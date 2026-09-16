# Firefox Configuration & PWAs Backup

Este directorio contiene el respaldo modular de la configuración de Firefox para el sistema (Ubuntu Wayland / Lenovo Yoga 9).

## Contenido

- **`profiles.ini`**: Configuración de perfiles del navegador (Perfil predeterminado: **Daniel**, secundario: **UNI**).
- **`user.js`**: Optimizaciones avanzadas para Wayland, aceleración por hardware VA-API Intel QuickSync, ahorro de batería y rendimiento en pantalla 4K.
- **`firefoxpwa/`**:
  - `config.json`: Configuración unificada de las 9 Progressive Web Apps (PWAs) en modo *standalone* y tema oscuro `#12141a`.
  - `firefox-pwa-runtime`: Wrapper ejecutable con `export MOZ_NO_REMOTE=1` para evitar secuestro de enlaces externos.
  - `pwa-user.js`: Preferencias aplicadas a cada perfil de PWA (desactivación de barra de pestañas, apertura de enlaces fuera de alcance en el navegador principal).
  - `pwa-userChrome.css`: Inyección de estilo CSS para barra superior oscura (`#12141a`).
- **`desktop-entries/`**:
  - `firefox_firefox.desktop`: Acceso directo para perfil Daniel.
  - `firefox-uni.desktop`: Acceso directo para perfil UNI.
  - `firefox-profiles.desktop`: Selector interactivo de perfiles.
  - `FFPWA-*.desktop`: Accesos directos de las PWAs instaladas (WhatsApp, Calendar, etc.).
