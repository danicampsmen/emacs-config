#!/usr/bin/env python3
# ==============================================================================
# Volume Daemon & OSD for Hyprland / PipeWire
#
# Control de volumen reactivo con parada instantánea a 0 ms:
# - Basado en eventos nativos del kernel (evdev):
#     ev.value == 1 (press)   -> ejecuta el paso de 2% de forma instantánea.
#     ev.value == 2 (hold)    -> repite suavemente (~28 Hz) mientras se mantenga presionada.
#     ev.value == 0 (release) -> PARADA INMEDIATA (0 ms) y sincronización con WirePlumber.
# - Soporte para JamesDSP: Si JamesDSP está activo, sincroniza automáticamente tanto
#   el sumidero virtual (jamesdsp_sink) como el DAC físico de hardware (Speaker),
#   garantizando que el sonido real siempre cambie de volumen y mute.
# ==============================================================================
import os
import re
import sys
import time
import select
import subprocess
import evdev
from evdev import ecodes

AUDIO_SINK = "@DEFAULT_AUDIO_SINK@"
AUDIO_SOURCE = "@DEFAULT_AUDIO_SOURCE@"

# Tamaño del paso por cada pulso (2% exacto)
VOLUME_STEP = 2

def get_default_sink_name():
    try:
        return subprocess.check_output(["pactl", "get-default-sink"], text=True).strip()
    except Exception:
        return ""

def get_physical_sink():
    try:
        out = subprocess.check_output(["pactl", "list", "sinks", "short"], text=True)
        running = []
        alsa = []
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 2:
                name = parts[1]
                if name.startswith("alsa_output.") or name.startswith("bluez_output."):
                    if len(parts) >= 5 and parts[4] == "RUNNING":
                        running.append(name)
                    alsa.append(name)
        if running:
            for r in running:
                if "Speaker" in r or "Headphone" in r:
                    return r
            return running[0]
        for a in alsa:
            if "Speaker" in a or "Headphone" in a:
                return a
        return alsa[0] if alsa else "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
    except Exception:
        return "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"

def get_volume_info():
    try:
        out = subprocess.check_output(["wpctl", "get-volume", AUDIO_SINK], text=True)
        muted = "[MUTED]" in out
        m = re.search(r"Volume:\s+([0-9\.]+)", out)
        vol = int(round(float(m.group(1)) * 100)) if m else 50
        return vol, muted
    except Exception:
        return 50, False

def get_mic_info():
    try:
        out = subprocess.check_output(["wpctl", "get-volume", AUDIO_SOURCE], text=True)
        return "[MUTED]" in out
    except Exception:
        return False

def send_osd_notification(vol, muted):
    if muted or vol <= 0:
        icon = "audio-volume-muted"
        text = "Silenciado" if muted else "0%"
    elif vol < 30:
        icon = "audio-volume-low"
        text = f"{vol}%"
    elif vol < 70:
        icon = "audio-volume-medium"
        text = f"{vol}%"
    else:
        icon = "audio-volume-high"
        text = f"{vol}%"

    subprocess.Popen([
        "notify-send",
        "-h", "string:x-canonical-private-synchronous:audio-volume",
        "-h", f"int:value:{vol}",
        "-i", icon,
        "-t", "600",
        "Volumen", text
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def send_mic_notification(muted):
    icon = "microphone-sensitivity-muted" if muted else "microphone-sensitivity-high"
    text = "Silenciado" if muted else "Activado"
    subprocess.Popen([
        "notify-send",
        "-h", "string:x-canonical-private-synchronous:audio-mic",
        "-i", icon,
        "-t", "600",
        "Micrófono", text
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

class VolumeDaemon:
    def __init__(self):
        self.vol, self.muted = get_volume_info()
        self.physical_sink = get_physical_sink()
        self.is_jamesdsp = (get_default_sink_name() == "jamesdsp_sink")
        self.devices = {}
        self.epoll = select.epoll()
        self.wpctl_proc = None
        self.last_step_time = 0.0
        self.last_osd_time = 0.0

    def _apply_step(self, direction, is_repeat=False):
        now = time.monotonic()
        if is_repeat and (now - self.last_step_time < 0.035):
            return
        self.last_step_time = now

        step_str = f"{VOLUME_STEP}%+" if direction > 0 else f"{VOLUME_STEP}%-"
        cmd = ["wpctl", "set-volume", "-l", "1.5", AUDIO_SINK, step_str] if direction > 0 else ["wpctl", "set-volume", AUDIO_SINK, step_str]
        self.wpctl_proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # Si JamesDSP es el sumidero activo, aplicar también al DAC físico
        if self.is_jamesdsp and self.physical_sink:
            p_step = f"+{VOLUME_STEP}%" if direction > 0 else f"-{VOLUME_STEP}%"
            subprocess.Popen(["pactl", "set-sink-volume", self.physical_sink, p_step], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if direction > 0:
            self.vol = min(150, self.vol + VOLUME_STEP)
        else:
            self.vol = max(0, self.vol - VOLUME_STEP)
        self.muted = False

        if now - self.last_osd_time >= 0.04:
            self.last_osd_time = now
            send_osd_notification(self.vol, self.muted)

    def rescan_devices(self):
        self.physical_sink = get_physical_sink()
        self.is_jamesdsp = (get_default_sink_name() == "jamesdsp_sink")

        for fd, dev in list(self.devices.items()):
            if not os.path.exists(dev.path):
                self.unregister_fd(fd)

        current_paths = {d.path for d in self.devices.values()}
        for path in evdev.list_devices():
            if path in current_paths:
                continue
            try:
                dev = evdev.InputDevice(path)
                caps = dev.capabilities()
                if ecodes.EV_KEY in caps:
                    keys = caps[ecodes.EV_KEY]
                    if any(k in keys for k in [ecodes.KEY_VOLUMEUP, ecodes.KEY_VOLUMEDOWN, ecodes.KEY_MUTE, ecodes.KEY_MICMUTE]):
                        self.devices[dev.fd] = dev
                        self.epoll.register(dev.fd, select.EPOLLIN)
                    else:
                        dev.close()
                else:
                    dev.close()
            except Exception:
                pass

    def unregister_fd(self, fd):
        try:
            self.epoll.unregister(fd)
        except Exception:
            pass
        if fd in self.devices:
            try:
                self.devices[fd].close()
            except Exception:
                pass
            del self.devices[fd]

    def run(self):
        self.rescan_devices()
        last_rescan = time.monotonic()

        while True:
            now = time.monotonic()

            # Rescan de dispositivos y sincronización pasiva cada 2 segundos en reposo
            if now - last_rescan >= 2.0:
                last_rescan = now
                self.rescan_devices()
                self.vol, self.muted = get_volume_info()

            try:
                events = self.epoll.poll(timeout=2.0)
            except IOError:
                continue

            for fd, event_mask in events:
                if event_mask & (select.EPOLLHUP | select.EPOLLERR):
                    self.unregister_fd(fd)
                    continue

                dev = self.devices.get(fd)
                if not dev:
                    continue

                try:
                    while True:
                        ev = dev.read_one()
                        if ev is None:
                            break
                        if ev.type != ecodes.EV_KEY:
                            continue

                        # 1. EVENTO PRESS (val == 1): Ejecución instantánea sin descarte
                        if ev.value == 1:
                            if ev.code == ecodes.KEY_VOLUMEUP:
                                self._apply_step(1, is_repeat=False)
                            elif ev.code == ecodes.KEY_VOLUMEDOWN:
                                self._apply_step(-1, is_repeat=False)
                            elif ev.code == ecodes.KEY_MUTE:
                                subprocess.Popen(["wpctl", "set-mute", AUDIO_SINK, "toggle"])
                                if self.is_jamesdsp and self.physical_sink:
                                    subprocess.Popen(["pactl", "set-sink-mute", self.physical_sink, "toggle"])
                                time.sleep(0.02)
                                self.vol, self.muted = get_volume_info()
                                send_osd_notification(self.vol, self.muted)
                            elif ev.code == ecodes.KEY_MICMUTE:
                                subprocess.Popen(["wpctl", "set-mute", AUDIO_SOURCE, "toggle"])
                                time.sleep(0.02)
                                send_mic_notification(get_mic_info())

                        # 2. EVENTO REPEAT (val == 2): Rampa fluida a ~28 Hz
                        elif ev.value == 2:
                            if ev.code == ecodes.KEY_VOLUMEUP:
                                self._apply_step(1, is_repeat=True)
                            elif ev.code == ecodes.KEY_VOLUMEDOWN:
                                self._apply_step(-1, is_repeat=True)

                        # 3. EVENTO RELEASE (val == 0): Parada instantánea y sincronización final
                        elif ev.value == 0:
                            if ev.code in (ecodes.KEY_VOLUMEUP, ecodes.KEY_VOLUMEDOWN):
                                if self.wpctl_proc is not None:
                                    try:
                                        self.wpctl_proc.wait(timeout=0.08)
                                    except Exception:
                                        pass
                                self.vol, self.muted = get_volume_info()
                                send_osd_notification(self.vol, self.muted)

                except (BlockingIOError, OSError):
                    pass

if __name__ == "__main__":
    VolumeDaemon().run()
