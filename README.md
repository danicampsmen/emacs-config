---

### 📁 Estructura del Ecosistema de Documentación

```text
~/.emacs.d/
├── README.md                           # Índice maestro y arquitectura general
└── docs/
    ├── 01-arquitectura-y-flujo.md       # Núcleo, arranque, UI y motor de edición modal
    ├── 02-guia-atajos-y-navegacion.md   # Cheat sheet exhaustivo de atajos (Líder ';')
    ├── 03-ecosistema-latex-e-ihes.md    # AUCTeX, Tree-sitter AST, Zen, apuntes-scr y tesis-uni
    ├── 04-ia-google-antigravity.md      # Agente Antigravity, REPL vterm, Diff Inline y diagnósticos
    ├── 05-segundo-cerebro-y-zotero.md   # Zotero Citar, Zettelkasten, BibTool y compilación
    └── 06-inkscape-y-sincronizacion.md  # Math Pad Wayland (uinput), Rclone Bisync y SyncClient
```

---

# ARCHIVO: `README.md`

```markdown
# 🌌 Emacs Mathematical Research IDE & Antigravity Agent Station

Estación de trabajo científica y editorial de alto rendimiento sobre **GNU Emacs (v30+)**, optimizada para la **investigación matemática avanzada, redacción editorial de nivel profesional (Arquitectura IHÉS / EGA Bourbaki), gestión del conocimiento (Segundo Cerebro / Zotero), computación con Julia, sincronización en la nube e Inteligencia Artificial Agéntica con Google Antigravity**.

---

## 🏛️ Mapa de Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           early-init.el                                 │
│      Optimizaciones de IPC, UI nativa silenciada, GC diferido inicial   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                              init.el                                    │
│                   Controlador maestro y carga secuencial                │
└──────┬─────────────────────────────┬─────────────────────────────┬──────┘
       │                             │                             │
┌──────▼──────────────┐       ┌──────▼──────────────┐       ┌──────▼──────────────┐
│  Núcleo y Edición   │       │ Ecosistema LaTeX    │       │ Agentes e IA        │
│  - my-packages.el   │       │ - my-latex-core.el  │       │ - my-ai.el          │
│  - my-ui.el         │       │ - my-latex-tree-... │       │   (Antigravity CLI  │
│  - my-editor.el     │       │ - my-latex-expan... │       │    Gemini 3.7 /     │
│  - my-keys.el       │       │ - my-latex-snip...  │       │    Claude 4.6 /     │
│  (Evil, Vertico,    │       │ - my-latex-visu...  │       │    Diff Inline)     │
│   Consult, Embark)  │       │ - tesis-snippets.el │       │ - gptel / aidermacs │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
       │                             │                             │
┌──────▼──────────────┐       ┌──────▼──────────────┐       ┌──────▼──────────────┐
│  Segundo Cerebro    │       │ Layouts y Gráficos  │       │ Sincronización      │
│  - my-second-brain  │       │ - tesis-layout.el   │       │ - gdrive-sync.el    │
│  - my-pdf.el        │       │ - tesis-tools.el    │       │   (Rclone Bisync /  │
│  (Citar, Zotero,    │       │ (Inkscape pdf_tex,  │       │    FUSE / Ediff)    │
│   Diario, BibTool)  │       │  Wayland Math Pad)  │       │ - syncclient.el     │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
```

---

## ⚡ Pila Tecnológica Integrada

| Capa / Subsistema | Tecnologías y Paquetes Clave |
|---|---|
| **Motor Modal & Navegación** | `evil`, `evil-collection`, `evil-surround`, `evil-mc`, `evil-tex`, `general`, `avy`, `harpoon`, `ace-window`, `undo-fu`. |
| **Búsqueda & Minibuffer** | `vertico`, `marginalia`, `orderless`, `consult`, `embark`, `embark-consult`, `wgrep`. |
| **Completado & Expansión** | `corfu`, `nerd-icons-corfu`, `cape`, `tempel`, `aas`, `laas` *(LaTeX Auto-Activating Snippets)*. |
| **Motor LaTeX & AST** | `auctex`, `reftex`, `eglot` *(TexLab LSP)*, `treesit` *(tree-sitter-latex)*, `texmathp`, `latexmk`, `zathura`. |
| **Tipografía & Documentclasses**| `apuntes-scr.cls` (v6.5 KOMA Bourbaki), `tesis-uni.cls` (v22.0 IHÉS EGA), STIX Two, TeX Gyre Termes. |
| **Inteligencia Artificial** | `Google Antigravity CLI (agy)`, `vterm`, `transient`, `gptel` *(Gemini 3.7 Flash, Claude Sonnet 4.6)*, `aidermacs`. |
| **Gestión del Conocimiento**| `citar`, `citar-embark`, `org-mode`, `org-modern`, `calfw`, `calfw-org`, `bibtool`, `graphviz`. |
| **Dibujo & Puente Gráfico** | `Inkscape` (Atajos Gilles Castel), `wayland-paste` (/dev/uinput daemon), `Inkscape Math Pad`. |
| **Nube & Persistencia** | `rclone` (bisync bidireccional, montura FUSE, TRAMP), `multisession`, `syncclient`. |

---

## 📚 Índice de Documentación Detallada

Para consultar la referencia técnica completa, dirígete a los módulos en la carpeta [`docs/`](./docs/):

1. [**01. Arquitectura, Rendimiento y Edición Base**](./docs/01-arquitectura-y-flujo.md): Ciclo de arranque, GC diferido, tema Modus Vivendi, pila Vertico/Consult/Embark, terminal Vterm y Julia REPL.
2. [**02. Guía Maestra de Atajos de Teclado (Cheat Sheet)**](./docs/02-guia-atajos-y-navegacion.md): Lista exhaustiva de todos los comandos indexados bajo la tecla líder `;`.
3. [**03. Ecosistema LaTeX, Tree-Sitter y Clases Maestras**](./docs/03-ecosistema-latex-e-ihes.md): Formateo AST Tree-sitter a 120 columnas, Súper Salto `TAB`, Visual Zen (TeX-Fold dinámico), clases `apuntes-scr.cls` y `tesis-uni.cls`.
4. [**04. Inteligencia Artificial: Google Antigravity & Jarvis**](./docs/04-ia-google-antigravity.md): CLI `agy`, terminal interactiva en vterm, edición inline con diff preview, auto-diagnósticos de compilación y herramientas LaTeX.
5. [**05. Segundo Cerebro, Bibliografía y Zotero**](./docs/05-segundo-cerebro-y-zotero.md): Flujo Zotero con Citar, enlaces mágicos a PDFs, diario automatizado, generación de `imports.tex` y compilación incremental.
6. [**06. Dibujo Vectorial (Inkscape Math Pad) y Sincronización en la Nube**](./docs/06-inkscape-y-sincronizacion.md): Math Pad flotante Wayland, exportación `.pdf_tex`, Rclone Bisync y SyncClient.

---

## 🚀 Inicio Rápido

```bash
# 1. Clonar configuración en el directorio de Emacs
git clone <tu-repositorio> ~/.emacs.d

# 2. Instalar dependencias del sistema (Ubuntu/Debian)
sudo apt install -y emacs-pgtk texlive-full zathura zathura-pdf-poppler \
                    ripgrep fd-find libvterm-dev libtool-bin cmake \
                    rclone python3-evdev python3-pyperclip inkscape wl-clipboard bibtool graphviz

# 3. Configurar permisos de uinput para el Math Pad de Inkscape
sudo usermod -aG uinput $USER
echo 'KERNEL=="uinput", GROUP="uinput", MODE="0660"' | sudo tee /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# 4. Iniciar Emacs (los paquetes se descargarán y compilarán automáticamente)
emacs
```
```

---

# ARCHIVO: `docs/01-arquitectura-y-flujo.md`

```markdown
# 01. Arquitectura, Rendimiento y Edición Base

Este documento detalla los componentes del núcleo de Emacs, las optimizaciones de bajo nivel para el arranque instantáneo y el entorno de edición modal.

---

## 1. Ciclo de Arranque y Rendimiento

### 1.1 Optimizaciones de Pre-Arranque (`early-init.el`)
El archivo `early-init.el` se ejecuta antes de inicializar la interfaz gráfica y el gestor de paquetes, permitiendo:
- **Desactivación de UI nativa:** Elimina barras de menú, herramientas y barras de desplazamiento (`tool-bar-lines`, `menu-bar-lines`, `vertical-scroll-bars`) antes de dibujar el frame, eliminando parpadeos (*flickering*).
- **Control de Garbage Collector:** Se asigna `gc-cons-threshold` a `most-positive-fixnum` durante el arranque. Al finalizar la carga, `emacs-startup-hook` lo restablece a 20 MB y el paquete `gcmh` (*Garbage Collection Magic Hack*) toma el control, asignando un umbral de 512 MB durante el trabajo activo y recolectando solo cuando Emacs entra en inactividad (2.0s).
- **Buffer IPC de Alto Rendimiento:** `read-process-output-max` se incrementa a 3 MB (por defecto 4 KB), acelerando la comunicación asíncrona con TexLab LSP, Vterm y el CLI de Antigravity.
- **Compilación Nativa Silenciosa:** `native-comp-async-report-warnings-errors` se establece en `'silent` para evitar popups molestos de compilación en segundo plano.

### 1.2 Carga Modular Orquestada (`init.el`)
`init.el` gestiona el orden estricto de carga de dependencias:
1. `my-packages.el`: Bootstrap de `use-package` y verificación declarativa de paquetes.
2. `exec-path-from-shell`: Sincronización del `$PATH` de Linux en entornos gráficos.
3. `gcmh`: Activación del recolector de basura diferido.
4. `my-ui.el`, `my-editor.el`, `my-ai.el`, `my-pdf.el`: Interfaz, edición modal, IA y visualizador.
5. **Ecosistema LaTeX:** `my-latex-core` $\rightarrow$ `my-latex-tree-sitter` $\rightarrow$ `my-latex-snippets` $\rightarrow$ `my-latex-expansions` $\rightarrow$ `my-latex-visuals`.
6. **Segundo Cerebro & Cloud:** `tesis-tools`, `tesis-layout`, `gdrive-sync`, `syncclient`, `my-second-brain`.
7. `my-keys.el`: Declaración de atajos con `general.el` al final para garantizar que todas las funciones existan en memoria.

---

## 2. Experiencia Visual e Interfaz (`my-ui.el`)

- **Tema:** `modus-vivendi-deuteranopia` (Tema oscuro de máximo contraste y accesibilidad cromática).
- **Tipografía:** 
  - *Fuente Principal:* `Iosevka Term` (Light, 15pt), ideal para mantener la alineación estricta de tablas, matrices y ecuaciones `align*`.
  - *Fallback:* `DejaVu Sans Mono`.
  - *Símbolos y Glifos:* `Symbols Nerd Font Mono` para renderizado perfecto de iconos en Dired, Modeline y Minibuffer.
- **Modeline:** `doom-modeline` optimizada con altura 30px y soporte de `minions-mode` para ocultar minor modes redundantes.
- **Regla de 120 Columnas:** `display-fill-column-indicator-mode` activo con límite visual en la columna 120 (`#333333`).
- **Modo Terminal-GUI (`my-terminal-gui-mode`):** Permite alternar mediante `; e t` una interfaz ultralimpia sin decoraciones de ventana (`undecorated`), sin barra de menús y desactivando totalmente las interacciones con el ratón (`my-no-mouse-mode`) para forzar un flujo 100% de teclado.

---

## 3. Pila de Completado y Minibuffer

El sistema sustituye las interfaces pesadas tipo Ivy/Helm por la suite modular moderna de Emacs:

```text
Minibuffer Query
       │
       ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Vertico    │ ───► │  Orderless   │ ───► │  Marginalia  │
│ (UI Vertical)│      │  (Filtrado   │      │(Anotaciones  │
│              │      │  sin orden)  │      │ y metadatos) │
└──────┬───────┘      └──────────────┘      └──────────────┘
       │
       ▼
┌──────────────┐
│    Embark    │ ───► Ejecuta acciones contextuales (C-. / C-;)
│(Menú Acciones│      sobre el candidato activo.
└──────────────┘
```

- **Vertico:** Presentación vertical fluida integrada nativamente en el minibuffer.
- **Orderless:** Coincidencias de búsqueda divididas por espacios en cualquier orden.
- **Marginalia:** Enriquecimiento de candidatos (docstrings, permisos de archivo, tamaños, fechas).
- **Embark:** Permite actuar sobre cualquier candidato (`C-.` para `embark-act`, `C-;` para `embark-dwim`).

---

## 4. Edición Modal con Evil Mode (`my-editor.el`)

- **Evil Mode:** Emulación Vim completa con estados de cursor diferenciados:
  - Normal: Bloque dorado (`goldenrod1`).
  - Visual: Bloque naranja (`orangered`).
  - Insert: Barra cian (`cyan`).
  - Replace: Barra roja (`red`).
  - Emacs: Bloque verde (`green`).
- **Extensiones Evil:** `evil-collection` (integración en todos los modos), `evil-surround` (manipulación de delimitadores), `evil-mc` (multicursor modal), `evil-tex` (movimientos y objetos de texto en LaTeX).
- **Undo/Redo Robusto:** Integración de `undo-fu` mapeado a `C-z` (deshacer) y `C-S-z` (rehacer) tanto en modo Normal como en Insert.
- **Búsqueda Horizontal Vim Rescatada:** Al usar `;` como líder global, la repetición de búsqueda horizontal de caracteres se ejecuta con `,` *(hacia adelante)* y `\` *(hacia atrás)*.
- **Corrección Ortográfica con Jinx:** `jinx-mode` global con soporte simultáneo de diccionarios en español (`es_PE`) e inglés (`en_US`). Atajo: `M-'` para corregir la palabra bajo el cursor.
- **Terminal Vterm Integrada:** `vterm-toggle` configurado con alcance por proyecto (`project`). Atajo: `; v t`.
- **Data Science con Julia:** Soporte integral para archivos `.jl` mediante `julia-mode`, `julia-repl` (enrutado a Vterm) y servidor LSP `eglot`.
```

---

# ARCHIVO: `docs/02-guia-atajos-y-navegacion.md`

```markdown
# 02. Guía Maestra de Atajos de Teclado (Cheat Sheet)

> [!NOTE]
> La **Tecla Líder** principal es **`;`** *(punto y coma)*, disponible en los estados Normal, Visual y Motion de Evil.

---

## 1. Atajos Globales y de Sistema

| Atajo | Función | Descripción |
|---|---|---|
| `; SPC` | `execute-extended-command` | Abre `M-x` con Vertico y Marginalia |
| `; s a` | `my/select-all-buffer` | Selecciona todo el buffer y pasa a Evil Visual-Line |
| `C-.` | `embark-act` | Menú contextual Embark sobre el elemento bajo cursor |
| `C-;` | `embark-dwim` | Acción predeterminada inteligente de Embark |
| `C-=` | `er/expand-region` | Expansión semántica incremental de selección |
| `M-y` | `consult-yank-pop` | Historial interactivo del portapapeles (*kill-ring*) |
| `M-'` | `jinx-correct` | Corregir ortografía en el punto |
| `C-M-'` | `jinx-languages` | Cambiar diccionarios activos de ortografía |
| `C-z` | `undo-fu-only-undo` | Deshacer |
| `C-S-z` | `undo-fu-only-redo` | Rehacer |
| `; j j` | `avy-goto-char-timer` | Salto rápido a cualquier carácter en pantalla |
| `; j l` | `avy-goto-line` | Salto rápido a línea con Avy |
| `; s s` | `consult-line` | Búsqueda interactiva de líneas en el buffer actual |

---

## 2. Inteligencia Artificial: Google Antigravity (`; a`)

| Atajo | Función | Descripción |
|---|---|---|
| `; a a` | `my/antigravity-menu` | **Menú Transient Maestro de Antigravity** |
| `; a c` | `my/antigravity-cli` | Iniciar o enfocar Terminal REPL de Antigravity (`agy`) |
| `; a C` | `my/antigravity-continue`| Reanudar la última sesión (`agy -c`) |
| `; a p` | `my/antigravity-plan` | Iniciar Antigravity en **Modo Planificación** |
| `; a q` | `my/antigravity-ask` | Consulta asíncrona con streaming en Markdown |
| `; a i` | `my/antigravity-inline-edit`| **Edición inline** con menú interactivo de Diff |
| `; a r` | `my/antigravity-refactor-region`| Refactorizar selección según prompt |
| `; a e` | `my/antigravity-explain-region` | Explicación didáctica de código o matemáticas |
| `; a E` | `my/antigravity-diagnose-terminal-error` | Diagnosticar y reparar errores en logs de Vterm |
| `; a g` | `my/antigravity-git-commit-message` | Generar commit semántico a partir de staging |
| `; a m` | `my/antigravity-switch-model` | Conmutar modelo (Gemini 3.7 Flash, Claude, etc.) |
| `; a x` | `my/antigravity-switch-effort`| Ajustar razonamiento (*effort*: low, medium, high) |
| `; a /` | `my/antigravity-send-slash-command` | Paleta de Slash Commands (`/plan`, `/goal`, etc.) |
| `; a A` | `aidermacs-transient-menu` | Menú del agente Aidermacs |

---

## 3. IA Jarvis, Agentes y Exportación de Contexto (`; A`)

| Atajo | Función | Descripción |
|---|---|---|
| `; A M` | `my/antigravity-menu` | Menú maestro de Antigravity |
| `; A l` | `my/antigravity-live-output` | Salida en tiempo real (Tail) de tareas Antigravity |
| `; A v` | `my/antigravity-live-vterm` | Terminal Vterm con `tail -f` del log activo |
| `; A a` | `aidermacs-transient-menu` | Menú interactivo de Aidermacs |
| `; A j` | `my/jarvis-chat-session` | Sesión interactiva de Chat GPTel (*JARVIS*) |
| `; A c` | `my/jarvis-oneshot-command` | Envío rápido de comandos one-shot vía GPTel |
| `; A e` | `my/export-config-as-txt` | **Exportar config (.el) a TXT** para contexto LLM |
| `; A E` | `my/export-files-by-extension` | Exportar archivos por extensión a TXT |
| `; A t` | `my/export-project-tex-as-txt`| **Exportar todos los `.tex` del proyecto a TXT** |

---

## 4. LaTeX y Redacción Editorial (`; t`)

| Atajo | Función | Descripción |
|---|---|---|
| `; t c` | `my/smart-compile` | Compilación inteligente (Incremental / Master) |
| `; t v` | `my/tex-view-with-focus` | Ver PDF en Zathura y sincronizar con SyncTeX |
| `; t z` | `my/latex-visual-mode` | Alternar **Modo Visual Zen** (TeX-Fold dinámico) |
| `; t f` | `my/ts-format-buffer` | **Formatear Buffer con Tree-sitter AST (120 cols)** |
| `; t h` | `my-latex-snippet-hydra/body`| **Hydra Visual de Snippets y Símbolos** |
| `; t l` | `my/smart-latex-label` | Insertar `\label{env:...}` contextual |
| `; t C` | `my/insert-cref` | Insertar `\cref{...}` buscando etiquetas del doc |
| `; t b` | `tesis-tools-insert-citation-advanced` | Citar avanzado (tipo, número y página) |
| `; t i` | `citar-insert-citation` | Insertar cita rápida con Citar / Zotero |
| `; t e` | `LaTeX-environment` | Insertar entorno AUCTeX |
| `; t s` | `LaTeX-section` | Insertar sección / subsección |
| `; t m` | `my/insert-matrix` | Asistente interactivo de matrices dinámicas |
| `; t o` | `consult-imenu` | Explorar índice y jerarquía del documento |
| `; t E` | `tesis-tools-edit-inkscape-pdftex` | Editar dibujo SVG en Inkscape |
| `; t A` | `my/open-apuntes-cls` | Editar clase maestra `apuntes-scr.cls` |
| `; t a` | `my/toggle-latex-auto-format-on-save` | Alternar autoformateo al guardar |
| `; t n` | `my/quick-add-snippet` | Añadir snippet Tempel en caliente |
| `; t R` | `my/reload-snippets` | Recargar archivo de snippets |
| `; t r` | `my/ts-rename-environment` | Renombrar entorno vía Tree-sitter AST |
| `; t V` | `my/ts-select-environment` | Seleccionar visualmente el entorno AST actual |
| `; t S` | `my/ts-search-environments`| Buscar y navegar entre entornos AST |
| `; t p` | `prettify-symbols-mode` | Alternar reemplazo de símbolos Unicode |
| `; t d` | `rainbow-delimiters-mode` | Alternar colores arcoíris en delimitadores |

---

## 5. Inserción y Pegado Rápido (`; i`)

| Atajo | Función | Descripción |
|---|---|---|
| `; i s` | `tempel-insert` | Insertar plantilla Tempel |
| `; i p` | `my/yank-clean` | **Pegar Limpio** (elimina saltos de línea molestos) |
| `; i f` | `cape-file` | Autocompletar ruta de archivo |
| `; i i` | `tesis-tools-insert-inkscape-pdftex` | Crear e insertar nueva figura Inkscape (`.pdf_tex`) |
| `; i m` | `tesis-tools-inkscape-math-popup` | Abrir **Math Pad Flotante para Inkscape** |

---

## 6. Archivos, Buffers y Navegación (`; f`, `; e`, `; h`, `; p`, `; g`)

| Atajo | Función | Descripción |
|---|---|---|
| `; f f` | `consult-find` | Buscar archivo en el sistema de archivos |
| `; f b` | `consult-buffer` | Conmutar buffers abiertos con vista previa |
| `; f s` | `save-buffer` | Guardar archivo actual |
| `; f e` | `my/dired-edit-directory` | **Editar directorio actual estilo Oil.nvim (WDired)** |
| `; f n` | `my/create-empty-file` | Crear nuevo archivo vacío en el directorio actual |
| `; e c` | `my/find-config-file` | Buscar y abrir archivos `.el` de la configuración |
| `; e i` | `my/open-init-file` | Abrir `init.el` directamente |
| `; e r` | `restart-emacs` | Reiniciar Emacs |
| `; e t` | `my-terminal-gui-mode` | Conmutar modo Terminal-GUI |
| `; h a` | `harpoon-add-file` | Marcar archivo actual en Harpoon |
| `; h h` | `harpoon-toggle-fileline`| Abrir menú de Harpoon |
| `; h 1`..`9`| `harpoon-go-to-1..9` | Saltar al archivo marcado 1 al 9 |
| `; p f` | `projectile-find-file` | Buscar archivo en el proyecto Projectile |
| `; p r` | `consult-ripgrep` | Búsqueda global en el proyecto con Ripgrep |
| `; p p` | `projectile-switch-project` | Cambiar de proyecto activo |
| `; p b` | `projectile-switch-to-buffer` | Buffers del proyecto activo |
| `; p k` | `projectile-kill-buffers` | Cerrar todos los buffers del proyecto |
| `; g s` | `magit-status` | Panel de control de Git con Magit |

---

## 7. Bibliografía, Citas y Zotero (`; b`)

| Atajo | Función | Descripción |
|---|---|---|
| `; b b` | `citar-open` | Abrir biblioteca bibliográfica con Citar |
| `; b n` | `citar-open-notes` | Abrir o crear nota de lectura asociada |
| `; b p` | `my/citar-preview-at-point`| Vista previa de la cita Zotero bajo cursor |
| `; b e` | `my/brain-export-local-bib` | **Exportar `.bib` local filtrado** para el proyecto |
| `; b l` | `my/insert-pdf-link` | Insertar enlace mágico a página de PDF en Zotero |
| `; b o` | `my/open-pdf-link` | Abrir PDF de Zotero en la página del enlace mágico |

---

## 8. Segundo Cerebro y Notas de Investigación (`; k`)

| Atajo | Función | Descripción |
|---|---|---|
| `; k n` | `my/brain-new-entry` | Crear nuevo apunte estructurado en subcarpeta |
| `; k s` | `my/brain-neural-search` | Búsqueda global en el cerebro con Ripgrep |
| `; k B` | `my/brain-generate-bib` | Unificar y regenerar `referencias.bib` maestro |
| `; k c` | `my/smart-compile` | Compilar documento maestro del cerebro |
| `; k C` | `my/brain-clean-and-compile`| Limpieza profunda y recompilación total |
| `; k p` | `my/brain-open-pdf` | Abrir PDF maestro del Segundo Cerebro |
| `; k G` | `my/brain-generate-graph` | Generar mapa visual Graphviz del cerebro |
| `; k d` | `my/journal-today` | Abrir/crear diario de investigación de hoy |

---

## 9. Sincronización en la Nube / Google Drive (`; d`, `; dy`)

| Atajo | Función | Descripción |
|---|---|---|
| `; d d` | `gdrive-sync-transient/body` | **Menú Transient de Google Drive (Rclone)** |
| `; d b` | `gdrive-sync/bisync-now` | Sincronización bidireccional inmediata (`bisync`) |
| `; d s` | `gdrive-sync/sync-local-to-remote` | Sincronizar carpeta Local $\rightarrow$ Remoto |
| `; d S` | `gdrive-sync/sync-remote-to-local` | Sincronizar carpeta Remoto $\rightarrow$ Local |
| `; d f` | `gdrive-sync/upload-current-file` | Subir archivo actual al almacenamiento remoto |
| `; d F` | `gdrive-sync/download-remote-file` | Descargar archivo específico desde remoto |
| `; d u` | `gdrive-sync/upload-modified` | Subir únicamente modificados en la sesión |
| `; d m` | `gdrive-sync/mount-remote` | Montar Google Drive como FUSE local |
| `; d M` | `gdrive-sync/unmount-remote` | Desmontar Google Drive FUSE |
| `; d n` | `gdrive-sync/browse-remote` | Explorar Drive en Dired vía TRAMP |
| `; d i` | `gdrive-sync/navigate-remote` | Explorador interactivo paso a paso |
| `; d c` | `gdrive-sync/resolve-conflicts` | **Resolver conflictos de sincronización con Ediff** |
| `; d r` | `gdrive-sync/bisync-resync-global` | Forzar inicialización de base de datos (`--resync`)|
| `; d l` | `gdrive-sync/force-unlock` | Eliminar archivos de bloqueo huérfanos (`.lck`) |
| `; d R` | `gdrive-sync/refresh-folder-cache`| Actualizar caché persistente de carpetas |
| `; dy t`| `syncclient-transient-prefix` | **Menú Transient de SyncClient** |
| `; dy S`| `syncclient-status` | Ver panel interactivo de SyncClient |
| `; dy f`| `syncclient-force-sync-current` | Forzar sincronización del par seleccionado |
| `; dy c`| `syncclient-clean-duplicates-current`| Limpieza de duplicados en SyncClient |
| `; dy a`| `syncclient-add-pair` | Agregar nuevo par local/remoto |

---

## 10. Ventanas, Terminal y Agenda (`; w`, `; v`, `; o`)

| Atajo | Función | Descripción |
|---|---|---|
| `; w w` | `ace-window` | Selección visual de ventana para salto rápido |
| `; w o` | `other-frame` | Saltar al siguiente frame de Emacs |
| `; w d` | `delete-window` | Cerrar ventana activa |
| `; w l` | `tesis-layout-activate` | Activar layout dividido de tesis |
| `; w p` | `tesis/layout-writer` | Disposición: Editor de código + PDF en Zathura |
| `; w r` | `tesis/layout-researcher` | Disposición: Editor de código + Biblioteca Citar |
| `; v t` | `my/toggle-term` | Desplegar/ocultar terminal Vterm inferior |
| `; v n` | `my/vterm-new` | Abrir nueva pestaña independiente de terminal |
| `; v k` | `vterm-module-compile` | Recompilar módulo C nativo de Vterm |
| `; o a` | `org-agenda` | Panel de Agenda semanal |
| `; o c` | `org-capture` | Captura rápida de tareas/ideas |
| `; o k` | `my/open-calendar` | Calendario gráfico interactivo (`calfw`) |
| `; o t` | `find-file vida.org` | Abrir agenda maestra de planificación |
| `; o i` | `my/org-process-mobile-inbox` | Importar notas capturadas desde el móvil |
```

---

# ARCHIVO: `docs/03-ecosistema-latex-e-ihes.md`

```markdown
# 03. Ecosistema LaTeX, Tree-Sitter y Clases Maestras

Este documento detalla el motor de edición matemática de alta velocidad, las optimizaciones de formateo AST con Tree-sitter, el sistema de saltos estructurales, las expansiones automáticas y la arquitectura editorial de las clases maestras `apuntes-scr.cls` y `tesis-uni.cls`.

---

## 1. Formateo Semántico y Tree-Sitter AST (`my-latex-tree-sitter.el`)

El comando maestro **`; t f`** (`my/ts-format-buffer`) ejecuta un formateo semántico integral y re-envoltura de prosa a 120 columnas sin alterar el código matemático:

```text
Código .tex crudo
       │
       ▼
┌─────────────────────────────────────────┐
│ 1. Aislamiento Vertical Semántico       │
│    - Unifica \begin{...}\label{}\index{}│
│    - Aísla \item, \propitem y pasos EGA │
│    - Separa \[ ... \] de texto continuo │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│ 2. Indentación y Re-Envoltura (120 col) │
│    - Stack jerárquico auto-reparable    │
│    - Re-envuelve solo prosa fuera de math│
│    - Preserva entornos align*, cases,   │
│      matrices y tikzcd intactos         │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│ 3. Alineación Columnar y Limpieza       │
│    - Alinea '&' en entornos matriciales │
│    - Elimina trailing whitespace y tabs │
│    - Restaura cursor y scroll exacto    │
└─────────────────────────────────────────┘
```

### Características Principales:
1. **Preservación Total del Cursor:** Guarda la línea, columna y posición de visualización (`window-start`), retornando al punto exacto tras el formateo.
2. **Normalización de Cabeceras:** Coloca en una sola línea canónica la apertura del entorno, su argumento opcional, su etiqueta `\label{...}` y su entrada de índice `\index{...}`.
3. **Aislamiento de Display Math:** Limpia líneas en blanco espurias antes de `\[` para evitar que LaTeX genere párrafos vacíos (`\par`).
4. **Herramientas AST Interactivas:**
   - `; t r` (`my/ts-rename-environment`): Renombra simultáneamente `\begin{env}` y `\end{env}` usando el parser AST.
   - `; t V` (`my/ts-select-environment`): Selecciona visualmente el entorno completo.
   - `; t S` (`my/ts-search-environments`): Menú interactivo con Vertico para saltar a cualquier entorno del documento.

---

## 2. Expansiones, Autocompletado y Súper Salto `TAB` (`my-latex-expansions.el`)

### 2.1 Gestores Maestros de `TAB` y `Shift+TAB`
El motor unifica Tempel y la navegación estructural en una sola tecla:
- **`TAB` (`my/ide-tab-handler`):**
  1. Si hay un snippet de Tempel activo, avanza al siguiente campo (`tempel-next`).
  2. Si hay un prefijo de snippet válido (fuera de etiquetas `\label`, `\cite`, `\ref`), lo expande.
  3. **Súper Salto Estructural Forward:** Salta automáticamente fuera de "puertas" estructurales: `{}`, `()`, `[]`, `\left...\right`, `\[...\]`, `\begin...\end`, `&`, `\\`, saltando también la puntuación adherida (`.,;:`).
  4. Si no aplica nada, inserta 4 espacios.
- **`Shift+TAB` (`my/ide-backtab-handler`):** Salto estructural inverso simétrico hacia atrás.

### 2.2 Autocompletado de Rutas Recursivo (`my/latex-path-capf`)
Al escribir comandos como `\input{`, `\include{`, `\includegraphics{` o `\addbibresource{`, Corfu despliega un menú interactivo que permite navegar por el árbol de directorios infinitamente. Al presionar `Enter` sobre una carpeta, continúa navegando en su interior; al seleccionar un archivo, remueve la extensión automáticamente si corresponde.

---

## 3. Visual Zen Mode y Line Focus (`my-latex-visuals.el`)

Activado mediante **`; t z`** (`my/latex-visual-mode`), transforma el buffer en una visualización limpia estilo manuscrito matemático:
- **Line Focus Simétrico:** La línea donde se ubica el cursor se despliega automáticamente en código LaTeX crudo para edición directa; al cambiar de línea, la anterior se vuelve a plegar (`TeX-fold`) instantáneamente sin parpadeos.
- **Plegado Semántico Elegante:**
  - `\section{...}` $\rightarrow$ `§ Título` (con fuente aumentada y color unificado).
  - `\begin{theorem}[Hilbert]` $\rightarrow$ `--- Teorema [Hilbert] ---`.
  - `\item` $\rightarrow$ `➣`.
  - `\directstep`, `\reversestep`, `\containedstep` $\rightarrow$ `(⇒)`, `(⇐)`, `(⊆)`.
  - `\TODO{...}`, `\FIXME{...}` $\rightarrow$ Cajas distintivas con fondo en color.
  - Macros matemáticas como `\norm{x}` $\rightarrow$ `‖ x ‖`, `\inner{x}{y}` $\rightarrow$ `〈 x , y 〉`.
- **Prettify Symbols Dictionary:** Diccionario completo Unicode que reemplaza visualmente `\alpha`, `\mathbb{R}`, `\symcal{O}`, `\otimes`, `\implies`, etc.
- **Atenuación de Delimitadores:** Los delimitadores `\(`, `\)`, `\[`, `\]` se colorean en un gris discreto (`my-latex-math-bracket-face`) para no sobrecargar la lectura.

---

## 4. Snippets Matemáticos y Geometría Compleja

### 4.1 Snippets Universales (LAAS / AAS)
En modo matemático, las siguientes combinaciones se expanden de forma instantánea sin pulsar TAB:

| Trigger | Salida LaTeX | Descripción |
|---|---|---|
| `mk` | `\( ... \)` | Ecuación matemática inline |
| `dm` | `\[ ... \]` | Ecuación display |
| `//` | `\frac{...}{...}` | Fracción interactiva |
| `=>` / `=<` | `\implies` / `\impliedby` | Implicación lógica |
| `iff` | `\iff` | Si y solo si |
| `ox` / `op` | `\otimes` / `\oplus` | Producto tensorial / suma directa |
| `inn` / `nin`| `\in` / `\not\in` | Pertenencia / no pertenencia |
| `!=` / `>=` / `<=` | `\neq` / `\geq` / `\leq` | Desigualdades |
| `CC`, `RR`, `NN`, `ZZ`, `QQ` | `\C`, `\R`, `\N`, `\Z`, `\Q` | Conjuntos numéricos |
| `;a`, `;b`, `;g`, `;d`, `;e`, `;w` | `\alpha`, `\beta`, `\gamma`, `\delta`, `\epsilon`, `\omega` | Alfabeto griego directo |
| `'b`, `'i`, `'e`, `'r` | `\symbf{...}`, `\symit{...}`, `\symem{...}`, `\symrm{...}` | Fuentes matemáticas |
| `Tr`, `inv`, `ort` | `^{\top}`, `^{-1}`, `^{\perp}` | Superíndices rápidos |

### 4.2 Snippets Especializados de Geometría Compleja (`tesis-snippets.el`)
Activos condicionalmente en proyectos de tesis:

| Trigger | Salida LaTeX | Concepto Matemático |
|---|---|---|
| `ac` | `\symcal{A}^{p,q}` | Espacio de $(p,q)$-formas diferenciales |
| `acf` | `\symcal{A}^{\bullet}_{\Complex}` | Álgebra de formas complejas |
| `t10` / `t01` | `T^{1,0}M` / `T^{0,1}M` | Fibrado tangente holomorfo / antiholomorfo |
| `dolb` | `H_{\overline{\partial}}^{p,q}(X)` | Cohomología de Dolbeault |
| `kahm` | `\omega = \frac{i}{2} \sum h_{i\overline{j}} dz^i \wedge d\bar{z}^j` | Métrica de Kähler en coordenadas |
| `kahpot`| `\omega = i \partial \overline{\partial} \phi` | Potencial local de Kähler |
| `ric` | `\operatorname{Ric}(\omega)` | Curvatura de Ricci |
| `lef` / `lefs` | `L(\alpha)` / `\Lambda` | Operador de Lefschetz y su adjunto dual |
| `lald` | `\Delta_{\overline{\partial}}` | Laplaciano de Dolbeault |
| `canb` | `K_X` / `\omega_X` | Fibrado / Haz Canónico |
| `serre` | `H^{p,q}(X) \cong H^{n-p,n-q}(X)^*` | Dualidad de Serre |
| `cy` | `c_1(X) = 0` | Variedad de Calabi-Yau |

---

## 5. Clases Maestras de Documentos

### 5.1 `apuntes-scr.cls` (v6.5 - Bourbaki Edition)
Clase modular construida sobre KOMA-Script (`scrartcl` / `scrbook`) con soporte multilingüe automático (`spanish`, `english`, `french`, `german`) y tipografía **STIX Two Text & Math**:
- **Ecosistema EGA / Bourbaki:** Párrafos numerados `\numpar[(1.1.1)]`, marcas de atención `\viragedangereux` (⚠️), separadores `\egabreak` (`* * *`), listas `egalist` ($a), b), c)$) y equivalencias `tfae` ($(i), (ii), (iii)$).
- **Suite de Demostraciones:** Entorno `proof` con filete lateral, pasos formales `\directstep`, `\reversestep`, `\containedstep`, subcasos con `proofcases` y afirmaciones subordinadas `claim` con remate `claimproof`.
- **Referencias Inteligentes (Suite `\sref`):**
  - `\sref{label}` $\rightarrow$ $(1.1.1)$
  - `\csref{label}` $\rightarrow$ Teorema $(1.1.1)$
  - `\namedsref{label}{Nombre}` $\rightarrow$ Teorema $(1.1.1)$ *(Nombre)*
  - `\titref{label}{Título}` $\rightarrow$ Título $(1.1.1)$
  - `\srefname{label}{Nombre}` $\rightarrow$ $(1.1.1, Nombre)$
- **Suite de Haces y Gavillas:** Macros con kerning editorial fino: `\shHom`, `\shExt`, `\shTor`, `\shDer`, `\shEnd`, `\shAut`, gavillas `\Ox`, `\Fsh`, `\Gsh`, `\Ish`.
- **Categorías Bourbaki:** Renderizadas estrictamente en negrita recta `\symbfup`: `\Set`, `\Sch`, `\QCoh`, `\Coh`, `\Ab`, `\CRing`, `\Mod`, `\Top`, `\Grp`, `\Vect`.
- **Bloques de Código Python:** Entornos Minted `pythonlib`, `pythoncode` y `pythonexec` (ejecuta el script vía `write18` y muestra el `stdout` en una caja adyacente).
- **Optimización y Cálculo:** Paquete `optidef` traducido con macros `\optmin`, `\optmax`, `\optst` y constructores formales de funciones `\Fobj`.

### 5.2 `tesis-uni.cls` (v22.0 - Pure IHÉS EGA Architecture)
Clase institucional para tesis de grado y posgrado en Matemática, con tipografía **TeX Gyre Termes / Heros / Cursor**:
- **Formato Visual Canónico:** Teoremas y definiciones con numeración unificada por sección `(1.1.1) Teorema. —`, ecuaciones subordinadas `(1.1.1.1)`.
- **Páginas Institucionales:** Generador automático de carátula oficial UNI (`\makeportada`), fichas bibliográficas IEEE / APA (`\makecitacion`), dedicatoria, agradecimientos y legajo.
- **Sumario de Capítulos:** Macro `\chaptersummary` que genera un sumario local de secciones con puntos conductores y estilo tipográfico IHÉS al inicio de cada capítulo.
```

---

# ARCHIVO: `docs/04-ia-google-antigravity.md`

```markdown
# 04. Inteligencia Artificial: Google Antigravity & Jarvis

El módulo `my-ai.el` implementa una integración total del motor de inteligencia artificial agéntica de **Google Antigravity (`agy`)** en Emacs, complementado con GPTel (Gemini) y Aidermacs.

---

## 1. Arquitectura del Agente Antigravity en Emacs

```text
                           ┌─────────────────────────────────────┐
                           │   🛸 Google Antigravity (agy CLI)   │
                           │   Modelos: Gemini 3.7 / Claude 4.6  │
                           └──────────────────┬──────────────────┘
                                              │
         ┌──────────────────┬─────────────────┴─────────────────┬──────────────────┐
         │                  │                                   │                  │
┌────────▼─────────┐ ┌──────▼──────────┐              ┌─────────▼────────┐ ┌───────▼──────────┐
│ Sesión REPL Vterm│ │ Edición Inline  │              │ Streaming Asínc. │ │ Herramientas     │
│   (Interactivo)  │ │ (Diff Preview)  │              │ (Buffer Markdown)│ │ Especializadas   │
│     `; a c`      │ │     `; a i`     │              │     `; a q`      │ │ (LaTeX / TikZ /  │
│  - Modo Plan     │ │ - Aceptar [a]   │              │ - Copiar [y]     │ │  Diagnósticos)   │
│  - Slash Cmds    │ │ - Ver Diff [d]  │              │ - Insertar [i]   │ │  - Fix Ecuaciones│
│  - Mención @file │ │ - Cancelar [c]  │              │ - Cerrar [q]     │ │  - Diagnosticar  │
└──────────────────┘ └─────────────────┘              └──────────────────┘ └──────────────────┘
```

---

## 2. Modalidades de Trabajo

### 2.1 Terminal Agente Interactivo REPL (Vterm)
- **Lanzamiento:** `; a c` (`my/antigravity-cli`) abre un buffer `*Antigravity-CLI*` en la raíz del proyecto actual (`projectile-project-root`).
- **Reanudar Sesión:** `; a C` (`my/antigravity-continue`) invoca `agy -c` para continuar la conversación previa sin perder el contexto.
- **Modo Plan:** `; a p` (`my/antigravity-plan`) inicia Antigravity con `--mode plan` para desglosar arquitecturas y tareas complejas antes de modificar archivos.
- **Slash Commands Interactivas:** `; a /` despliega un menú interactivo con Vertico:
  - `/plan`: Modo de planificación interactivo.
  - `/goal`: Ejecución continua orientada a objetivos sin detenerse.
  - `/schedule`: Programación de tareas temporizadas.
  - `/learn`: Persistencia de reglas o aprendizajes en el proyecto.
  - `/grill-me`: Entrevista interactiva para auditar el diseño antes de implementar.
  - `/clear`: Limpiar el contexto de la conversación.

### 2.2 Edición Inline Dirigida (`my/antigravity-inline-edit` / `; a i`)
Permite seleccionar una región de código o LaTeX y enviarla junto a una instrucción:
1. Antigravity procesa los cambios de forma asíncrona.
2. Al recibir la respuesta, Emacs presenta un diálogo interactivo en el eco-área:
   - Presiona **`a`**: Aplica los cambios directamente reemplazando la región.
   - Presiona **`d`**: Abre un buffer `*Antigravity-Diff*` en `diff-mode` para inspeccionar las diferencias antes de aplicar.
   - Presiona **`c`**: Cancela la operación sin alterar el buffer.

### 2.3 Consultas Asíncronas en Streaming (`my/antigravity-ask` / `; a q`)
Ejecuta `agy --print` en segundo plano sin congelar la interfaz de Emacs:
- Muestra la respuesta en tiempo real dentro del buffer `*Antigravity-Response*` en `markdown-mode`.
- **Atajos directos en el buffer de respuesta:**
  - `y`: Copia la respuesta completa al portapapeles.
  - `i`: Inserta la respuesta en el buffer y posición de origen donde estabas trabajando.
  - `c`: Salta a la terminal CLI de Antigravity.
  - `q`: Cierra la ventana de respuesta.

---

## 3. Diagnóstico y Auto-Reparación de Errores

- **Diagnóstico de Terminal (`my/antigravity-diagnose-terminal-error` / `; a E`):** Captura los últimos 3500 caracteres del buffer `*vterm*` activo, analiza la causa raíz del fallo y sugiere los comandos de terminal o código para solucionarlo.
- **Diagnóstico de Compilación (`my/antigravity-diagnose-compilation-error` / `; a a` $\rightarrow$ `B`):** Captura la salida de compilación de AUCTeX (`*compilation*` o `*TeX Help*`), localiza el error en el documento LaTeX y genera el parche correctivo.

---

## 4. Herramientas Especializadas para LaTeX y Matemáticas

Accesibles desde el menú transient maestro (`; a a`):
- **Corregir Ecuación / Align (`my/antigravity-latex-fix-formula` / `; a a` $\rightarrow$ `F`):** Corrige la sintaxis de entornos `amsmath`, ajusta alineaciones con `&` y repara delimitadores desbalanceados.
- **Explicar Fórmula o Teorema (`my/antigravity-latex-explain` / `; a a` $\rightarrow$ `X`):** Genera una explicación matemática rigurosa del fragmento LaTeX seleccionado.
- **Generar Diagrama TikZ (`my/antigravity-latex-generate-tikz` / `; a a` $\rightarrow$ `Z`):** Convierte una descripción en lenguaje natural en código TikZ / PGFPlots autocontenido y listo para compilar.
- **Asistente de Demostración (`my/antigravity-latex-proof-assist` / `; a a` $\rightarrow$ `P`):** Sugiere lemas intermedios, estructura de casos y pasos lógicos para completar una prueba matemática.

---

## 5. Menú Transient Maestro (`my/antigravity-menu` / `; a a`)

```text
🛸 Google Antigravity | Modelo: gemini-3.7-flash | Effort: high | Permisos: Ask | Sandbox: OFF
╭─────────────────────────────────╮ ╭────────────────────────────────╮
│ 💬 Sesiones Agente (CLI)        │ │ ⚡ Acciones de Código          │
│ [c] Terminal Interactiva (vterm)│ │ [q] Preguntar / Consultar      │
│ [C] Reanudar Sesión (-c)        │ │ [i] Edición Inline (Diff)      │
│ [p] Modo Planificación (plan)   │ │ [e] Explicar Selección         │
│ [A] Modo Auto-Edición           │ │ [r] Refactorizar Región        │
│ [n] Nueva Sesión Limpia         │ │ [d] Generar Docstring          │
│ [/] Slash Commands...           │ │ [t] Generar Pruebas Unitarias  │
╰─────────────────────────────────╯ ╰────────────────────────────────╯
╭─────────────────────────────────╮ ╭────────────────────────────────╮
│ 🛠️ Diagnóstico & Logs           │ │ 🎓 LaTeX & Matemáticas         │
│ [L] Salida en Vivo (Tail)       │ │ [F] Corregir Ecuación / Align  │
│ [T] Terminal vterm en Vivo      │ │ [X] Explicar Fórmula / Teorema │
│ [E] Diagnosticar Terminal vterm │ │ [Z] Generar Diagrama TikZ      │
│ [B] Diagnosticar Compilación    │ │ [P] Asistente de Demostración  │
│ [G] Generar Commit Git          │ ╰────────────────────────────────╯
│ [V] Revisar Cambios Git Diff    │ ╭────────────────────────────────╮
│ [D] Enviar Marcados de Dired    │ │ ⚙️ Ajustes & Reglas            │
╰─────────────────────────────────╯ │ [m] Cambiar Modelo             │
                                    │ [x] Nivel Razonamiento (effort)│
                                    │ [!] Alternar Auto-Aprobación   │
                                    │ [b] Alternar Sandbox           │
                                    │ [k] Abrir Reglas (.agents/rules│
                                    │ [K] Abrir Skills (.agents/skill│
                                    ╰────────────────────────────────╯
```

---

## 6. Monitoreo de Tareas y Logs en Vivo

- **Salida de Terminal en Tiempo Real (`my/antigravity-live-output` / `; A l`):** Abre una ventana inferior dedicada que realiza un seguimiento reactivo (`auto-revert-tail-mode`) del archivo de registro `.log` generado por las tareas autónomas de Antigravity en `~/.gemini/antigravity-ide/brain/`.
- **Terminal Vterm con Seguimiento (`my/antigravity-live-vterm` / `; A v`):** Lanza un buffer Vterm ejecutando `tail -f` sobre la última tarea en ejecución.
```

---

# ARCHIVO: `docs/05-segundo-cerebro-y-zotero.md`

```markdown
# 05. Segundo Cerebro, Bibliografía y Zotero

El módulo `my-second-brain.el` implementa una arquitectura integral de gestión del conocimiento matemático y bibliográfico estructurada sobre carpetas jerárquicas, referencias unificadas con BibTool y vinculación con Zotero vía Citar.

---

## 1. Arquitectura del Segundo Cerebro

El sistema reside en `~/Documentos/Segundo-Cerebro/` y organiza las notas de investigación de la siguiente manera:

```text
Segundo-Cerebro/
├── main.tex                    # Documento maestro compilable con LuaLaTeX
├── imports.tex                 # Generado automáticamente por my/brain-generate-imports
├── referencias.bib             # Bibliografía global unificada generada por BibTool
├── 00-Diario/                  # Bitácora personal y notas diarias (Año/Mes/Dia.tex)
├── 01-Geometria-Algebraica/    # Carpetas de categorías temáticas
│   ├── Variedades-Toricas/
│   │   ├── main.tex
│   │   └── referencias.bib
│   └── Esquemas-EGA/
│       └── Esquemas-EGA.tex
├── 02-Analisis-Complejo/
└── ...
```

---

## 2. Gestión Bibliográfica con Zotero y Citar

### 2.1 Configuración de Biblioteca Global
- **Archivo Maestro:** `~/Documentos/Segundo-Cerebro/referencias.bib`.
- **Almacenamiento de PDFs:** `~/Zotero/storage/` y `~/Documentos/Books/`.
- **Notas de Tesis:** `~/Documentos/Notas_Tesis/`.
- **Exploración Rápida:** `; b b` (`citar-open`) permite buscar referencias con autocompletado en Vertico, ver metadatos y abrir el PDF correspondiente en Zathura.

### 2.2 Enlaces Mágicos a PDFs (`my/insert-pdf-link` y `my/open-pdf-link`)
Permite insertar comentarios en el código LaTeX que apuntan directamente a una página específica del PDF de Zotero:
1. Ejecuta `; b l` e ingresa el número de página.
2. Se inserta la línea: `% PDF: /ruta/al/archivo/en/zotero.pdf::45`.
3. Al situar el cursor sobre esta línea y presionar `; b o`, Zathura abre instantáneamente el documento en la página 45.

### 2.3 Exportación de Bibliografía Local para Proyectos (`my/brain-export-local-bib`)
Al trabajar en un artículo o capítulo aislado, el comando **`; b e`** escanea todas las citas `\cite{...}`, `\cref{...}` y `\ref{...}` del buffer actual, busca sus entradas completas en el `referencias.bib` maestro del Segundo Cerebro y genera un `referencias.bib` local y limpio en el directorio del proyecto, eliminando dependencias externas.

---

## 3. Diario y Bitácora Automatizada (`my/journal-today` / `; k d`)

Al pulsar `; k d`:
1. Determina la fecha actual (ej. `2026/09/01`).
2. Crea la estructura de carpetas `00-Diario/2026/09/` si no existe.
3. Genera el archivo del día `2026-09-01.tex` con la cabecera:
   ```latex
   \section*{Martes, 01 de Septiembre de 2026}
   \label{day:2026-09-01}
   ```
4. Registra automáticamente el `\input{2026/09/2026-09-01.tex}` en `Bitácora-Personal.tex` antes de `\end{document}`.
5. Coloca el cursor en el final del buffer en modo Inserción de Evil.

---

## 4. Motor de Compilación y Reconstrucción

### 4.1 Generador Dinámico de Estructura (`my/brain-generate-imports`)
Escanea todas las carpetas que inician con números (ej. `01-`, `02-`), clasifica sus documentos `.tex` como partes del libro maestro y genera `imports.tex` traduciendo nombres de archivo a títulos elegantes mediante el diccionario `my/brain-pretty-names`.

### 4.2 Unificación Bibliográfica con BibTool (`my/brain-generate-bib` / `; k B`)
- Si `bibtool` está instalado en el sistema, ejecuta un proceso nativo en C que indexa y elimina duplicados de todos los archivos `.bib` del cerebro en menos de 0.1 segundos.
- Si no está instalado, ejecuta un motor de respaldo en Emacs Lisp.

### 4.3 Pipeline de Compilación Inteligente (`; k c` y `; k C`)
- **Compilación Incremental (`; k c` / `my/smart-compile`):** Si estás en un subarchivo, compila solo el contenido editado de forma rápida. Si estás en un archivo maestro, ejecuta la reconstrucción completa.
- **Compilación Profunda (`; k C` / `my/brain-clean-and-compile`):** Ejecuta `latexmk -C` para purgar archivos temporales (`.aux`, `.bbl`, `.bcf`, `_region_.tex`), regenera `referencias.bib` e `imports.tex`, y compila asíncronamente con LuaLaTeX (`latexmk -pdflua -shell-escape`). Al terminar con éxito, realiza un backup automático en Git (`my/brain-git-backup`).

---

## 5. Visualización del Grafo de Conocimiento (`my/brain-generate-graph` / `; k G`)

Escanea todas las conexiones `\input{...}` e `\import{...}` entre las notas del Segundo Cerebro, genera un archivo DOT de Graphviz y renderiza un diagrama de red en PNG/PDF (`brain_map.png`) abriéndolo automáticamente en Zathura para visualizar la topología de tus notas.
```

---

# ARCHIVO: `docs/06-inkscape-y-sincronizacion.md`

```markdown
# 06. Dibujo Vectorial (Inkscape Math Pad) y Sincronización en la Nube

Este documento detalla el puente de dibujo matemático en tiempo real entre Emacs, GNOME Wayland e Inkscape, así como el motor de sincronización bidireccional en la nube con Google Drive y Rclone.

---

## 1. Integración Gráfica Inkscape $\rightarrow$ LaTeX (`.pdf_tex`)

El flujo permite incluir dibujos vectoriales con texto y fórmulas renderizados nativamente por LaTeX con la misma tipografía y tamaño del documento principal.

```text
        Emacs ('; i i')
               │
       Crea figura.svg
               │
               ▼
       Abre GUI Inkscape ──(Atajos Castel: w, a, c, f, s, o)
               │
               │  [<Alt>m / '; i m']
               ▼
       ┌──────────────────────────────┐
       │  Inkscape Math Pad (Emacs)   │
       │  Escribe fórmula en LaTeX    │
       │  [Enter / ZZ]                │
       └──────────────┬───────────────┘
                      │
       Copia al portapapeles y simula
       Ctrl+V en Inkscape vía /dev/uinput
                      │
       Cierra Inkscape
                      │
                      ▼
       Exporta figura.pdf + figura.pdf_tex
       Inserta \incfig{figura} en el buffer
```

### 1.1 Inserción y Edición de Figuras
- **Crear Nueva Figura (`; i i` / `tesis-tools-insert-inkscape-pdftex`):**
  1. Solicita el nombre de la figura (ej. `fibrado-tangente`).
  2. Crea la plantilla SVG con dimensiones estándar (75mm $\times$ 45mm) en `./figuras/`.
  3. Lanza Inkscape y añade el bloque LaTeX en Emacs:
     ```latex
     \begin{figure}[htpb]
       \centering
       \incfig{fibrado-tangente}
       \caption{fibrado-tangente}
       \label{fig:fibrado-tangente}
     \end{figure}
     ```
  4. Al guardar y cerrar Inkscape, un sentinel asíncrono ejecuta `inkscape --export-area-drawing --export-filename=figura.pdf --export-latex figura.svg` para generar el archivo `.pdf_tex`.
- **Editar Figura Existente (`; t E` / `tesis-tools-edit-inkscape-pdftex`):** Al situar el cursor sobre `\incfig{figura}` y pulsar `; t E`, localiza el SVG correspondiente, abre Inkscape y re-exporta automáticamente al cerrar.

---

## 2. Math Pad Flotante para Wayland (`tesis-tools-open-math-pad`)

Ventana modal ultra-rápida para insertar fórmulas en Inkscape sin lidiar con diálogos lentos:
1. En Inkscape, presiona `<Alt>m` (o `; i m` en Emacs).
2. Se abre un marco flotante centrado de Emacs con el buffer `*Inkscape Math Pad*` en `LaTeX-mode` con Corfu y snippets activos.
3. Escribe la fórmula matemática (ej. `\symcal{F} \otimes_{\Ox} \symcal{G}`).
4. Presiona **`Enter`**, **`C-c C-c`** o **`ZZ`** en modo normal de Evil:
   - Copia el texto al portapapeles de Wayland.
   - Invoca el script `wayland-paste` que interactúa con `/dev/uinput` para emitir la señal física de pegado (`Ctrl+V`) en la ventana activa de Inkscape.
   - Destruye el marco flotante al instante sin dejar buffers residuales.

---

## 3. Sincronización con Google Drive (`gdrive-sync.el`)

Implementa un cliente de sincronización robusto basado en `rclone`, con persistencia multisessión y resolución interactiva de conflictos.

### 3.1 Menú Transient Maestro (`; d d`)

```text
☁️  Google Drive Sync  |  Remote: GoogleDrive-Documentos_Ubuntu_Fayfer  |  Local: ~/Documentos/
╭────────────────────────────────────────╮ ╭────────────────────────────────────────╮
│ 📁 Navegación & Exploración            │ │ 🔄 Bidireccional (Global)              │
│ [n] Navegar Google Drive (Dired TRAMP) │ │ [b] Sincronizar Todo (bisync)          │
│ [i] Explorador Interactivo             │ │ [u] Subir Editados en Sesión           │
│ [m] Montar Google Drive (FUSE)         │ ╰────────────────────────────────────────╯
│ [M] Desmontar Google Drive             │ ╭────────────────────────────────────────╮
╰────────────────────────────────────────╯ │ 📤 Local ➔ Remoto                      │
╭────────────────────────────────────────╮ │ [s] Carpeta Local ➔ Remoto             │
│ 📥 Remoto ➔ Local                      │ │ [f] Subir Archivo Actual               │
│ [d] Carpeta Remota ➔ Local             │ ╰────────────────────────────────────────╯
│ [D] Descargar Archivo Remoto           │ ╭────────────────────────────────────────╮
╰────────────────────────────────────────╯ │ 🛠️  Mantenimiento y Diagnóstico        │
╭────────────────────────────────────────╮ │ [r] Forzar Resincronización (--resync) │
│ ⚡ Conflictos & Caché                  │ │ [l] Eliminar Candados (.lck)           │
│ [c] Resolver Conflictos (Ediff)        │ │ [R] Refrescar Caché de Carpetas        │
╰────────────────────────────────────────╯ ╰────────────────────────────────────────╯
```

### 3.2 Modalidades Operativas
1. **Sincronización Bidireccional (`bisync` / `; d b`):** Ejecuta `rclone bisync` con control de duplicados, flags de rendimiento (`--fast-list`, `--transfers 8`, `--checkers 16`) y archivo de filtros (`~/.config/rclone/rclone-filters.txt`).
2. **Subida de Editados en Sesión (`; d u`):** Gracias a `after-save-hook`, Emacs rastrea los archivos guardados en la sesión y permite subirlos en lote sin necesidad de sincronizar todo el árbol.
3. **Montaje FUSE (`rclone mount` / `; d m`):** Monta el remote de Google Drive en `~/GoogleDrive/` con cache VFS completo (`--vfs-cache-mode full`) y abre Dired inmediatamente.
4. **Resolución de Conflictos con Ediff (`; d c`):** Busca recursivamente archivos marcados como `.conflict` generados por colisiones en la nube y abre una sesión de `ediff-files` para fusionar los cambios visualmente.
5. **Estrategia al Salir de Emacs (`kill-emacs-hook`):** Si hay archivos editados pendientes al cerrar Emacs, `gdrive-sync/on-exit-strategy` pregunta interactivamente si se desea sincronizar antes de terminar o lanza un proceso desacoplado en segundo plano.

---

## 4. Monitor SyncClient (`syncclient.el`)

Módulo complementario para interactuar con el demonio local de sincronización continua:
- **Panel Interactivo (`; dy S`):** Tabla interactiva (`tabulated-list-mode`) que muestra el estado de los pares de sincronización (ID, Estado, Motor, Rutas locales y remotas).
- **Acciones Rápidas:**
  - `s` o `; dy f`: Forzar sincronización del par seleccionado.
  - `d` o `; dy c`: Limpiar duplicados del par.
  - `; dy a`: Agregar nuevo par de sincronización local/remoto interactivamente.
  - `; dy i`: Muestra la actividad actual del demonio en el eco-área.
```

---

### Resumen de Mejoras Realizadas en la Documentación

1. **Sincronización Total con el Código Fuente:** Se corrigieron todas las discrepancias de nombres de funciones, variables de configuración y atajos de teclado existentes en los archivos `.el` (como la suite `my-keys.el`, el motor de formateo `my-latex-tree-sitter.el` a 120 columnas y el gestor de Antigravity `my-ai.el`).
2. **Estructura Modular Limpia:** Se separó la documentación en 6 guías monográficas temáticas dentro de `docs/` más un `README.md` maestro de entrada.
3. **Profundidad Técnica:** Se detallaron los diagramas de flujo de datos (Tree-sitter, Antigravity, Math Pad y Segundo Cerebro), el funcionamiento interno del Súper Salto `TAB` y la arquitectura editorial de las clases `apuntes-scr.cls` y `tesis-uni.cls`.
