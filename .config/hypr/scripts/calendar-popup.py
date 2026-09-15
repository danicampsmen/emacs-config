#!/usr/bin/env python3
# ==============================================================================
# GNOME-Style Calendar & Google Calendar Agenda Dropdown for Waybar / Hyprland
# ==============================================================================

import os
import sys
import re
import json
import time
import datetime
import threading
import subprocess

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, Gdk, GLib, Pango

try:
    from dateutil import parser as dt_parser, tz, rrule
except ImportError:
    # Minimal fallback if dateutil is unavailable
    from dateutil import tz
    dt_parser = None
    rrule = None

import requests

CONFIG_PATH = os.path.expanduser("~/.config/hypr/gcalendar_config.json")
CACHE_PATH = os.path.expanduser("~/.cache/gcalendar_cache.json")

DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
MESES = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
]
MESES_ABR = [
    "Ene", "Feb", "Mar", "Abr", "May", "Jun",
    "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"
]

APP_CSS = """
window.calendar-popup {
    background-color: #202024;
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 16px;
    box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

.header-box {
    padding: 12px 16px;
    background-color: rgba(255, 255, 255, 0.03);
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.header-title {
    font-size: 15px;
    font-weight: 700;
    color: #f6f6f6;
}

.btn-icon {
    border-radius: 9999px;
    padding: 6px;
    min-width: 32px;
    min-height: 32px;
}

.btn-today {
    font-weight: 600;
    font-size: 12px;
    padding: 4px 12px;
    border-radius: 8px;
    background-color: rgba(255, 255, 255, 0.08);
    color: #dedede;
}
.btn-today:hover {
    background-color: rgba(255, 255, 255, 0.15);
    color: #ffffff;
}

.config-drawer {
    background-color: #1a1a1d;
    padding: 14px 16px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.config-title {
    font-size: 13px;
    font-weight: 700;
    color: #78aeed;
}

.config-help {
    font-size: 11px;
    color: #a0a0a6;
}

.calendar-pane {
    padding: 12px 14px;
}

.agenda-pane {
    padding: 12px 16px;
    background-color: rgba(0, 0, 0, 0.12);
}

.agenda-header {
    font-size: 13px;
    font-weight: 700;
    color: #d1d1d6;
    margin-bottom: 8px;
}

.agenda-count-badge {
    font-size: 11px;
    font-weight: 600;
    padding: 2px 8px;
    border-radius: 9999px;
    background-color: rgba(53, 132, 228, 0.2);
    color: #78aeed;
}

.event-card {
    background-color: #27272c;
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 8px;
    transition: all 150ms ease;
}

.event-card:hover {
    background-color: #2e2e34;
    border-color: rgba(255, 255, 255, 0.15);
}

.time-badge {
    font-size: 11px;
    font-weight: 600;
    padding: 2px 7px;
    border-radius: 6px;
    background-color: rgba(53, 132, 228, 0.18);
    color: #78aeed;
}

.time-badge-allday {
    font-size: 11px;
    font-weight: 600;
    padding: 2px 7px;
    border-radius: 6px;
    background-color: rgba(246, 97, 81, 0.18);
    color: #ff7b63;
}

.event-title {
    font-size: 13px;
    font-weight: 600;
    color: #ffffff;
}

.event-location {
    font-size: 11px;
    color: #a0a0a6;
}

.btn-meet {
    font-size: 11px;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 6px;
    background-color: #1a73e8;
    color: #ffffff;
}
.btn-meet:hover {
    background-color: #1557b0;
}

.btn-link {
    font-size: 11px;
    padding: 4px 8px;
    border-radius: 6px;
    background-color: rgba(255, 255, 255, 0.08);
    color: #dedede;
}
.btn-link:hover {
    background-color: rgba(255, 255, 255, 0.15);
}

.btn-footer {
    font-size: 12px;
    padding: 6px 12px;
    border-radius: 8px;
    background-color: rgba(255, 255, 255, 0.05);
    color: #b0b0b6;
}
.btn-footer:hover {
    background-color: rgba(255, 255, 255, 0.1);
    color: #ffffff;
}

.empty-state-title {
    font-size: 14px;
    font-weight: 600;
    color: #9a9aa0;
}

.empty-state-subtitle {
    font-size: 12px;
    color: #6a6a70;
}
"""

def load_config():
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    return {"ics_url": "", "auto_refresh_minutes": 15}

def save_config(cfg):
    try:
        os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
        with open(CONFIG_PATH, 'w', encoding='utf-8') as f:
            json.dump(cfg, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving config: {e}", file=sys.stderr)

def load_cache():
    if os.path.exists(CACHE_PATH):
        try:
            with open(CACHE_PATH, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    return {"last_sync": 0, "events": []}

def save_cache(events):
    try:
        os.makedirs(os.path.dirname(CACHE_PATH), exist_ok=True)
        data = {
            "last_sync": time.time(),
            "events": events
        }
        with open(CACHE_PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving cache: {e}", file=sys.stderr)

def get_demo_events():
    local_tz = tz.tzlocal()
    now = datetime.datetime.now(local_tz)
    today = now.date()
    
    t1 = datetime.datetime.combine(today, datetime.time(10, 0), tzinfo=local_tz)
    t2 = datetime.datetime.combine(today, datetime.time(11, 0), tzinfo=local_tz)
    
    t3 = datetime.datetime.combine(today, datetime.time(15, 30), tzinfo=local_tz)
    t4 = datetime.datetime.combine(today, datetime.time(16, 30), tzinfo=local_tz)
    
    tomorrow = today + datetime.timedelta(days=1)
    t5 = datetime.datetime.combine(tomorrow, datetime.time(9, 0), tzinfo=local_tz)
    t6 = datetime.datetime.combine(tomorrow, datetime.time(10, 30), tzinfo=local_tz)

    return [
        {
            "summary": "Reunión de demostración (Google Meet)",
            "location": "Google Meet",
            "start": t1.isoformat(),
            "end": t2.isoformat(),
            "allday": False,
            "meet_url": "https://meet.google.com/abc-defg-hij",
            "is_demo": True
        },
        {
            "summary": "Planificación y desarrollo de proyectos",
            "location": "Oficina / Remoto",
            "start": t3.isoformat(),
            "end": t4.isoformat(),
            "allday": False,
            "meet_url": "",
            "is_demo": True
        },
        {
            "summary": "Día de enfoque / Sprint",
            "location": "",
            "start": datetime.datetime.combine(today, datetime.time.min, tzinfo=local_tz).isoformat(),
            "end": datetime.datetime.combine(today + datetime.timedelta(days=1), datetime.time.min, tzinfo=local_tz).isoformat(),
            "allday": True,
            "meet_url": "",
            "is_demo": True
        },
        {
            "summary": "Revisión técnica de código",
            "location": "Meet",
            "start": t5.isoformat(),
            "end": t6.isoformat(),
            "allday": False,
            "meet_url": "https://meet.google.com/xyz-uvwx-rst",
            "is_demo": True
        }
    ]

def parse_ics_text(content):
    content = re.sub(r'\r?\n[ \t]', '', content)
    local_tz = tz.tzlocal()
    events = []
    
    now = datetime.datetime.now(local_tz)
    window_start = now - datetime.timedelta(days=35)
    window_end = now + datetime.timedelta(days=100)
    
    vevent_matches = re.findall(r'BEGIN:VEVENT(.*?)END:VEVENT', content, re.DOTALL)
    for v in vevent_matches:
        summary = 'Sin título'
        s_m = re.search(r'^SUMMARY:(.*)$', v, re.MULTILINE)
        if s_m:
            summary = s_m.group(1).replace('\\,', ',').replace('\\;', ';').replace('\\n', '\n').replace('\\\\', '\\').strip()
            
        location = ''
        loc_m = re.search(r'^LOCATION:(.*)$', v, re.MULTILINE)
        if loc_m:
            location = loc_m.group(1).replace('\\,', ',').replace('\\;', ';').replace('\\n', '\n').replace('\\\\', '\\').strip()
            
        desc = ''
        desc_m = re.search(r'^DESCRIPTION:(.*)$', v, re.MULTILINE)
        if desc_m:
            desc = desc_m.group(1).replace('\\,', ',').replace('\\;', ';').replace('\\n', '\n').replace('\\\\', '\\').strip()
            
        dtstart_m = re.search(r'^DTSTART(?:;[^:]+)?:(.*)$', v, re.MULTILINE)
        dtend_m = re.search(r'^DTEND(?:;[^:]+)?:(.*)$', v, re.MULTILINE)
        
        if not dtstart_m:
            continue
            
        raw_start = dtstart_m.group(1).strip()
        raw_end = dtend_m.group(1).strip() if dtend_m else None
        
        is_allday = len(raw_start) == 8 and raw_start.isdigit()
        
        if is_allday:
            try:
                start_date = datetime.datetime.strptime(raw_start, '%Y%m%d').date()
                if raw_end and len(raw_end) == 8 and raw_end.isdigit():
                    end_date = datetime.datetime.strptime(raw_end, '%Y%m%d').date()
                else:
                    end_date = start_date + datetime.timedelta(days=1)
                start_dt = datetime.datetime.combine(start_date, datetime.time.min, tzinfo=local_tz)
                end_dt = datetime.datetime.combine(end_date, datetime.time.min, tzinfo=local_tz)
            except Exception:
                continue
        else:
            try:
                p_start = dt_parser.parse(raw_start)
                if p_start.tzinfo is not None:
                    start_dt = p_start.astimezone(local_tz)
                else:
                    start_dt = p_start.replace(tzinfo=local_tz)
            except Exception:
                continue
                
            if raw_end:
                try:
                    p_end = dt_parser.parse(raw_end)
                    if p_end.tzinfo is not None:
                        end_dt = p_end.astimezone(local_tz)
                    else:
                        end_dt = p_end.replace(tzinfo=local_tz)
                except Exception:
                    end_dt = start_dt + datetime.timedelta(hours=1)
            else:
                end_dt = start_dt + datetime.timedelta(hours=1)

        # Detect video call / meet links
        meet_match = re.search(r'https?://(?:meet\.google\.com/[a-z0-9-]+|[\w.-]*zoom\.us/[^\s<>"]+|teams\.microsoft\.com/[^\s<>"]+)', f'{location} {desc}')
        meet_url = meet_match.group(0) if meet_match else ''

        # Handle RRULE
        rrule_m = re.search(r'^RRULE:(.*)$', v, re.MULTILINE)
        if rrule_m and rrule:
            rule_str = rrule_m.group(1).strip()
            duration = end_dt - start_dt
            try:
                rule_obj = rrule.rrulestr(rule_str, dtstart=start_dt)
                occurrences = rule_obj.between(window_start, window_end, inc=True)
                for occ in occurrences:
                    occ_end = occ + duration
                    events.append({
                        'summary': summary,
                        'location': location,
                        'start': occ.isoformat(),
                        'end': occ_end.isoformat(),
                        'allday': is_allday,
                        'meet_url': meet_url
                    })
                continue
            except Exception:
                pass

        # Standard single occurrence
        if window_start <= start_dt <= window_end:
            events.append({
                'summary': summary,
                'location': location,
                'start': start_dt.isoformat(),
                'end': end_dt.isoformat(),
                'allday': is_allday,
                'meet_url': meet_url
            })
            
    events.sort(key=lambda x: x['start'])
    return events


class CalendarPopupApp(Adw.Application):
    def __init__(self):
        from gi.repository import Gio
        super().__init__(
            application_id='com.gnome.CalendarPopup',
            flags=Gio.ApplicationFlags.NON_UNIQUE
        )
        self.config = load_config()
        self.cache_data = load_cache()
        self.events = self.cache_data.get("events", [])
        
        # If cache empty and no ics_url configured, load demo events
        if not self.events and not self.config.get("ics_url"):
            self.events = get_demo_events()
            
        self.selected_date = datetime.date.today()
        self.is_syncing = False

    def do_activate(self):
        try:
            Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.FORCE_DARK)
            self.win = CalendarPopupWindow(self)
            self.win.present()
            
            # Check if background sync needed
            last_sync = self.cache_data.get("last_sync", 0)
            now_ts = time.time()
            ics_url = self.config.get("ics_url", "").strip()
            interval_sec = self.config.get("auto_refresh_minutes", 10) * 60
            
            if ics_url and (now_ts - last_sync > interval_sec or not self.events):
                self.start_sync_thread()
                
            GLib.timeout_add_seconds(interval_sec, self.periodic_check)
        except Exception as e:
            import traceback
            traceback.print_exc()

    def periodic_check(self):
        ics_url = self.config.get("ics_url", "").strip()
        if ics_url and not self.is_syncing:
            self.start_sync_thread()
        return True

    def start_sync_thread(self):
        if self.is_syncing:
            return
        ics_url = self.config.get("ics_url", "").strip()
        if not ics_url:
            return
            
        self.is_syncing = True
        self.win.set_sync_state(True)
        
        def run_fetch():
            try:
                resp = requests.get(ics_url, timeout=12, headers={"User-Agent": "GNOME-Calendar-Popup/1.0"})
                if resp.status_code == 200:
                    evs = parse_ics_text(resp.text)
                    save_cache(evs)
                    GLib.idle_add(self.on_sync_finished, evs, None)
                else:
                    GLib.idle_add(self.on_sync_finished, None, f"HTTP {resp.status_code}")
            except Exception as e:
                GLib.idle_add(self.on_sync_finished, None, str(e))
                
        threading.Thread(target=run_fetch, daemon=True).start()

    def on_sync_finished(self, evs, error):
        self.is_syncing = False
        self.win.set_sync_state(False)
        if evs is not None:
            self.events = evs
            self.win.update_calendar_marks()
            self.win.render_agenda()
            self.win.show_toast("Calendario sincronizado correctamente")
        elif error:
            self.win.show_toast(f"Error de sincronización: {error}")
        return False


class CalendarPopupWindow(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.app = app
        self.set_title("Calendario y Agenda")
        self.set_default_size(780, 540)
        self.selected_date = datetime.date.today()
        self.launch_time = time.time()
        self.apply_css()
        self.setup_ui()
        self.setup_events()
        
    def apply_css(self):
        provider = Gtk.CssProvider()
        provider.load_from_data(APP_CSS.encode('utf-8'))
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def setup_ui(self):
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.set_content(main_box)

        # -------------------------------------------------------------
        # 1. Header Bar
        # -------------------------------------------------------------
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        header_box.add_css_class("header-box")
        
        # Header Date
        today = datetime.date.today()
        day_str = DIAS[today.weekday()]
        month_str = MESES[today.month - 1]
        self.lbl_header = Gtk.Label(
            label=f"{day_str}, {today.day} de {month_str}",
            xalign=0
        )
        self.lbl_header.add_css_class("header-title")
        header_box.append(self.lbl_header)
        
        # Spacer
        spacer = Gtk.Box(hexpand=True)
        header_box.append(spacer)

        # Today Jump Button
        self.btn_today = Gtk.Button(label="Hoy")
        self.btn_today.add_css_class("btn-today")
        self.btn_today.connect("clicked", self.on_today_clicked)
        header_box.append(self.btn_today)

        # Sync Button
        self.btn_sync = Gtk.Button.new_from_icon_name("view-refresh-symbolic")
        self.btn_sync.add_css_class("btn-icon")
        self.btn_sync.add_css_class("flat")
        self.btn_sync.set_tooltip_text("Sincronizar con Google Calendar")
        self.btn_sync.connect("clicked", lambda b: self.app.start_sync_thread())
        header_box.append(self.btn_sync)

        # Settings / URL Button
        self.btn_settings = Gtk.Button.new_from_icon_name("preferences-system-symbolic")
        self.btn_settings.add_css_class("btn-icon")
        self.btn_settings.add_css_class("flat")
        self.btn_settings.set_tooltip_text("Configurar enlace iCal de Google Calendar")
        self.btn_settings.connect("clicked", self.on_toggle_settings)
        header_box.append(self.btn_settings)

        # Close Button
        self.btn_close = Gtk.Button.new_from_icon_name("window-close-symbolic")
        self.btn_close.add_css_class("btn-icon")
        self.btn_close.add_css_class("flat")
        self.btn_close.set_tooltip_text("Cerrar (Escape)")
        self.btn_close.connect("clicked", lambda b: self.close())
        header_box.append(self.btn_close)

        main_box.append(header_box)

        # -------------------------------------------------------------
        # 2. Configuration Drawer (Gtk.Revealer)
        # -------------------------------------------------------------
        self.revealer = Gtk.Revealer()
        self.revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
        self.revealer.set_reveal_child(False)

        cfg_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        cfg_box.add_css_class("config-drawer")

        cfg_title = Gtk.Label(label="Configuración de Google Calendar (iCal)", xalign=0)
        cfg_title.add_css_class("config-title")
        cfg_box.append(cfg_title)

        cfg_help = Gtk.Label(
            label="1. Abre Google Calendar > ⚙ Ajustes > Selecciona tu calendario.\n2. Ve a 'Integrar el calendario' y copia la 'Dirección secreta en formato iCal' (.ics).",
            xalign=0,
            wrap=True
        )
        cfg_help.add_css_class("config-help")
        cfg_box.append(cfg_help)

        entry_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.entry_url = Gtk.Entry(hexpand=True)
        self.entry_url.set_placeholder_text("https://calendar.google.com/calendar/ical/.../basic.ics")
        self.entry_url.set_text(self.app.config.get("ics_url", ""))
        entry_row.append(self.entry_url)

        btn_save = Gtk.Button(label="Guardar y sincronizar")
        btn_save.add_css_class("suggested-action")
        btn_save.connect("clicked", self.on_save_config)
        entry_row.append(btn_save)

        cfg_box.append(entry_row)
        self.revealer.set_child(cfg_box)
        main_box.append(self.revealer)

        # -------------------------------------------------------------
        # 3. Main Split Body (Calendar + Agenda)
        # -------------------------------------------------------------
        body_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0, vexpand=True)

        # --- Left Column: Calendar ---
        left_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        left_box.add_css_class("calendar-pane")
        left_box.set_size_request(320, -1)

        self.calendar = Gtk.Calendar()
        self.calendar.set_show_heading(True)
        self.calendar.set_show_day_names(True)
        self.calendar.set_show_week_numbers(False)
        self.calendar.connect("day-selected", self.on_day_selected)
        self.calendar.connect("notify::month", self.on_calendar_view_changed)
        self.calendar.connect("notify::year", self.on_calendar_view_changed)
        left_box.append(self.calendar)

        # Left Column Footer Buttons
        footer_actions = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6, halign=Gtk.Align.CENTER)
        
        btn_web = Gtk.Button(label="Abrir Google Calendar")
        btn_web.add_css_class("btn-footer")
        btn_web.connect("clicked", lambda b: subprocess.Popen(["xdg-open", "https://calendar.google.com"]))
        footer_actions.append(btn_web)

        btn_gnome = Gtk.Button(label="GNOME Calendar")
        btn_gnome.add_css_class("btn-footer")
        btn_gnome.connect("clicked", lambda b: subprocess.Popen(["gnome-calendar"]))
        footer_actions.append(btn_gnome)

        left_box.append(footer_actions)
        body_box.append(left_box)

        # Separator
        sep = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        body_box.append(sep)

        # --- Right Column: Agenda ---
        right_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8, hexpand=True, vexpand=True)
        right_box.add_css_class("agenda-pane")

        # Agenda Header Row
        agenda_hdr = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.lbl_agenda_title = Gtk.Label(label="Agenda", xalign=0)
        self.lbl_agenda_title.add_css_class("agenda-header")
        agenda_hdr.append(self.lbl_agenda_title)

        agenda_hdr.append(Gtk.Box(hexpand=True))

        self.lbl_count_badge = Gtk.Label(label="0 eventos")
        self.lbl_count_badge.add_css_class("agenda-count-badge")
        agenda_hdr.append(self.lbl_count_badge)

        right_box.append(agenda_hdr)

        # Scrolled Agenda List
        self.scroll = Gtk.ScrolledWindow(vexpand=True, hexpand=True)
        self.scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        
        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.scroll.set_child(self.list_box)
        right_box.append(self.scroll)

        body_box.append(right_box)
        main_box.append(body_box)

        # Initialize calendar markings and agenda list
        self.update_calendar_marks()
        self.render_agenda()

    def setup_events(self):
        # Keyboard handling: Escape to close
        key_ctrl = Gtk.EventControllerKey()
        key_ctrl.connect("key-pressed", self.on_key_pressed)
        self.add_controller(key_ctrl)

        self.has_been_focused = False
        self.connect("notify::is-active", self.on_is_active)

    def on_is_active(self, win, pspec):
        is_active = self.get_property("is-active")
        if is_active:
            self.has_been_focused = True
        elif self.has_been_focused:
            GLib.timeout_add(200, self.check_and_close)

    def check_and_close(self):
        if self.has_been_focused and not self.get_property("is-active"):
            self.close()
        return False

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False

    def on_toggle_settings(self, btn):
        revealed = self.revealer.get_reveal_child()
        self.revealer.set_reveal_child(not revealed)

    def on_save_config(self, btn):
        url = self.entry_url.get_text().strip()
        self.app.config["ics_url"] = url
        save_config(self.app.config)
        self.revealer.set_reveal_child(False)
        self.app.start_sync_thread()

    def on_today_clicked(self, btn):
        today = datetime.date.today()
        self.selected_date = today
        dt = GLib.DateTime.new_local(today.year, today.month, today.day, 0, 0, 0)
        self.calendar.set_date(dt)
        self.render_agenda()

    def on_day_selected(self, cal):
        gdt = cal.get_date()
        self.selected_date = datetime.date(gdt.get_year(), gdt.get_month(), gdt.get_day_of_month())
        self.render_agenda()

    def on_calendar_view_changed(self, cal, pspec):
        self.update_calendar_marks()

    def update_calendar_marks(self):
        self.calendar.clear_marks()
        gdt = self.calendar.get_date()
        view_year = gdt.get_year()
        view_month = gdt.get_month()

        marked_days = set()
        for ev in self.app.events:
            try:
                start_dt = datetime.datetime.fromisoformat(ev['start'])
                if start_dt.year == view_year and start_dt.month == view_month:
                    marked_days.add(start_dt.day)
            except Exception:
                continue

        for day in marked_days:
            self.calendar.mark_day(day)

    def render_agenda(self):
        # Clear list box
        while True:
            child = self.list_box.get_first_child()
            if not child:
                break
            self.list_box.remove(child)

        sel = self.selected_date
        today = datetime.date.today()

        # Update Agenda Title
        day_str = DIAS[sel.weekday()]
        month_str = MESES_ABR[sel.month - 1]
        
        if sel == today:
            title_text = f"Hoy — {day_str}, {sel.day} de {month_str}"
        elif sel == today + datetime.timedelta(days=1):
            title_text = f"Mañana — {day_str}, {sel.day} de {month_str}"
        elif sel == today - datetime.timedelta(days=1):
            title_text = f"Ayer — {day_str}, {sel.day} de {month_str}"
        else:
            title_text = f"{day_str}, {sel.day} de {month_str} de {sel.year}"

        self.lbl_agenda_title.set_label(title_text)

        # Filter events for selected day
        day_events = []
        for ev in self.app.events:
            try:
                start_dt = datetime.datetime.fromisoformat(ev['start'])
                end_dt = datetime.datetime.fromisoformat(ev['end'])
                
                # Check if event spans selected date
                if ev.get('allday'):
                    if start_dt.date() <= sel < end_dt.date():
                        day_events.append(ev)
                else:
                    if start_dt.date() == sel:
                        day_events.append(ev)
            except Exception:
                continue

        count = len(day_events)
        self.lbl_count_badge.set_label(f"{count} {'evento' if count == 1 else 'eventos'}")

        if count == 0:
            self.render_empty_state()
            return

        for ev in day_events:
            card = self.create_event_card(ev)
            self.list_box.append(card)

    def render_empty_state(self):
        empty_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10,
            halign=Gtk.Align.CENTER,
            valign=Gtk.Align.CENTER,
            vexpand=True
        )
        empty_box.set_margin_top(40)
        empty_box.set_margin_bottom(40)

        icon = Gtk.Image.new_from_icon_name("appointment-soon-symbolic")
        icon.set_pixel_size(48)
        icon.set_opacity(0.4)
        empty_box.append(icon)

        title = Gtk.Label(label="Sin eventos programados")
        title.add_css_class("empty-state-title")
        empty_box.append(title)

        if not self.app.config.get("ics_url"):
            subtitle = Gtk.Label(
                label="Haz clic en ⚙ arriba para ingresar el enlace de tu Google Calendar.",
                wrap=True,
                xalign=0.5
            )
            subtitle.add_css_class("empty-state-subtitle")
            empty_box.append(subtitle)
            
            btn_cfg = Gtk.Button(label="Conectar Google Calendar")
            btn_cfg.add_css_class("suggested-action")
            btn_cfg.connect("clicked", self.on_toggle_settings)
            empty_box.append(btn_cfg)
        else:
            subtitle = Gtk.Label(
                label="No tienes reuniones ni tareas pendientes para este día.",
                wrap=True,
                xalign=0.5
            )
            subtitle.add_css_class("empty-state-subtitle")
            empty_box.append(subtitle)

            if self.selected_date != datetime.date.today():
                btn_ret = Gtk.Button(label="Volver a hoy")
                btn_ret.add_css_class("btn-today")
                btn_ret.connect("clicked", self.on_today_clicked)
                empty_box.append(btn_ret)

        self.list_box.append(empty_box)

    def create_event_card(self, ev):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        card.add_css_class("event-card")

        # Top row: Time + Badge
        top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        
        is_allday = ev.get('allday', False)
        if is_allday:
            time_lbl = Gtk.Label(label="Todo el día")
            time_lbl.add_css_class("time-badge-allday")
        else:
            try:
                s_dt = datetime.datetime.fromisoformat(ev['start'])
                e_dt = datetime.datetime.fromisoformat(ev['end'])
                time_lbl = Gtk.Label(label=f"{s_dt.strftime('%H:%M')} – {e_dt.strftime('%H:%M')}")
                time_lbl.add_css_class("time-badge")
            except Exception:
                time_lbl = Gtk.Label(label="Horario")
                time_lbl.add_css_class("time-badge")

        top_row.append(time_lbl)
        
        if ev.get("is_demo"):
            demo_badge = Gtk.Label(label="Demo")
            demo_badge.add_css_class("agenda-count-badge")
            top_row.append(demo_badge)

        top_row.append(Gtk.Box(hexpand=True))

        card.append(top_row)

        # Title
        summary_lbl = Gtk.Label(label=ev.get('summary', 'Sin título'), xalign=0, wrap=True)
        summary_lbl.add_css_class("event-title")
        card.append(summary_lbl)

        # Location row
        loc = ev.get('location', '').strip()
        if loc:
            loc_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            loc_icon = Gtk.Image.new_from_icon_name("mark-location-symbolic")
            loc_icon.set_opacity(0.6)
            loc_box.append(loc_icon)
            
            loc_lbl = Gtk.Label(label=loc, xalign=0, ellipsize=Pango.EllipsizeMode.END)
            loc_lbl.add_css_class("event-location")
            loc_box.append(loc_lbl)
            card.append(loc_box)

        # Action Buttons (e.g. Google Meet, Zoom)
        meet_url = ev.get('meet_url', '').strip()
        if meet_url:
            act_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            act_box.set_margin_top(4)

            btn_meet = Gtk.Button(label="📹 Unirse a Google Meet" if "meet.google.com" in meet_url else "📹 Unirse a la reunión")
            btn_meet.add_css_class("btn-meet")
            btn_meet.connect("clicked", lambda b, u=meet_url: subprocess.Popen(["xdg-open", u]))
            act_box.append(btn_meet)

            card.append(act_box)

        return card

    def set_sync_state(self, is_syncing):
        if is_syncing:
            self.btn_sync.set_sensitive(False)
            self.btn_sync.set_tooltip_text("Sincronizando...")
        else:
            self.btn_sync.set_sensitive(True)
            self.btn_sync.set_tooltip_text("Sincronizar con Google Calendar")

    def show_toast(self, message):
        # We can update the tooltip or show a brief label
        self.btn_sync.set_tooltip_text(message)


def sync_headless():
    cfg = load_config()
    ics_url = cfg.get("ics_url", "").strip()
    if not ics_url:
        print("No hay URL de Google Calendar configurada en ~/.config/hypr/gcalendar_config.json")
        return False
    print(f"Sincronizando desde: {ics_url[:30]}...")
    try:
        resp = requests.get(ics_url, timeout=15, headers={"User-Agent": "GNOME-Calendar-Popup/1.0"})
        if resp.status_code == 200:
            evs = parse_ics_text(resp.text)
            save_cache(evs)
            print(f"Sincronización exitosa: {len(evs)} eventos cacheados.")
            return True
        else:
            print(f"Error HTTP {resp.status_code}", file=sys.stderr)
            return False
    except Exception as e:
        print(f"Error de conexión: {e}", file=sys.stderr)
        return False

def main():
    if "--sync" in sys.argv or "--sync-only" in sys.argv:
        success = sync_headless()
        sys.exit(0 if success else 1)
        
    app = CalendarPopupApp()
    app.run(sys.argv)

if __name__ == "__main__":
    main()
