#!/usr/bin/env python3
# ==============================================================================
# Volume Daemon & OSD for Hyprland / PipeWire
#
# Control de volumen reactivo con parada instantánea a 0 ms:
# - Basado en eventos nativos del kernel (evdev):
#     ev.value == 1 (press)   -> ejecuta el primer paso de 1%.
#     ev.value == 2 (hold)    -> repite suavemente mientras se mantenga presionada.
#     ev.value == 0 (release) -> PARADA INMEDIATA (0 ms). El kernel deja de emitir
#                               eventos y el volumen se detiene en el acto.
# - Cero hilos en segundo plano (Thread-free) y cero temporizadores artificiales.
# - Prevención de colas: no se acumulan procesos wpctl en segundo plano.
# ==============================================================================
import os
import re
import sys
import time
import select
import signal
import subprocess
import evdev
from evdev import ecodes

AUDIO_SINK = "@DEFAULT_AUDIO_SINK@"
AUDIO_SOURCE = "@DEFAULT_AUDIO_SOURCE@"

# Tamaño del paso por cada pulso (1% exacto)
VOLUME_STEP = 1

# Evitar procesos zombie en Linux al usar Popen
signal.signal(signal.SIGCHLD, signal.SIG_IGN)

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
        self.devices = {}
        self.epoll = select.epoll()
        self.wpctl_proc = None
        self.last_osd_time = 0.0

    def _apply_step(self, direction):
        # Evitar sobrecargar PipeWire si una llamada previa de wpctl sigue en vuelo
        if self.wpctl_proc is not None and self.wpctl_proc.poll() is None:
            return

        step_str = f"{VOLUME_STEP}%+" if direction > 0 else f"{VOLUME_STEP}%-"
        cmd = ["wpctl", "set-volume", "-l", "1.5", AUDIO_SINK, step_str] if direction > 0 else ["wpctl", "set-volume", AUDIO_SINK, step_str]
        self.wpctl_proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if direction > 0:
            self.vol = min(150, self.vol + VOLUME_STEP)
        else:
            self.vol = max(0, self.vol - VOLUME_STEP)
        self.muted = False

        # Throttling de OSD durante repetición continua (~16 fps)
        now = time.monotonic()
        if now - self.last_osd_time >= 0.05:
            self.last_osd_time = now
            send_osd_notification(self.vol, self.muted)

    def rescan_devices(self):
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

                        # 1. EVENTO PRESS (val == 1) o REPEAT NATIVO (val == 2):
                        # Ejecuta el incremento mientras se mantenga la tecla presionada
                        if ev.value in (1, 2):
                            if ev.code == ecodes.KEY_VOLUMEUP:
                                self._apply_step(1)
                            elif ev.code == ecodes.KEY_VOLUMEDOWN:
                                self._apply_step(-1)
                            elif ev.value == 1 and ev.code == ecodes.KEY_MUTE:
                                subprocess.Popen(["wpctl", "set-mute", AUDIO_SINK, "toggle"])
                                time.sleep(0.02)
                                self.vol, self.muted = get_volume_info()
                                send_osd_notification(self.vol, self.muted)
                            elif ev.value == 1 and ev.code == ecodes.KEY_MICMUTE:
                                subprocess.Popen(["wpctl", "set-mute", AUDIO_SOURCE, "toggle"])
                                time.sleep(0.02)
                                send_mic_notification(get_mic_info())

                        # 2. EVENTO RELEASE (val == 0):
                        # PARADA INSTANTÁNEA (0 ms): El kernel cesa la emisión de repeticiones.
                        # Esperamos a que finalice el proceso en vuelo si lo hay y sincronizamos.
                        elif ev.value == 0:
                            if ev.code in (ecodes.KEY_VOLUMEUP, ecodes.KEY_VOLUMEDOWN):
                                if self.wpctl_proc is not None:
                                    try:
                                        self.wpctl_proc.wait(timeout=0.04)
                                    except Exception:
                                        pass
                                self.vol, self.muted = get_volume_info()
                                send_osd_notification(self.vol, self.muted)

                except (BlockingIOError, OSError):
                    pass

if __name__ == "__main__":
    VolumeDaemon().run()
