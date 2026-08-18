# Configuración de Inkscape + Emacs Math Pad (Workflow Gilles Castel)

Este directorio contiene la copia de seguridad, código fuente y scripts de despliegue para la integración completa de Inkscape con GNU Emacs bajo GNOME / Wayland (Ubuntu).

---

## 📁 Estructura del Directorio

```text
inkscape/
├── applications/
│   └── inkscape-math-pad.desktop   # Lanzador .desktop para GNOME Shell
├── bin/
│   ├── inkscape-math-pad          # Launcher del popup flotante de Emacs
│   └── wayland-paste              # Demonio uinput para emisión instantánea de Ctrl+V
├── extensions/                    # Extensiones de estilo Castel para Inkscape
│   ├── castel_arrow.py / .inx     # Flechas (a, Shift+a, Shift+r)
│   ├── castel_width.py / .inx     # Grosor de línea (w, Shift+w)
│   ├── castel_color.py / .inx     # Paleta de colores (c, Shift+c)
│   ├── castel_fill.py / .inx      # Rellenos (f, Shift+f)
│   ├── castel_stroke.py / .inx    # Estilos de trazo (s, Shift+s)
│   ├── castel_opacity.py / .inx   # Opacidad (o, Shift+o)
│   ├── castel_charts.py / .inx    # Gráficos (u, Shift+u)
│   ├── castel_point.py / .inx     # Puntos (p)
│   ├── castel_halo.py / .inx      # Halo blanco (Ctrl+b)
│   └── crear_extensiones.sh       # Generador de estilos
├── keys/
│   └── default.xml                # Mapeo de atajos sin colisiones en Inkscape
├── systemd/
│   └── wayland-paste.service      # Servicio systemd de usuario para el demonio de pegado
├── install.sh                     # Script de instalación y restauración automática
└── README.md                      # Esta documentación
```

---

## ⌨️ Tabla de Atajos de Teclado en Inkscape

| Tecla / Atajo | Acción / Extensión |
|---|---|
| `<Alt>m` | **Abrir Math Pad Flotante en Emacs** |
| `w` / `<Shift>w` | Ciclar Grosor de Trazo (adelante / atrás) |
| `a` / `<Shift>a` | Ciclar Flechas / Marcadores (adelante / atrás) |
| `<Shift>r` | Invertir dirección de la flecha |
| `c` / `<Shift>c` | Ciclar Colores |
| `f` / `<Shift>f` | Ciclar Rellenos |
| `s` / `<Shift>s` | Ciclar Tipos de Trazo (continuo, punteado, etc.) |
| `o` / `<Shift>o` | Ciclar Opacidad |
| `u` / `<Shift>u` | Ciclar Gráficos / Estilos de Diagrama |
| `p` | Generar Punto |
| `<Primary>b` | Alternar Halo Blanco de Fondo |
| `v` / `F1` | Herramienta de Selección (Select Tool) |

---

## 📝 Uso del Math Pad

1. En Inkscape, presiona **`<Alt>m>`**.
2. Aparecerá una ventana compacta, centrada y en primer plano.
3. Escribe tu fórmula o texto en LaTeX (ej. `$f(x) = \sin(x)$`).
4. Presiona **`Enter`**, **`C-c C-c`** o **`ZZ`** para confirmar:
   * La ventana se cierra limpiamente al instante.
   * El demonio `wayland-paste` actualiza el portapapeles y envía `Ctrl + V` a Inkscape sin latencia.
5. Presiona **`Esc`**, **`q`** o **`C-c C-k`** para cancelar sin pegar.

---

## 🚀 Restauración en un Nuevo Sistema

Para desplegar esta configuración completa en otra máquina o tras reinstalar el sistema:

```bash
cd ~/.emacs.d/inkscape
./install.sh
```

El script se encargará automáticamente de:
1. Copiar extensiones y atajos a `~/.config/inkscape/`.
2. Instalar los ejecutables en `~/.local/bin/`.
3. Registrar la aplicación en `~/.local/share/applications/`.
4. Habilitar y arrancar `wayland-paste.service` con `systemctl --user`.
5. Configurar el atajo global `<Alt>m` en GNOME Shell con `gsettings`.
