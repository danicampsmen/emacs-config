# 🌌 Emacs Configuration: Mathematical Research IDE & Second Brain

Configuración modular avanzada de **GNU Emacs (v30+)** diseñada como una estación de trabajo integral para la **investigación matemática avanzada, redacción editorial de tesis (Arquitectura IHÉS / EGA Bourbaki), apuntes académicos, gestión bibliográfica con Zotero y sincronización en la nube**.

---

## 📑 Tabla de Contenidos

1. [Arquitectura y Estructura del Sistema](#-arquitectura-y-estructura-del-sistema)
2. [Pila Tecnológica y Paquetes](#-pila-tecnológica-y-paquetes)
3. [Guía de Atajos de Teclado (Cheat Sheet)](#-guía-de-atajos-de-teclado-cheat-sheet)
   - [Líder y Atajos Globales](#atajos-globales-y-navegación)
   - [LaTeX y Redacción Científica (`; t`)](#latex-y-redacción-científica--t)
   - [Archivos, Buffers y Ventanas (`; f`, `; w`, `; e`)](#archivos-buffers-y-ventanas)
   - [Harpoon y Proyectos (`; h`, `; p`, `; g`)](#harpoon-proyectos-y-git)
   - [Bibliografía, Citas y Zotero (`; b`)](#bibliografía-y-citas--b)
   - [Segundo Cerebro y Notas (`; k`)](#segundo-cerebro-y-notas--k)
   - [Sincronización en la Nube / Google Drive (`; d`, `; dy`)](#sincronización-en-la-nube-google-drive--d--dy)
   - [Terminal Vterm (`; v`)](#terminal-vterm--v)
   - [Inteligencia Artificial (`; a`, `; A`)](#inteligencia-artificial--a--a)
   - [Agenda y Org-Mode (`; o`)](#agenda-y-org-mode--o)
4. [Ecosistema LaTeX y Clases Maestras](#-ecosistema-latex-y-clases-maestras)
5. [Integración Gráfica con Inkscape](#-integración-gráfica-con-inkscape)
6. [Instalación y Requisitos del Sistema](#-instalación-y-requisitos-del-sistema)

---

## 🏛️ Arquitectura y Estructura del Sistema

La configuración se organiza en una arquitectura modular limpia dentro de `lisp/`, coordinada secuencialmente por `early-init.el` e `init.el`.

```text
~/.emacs.d/
├── early-init.el             # Optimizaciones de pre-arranque (GC, UI nativa, IPC)
├── init.el                  # Orquestador maestro de carga modular
├── custom.el                # Variables generadas por Emacs Customize
├── apuntes-scr.cls          # Clase Maestra para Apuntes y Artículos (KOMA-Script v4.4)
├── tesis-uni.cls            # Clase Maestra de Tesis (IHÉS EGA Bourbaki v22.0)
│
├── lisp/                    # Módulos de configuración (Lisp)
│   ├── my-packages.el       # Gestor de paquetes y repositorios (MELPA, ELPA)
│   ├── my-ui.el             # Tema visual, tipografía, doom-modeline, nerd-icons
│   ├── my-editor.el         # Motor Evil (Vim), Vertico, Consult, Marginalia, Embark
│   ├── my-keys.el           # Mapeo maestro de atajos líder (';') con General.el
│   ├── my-latex-core.el     # AUCTeX, Eglot (TexLab), compilación LuaLaTeX, SyncTeX
│   ├── my-latex-expansions.el# Corfu, Tempel, Súper Salto TAB, LAAS/AAS, Capf de rutas
│   ├── my-latex-snippets.el # Plantillas Tempel, envolturas visuales, Hydra visual
│   ├── my-latex-visuals.el  # TeX-Fold dinámico, Unicode prettify, realce semántico
│   ├── my-latex-tree-sitter.el# Formateo AST Tree-sitter, aislamiento vertical
│   ├── tesis-snippets.el    # Snippets especializados de Geometría Compleja y Kähler
│   ├── tesis-layout.el      # Gestor de disposiciones de pantalla para redacción
│   ├── tesis-tools.el       # Herramientas de tesis, Inkscape pdf_tex y Math Pad
│   ├── my-second-brain.el   # Zotero, Citar, notas zettelkasten y exportación .bib
│   ├── my-ai.el             # Integración con Antigravity / Gemini / GPTel / Aidermacs
│   ├── my-pdf.el            # Visor y anotador de PDFs integrado
│   ├── gdrive-sync.el       # Sincronizador bidireccional Google Drive con Rclone
│   └── syncclient.el        # Monitor y gestor de sincronización de carpetas
│
└── inkscape/                # Entorno completo de dibujo matemático y Math Pad
    ├── applications/        # Lanzador de escritorio .desktop
    ├── bin/                 # Ejecutables inkscape-math-pad y wayland-paste (uinput)
    ├── extensions/          # Extensiones de estilo Gilles Castel (.py y .inx)
    ├── keys/                # Atajos sin conflictos (default.xml)
    ├── systemd/             # Demonio de usuario wayland-paste.service
    ├── install.sh           # Instalador automático en un paso
    └── README.md            # Documentación del flujo de dibujo
```

---

## ⚡ Pila Tecnológica y Paquetes

- **Edición Modal y Navegación:** `evil`, `evil-collection`, `evil-surround`, `evil-mc`, `evil-tex`, `general`, `avy`, `ace-window`, `harpoon`, `drag-stuff`.
- **Búsqueda y Minibuffer:** `vertico`, `marginalia`, `orderless`, `consult`, `embark`, `embark-consult`, `wgrep`.
- **Autocompletado e Inserción:** `corfu`, `nerd-icons-corfu`, `cape`, `tempel`, `aas`, `laas` *(LaTeX Auto-Activating Snippets)*.
- **Motor LaTeX & LSP:** `auctex`, `reftex`, `eglot` *(TexLab Language Server)*, `treesit` *(tree-sitter-latex)*, `texmathp`.
- **Visualización y Estética:** `modus-themes`, `doom-modeline`, `nerd-icons`, `rainbow-delimiters`, `hl-todo`, `goggles`, `diff-hl`.
- **Gestión del Conocimiento y Citas:** `citar`, `citar-embark`, `org-mode`, `org-modern`, `calfw`, `calfw-org`.
- **Terminal e IA:** `vterm`, `vterm-toggle`, `aidermacs`, `gptel`.

---

## ⌨️ Guía de Atajos de Teclado (Cheat Sheet)

> [!TIP]
> La **Tecla Líder** principal está mapeada a **`;`** *(punto y coma)* en los modos Normal, Visual y Motion de Evil. En caso de necesitar la repetición de búsqueda horizontal de Vim, usa `,` *(hacia adelante)* y `\` *(hacia atrás)*.

---

### Atajos Globales y Navegación

| Atajo | Función / Descripción |
|---|---|
| `; SPC` | `M-x` (Ejecutar comando interactivo) |
| `; sa` | Seleccionar todo el buffer (`visual-line`) |
| `C-.` | **Embark Act** (Acciones contextuales sobre el elemento bajo cursor) |
| `C-;` | **Embark DWIM** (Acción predeterminada inteligente) |
| `C-=` | Expandir región semántica (`expand-region`) |
| `M-y` | Consultar historial del portapapeles (`consult-yank-pop`) |
| `M-'` | Corregir ortografía bajo cursor con Jinx (`jinx-correct`) |
| `C-M-'` | Cambiar idiomas de ortografía (`jinx-languages`) |
| `C-z` / `C-S-z` | Deshacer / Rehacer con `undo-fu` (tanto en Normal como en Insert) |
| `; j j` | Salto rápido a texto con Avy (`avy-goto-char-timer`) |
| `; j l` | Salto rápido a línea con Avy (`avy-goto-line`) |
| `; s s` | Buscar línea en el buffer actual (`consult-line`) |

---

### LaTeX y Redacción Científica (`; t`)

| Atajo | Función / Descripción |
|---|---|
| `; t c` | **Compilar inteligentemente** el documento maestro con LuaLaTeX (`my/smart-compile`) |
| `; t v` | **Ver PDF sincronizado** con Zathura y SyncTeX hacia la línea actual (`my/tex-view-with-focus`) |
| `; t z` | Alternar **Modo Visual Zen / TeX-Fold** (plegado tipográfico de símbolos) |
| `; t f` | **Formatear Buffer con Tree-sitter AST** y aislamiento vertical (`my/ts-format-buffer`) |
| `; t h` | **Hydra Visual de Snippets** (Menú interactivo con todos los atajos matemáticos) |
| `; t l` | Insertar etiqueta inteligente (`\label{...}`) |
| `; t C` | Insertar referencia inteligente con cleveref (`\cref{...}`) |
| `; t b` | Insertar cita bibliográfica avanzada con formato y página (`tesis-tools-insert-citation-advanced`) |
| `; t i` | Insertar cita rápida con Citar (`citar-insert-citation`) |
| `; t e` | Insertar entorno LaTeX (`LaTeX-environment`) |
| `; t s` | Insertar sección / subsección (`LaTeX-section`) |
| `; t m` | Asistente interactivo para matrices dinámicas (`my/insert-matrix`) |
| `; t o` | Explorador de estructura del documento / índice (`consult-imenu`) |
| `; t E` | Editar figura SVG de Inkscape asociada al cursor (`tesis-tools-edit-inkscape-pdftex`) |
| `; t A` | Abrir la clase maestra `apuntes-scr.cls` para edición |
| `; t a` | Alternar autoformateo semántico al guardar |
| `; t r` | Renombrar entorno LaTeX bajo cursor mediante Tree-sitter |
| `; t V` | Seleccionar visualmente el entorno LaTeX actual |
| `; t S` | Buscar y navegar entre entornos LaTeX |

#### 🔀 Súper Salto Estructural con TAB
En cualquier buffer LaTeX:
* **`TAB`**: Si hay un snippet de Tempel activo, salta al siguiente campo. Si no, **salta hacia adelante fuera del delimitador estructural más próximo** (`{}`, `()`, `[]`, `\left...\right`, `\[...\]`, `\begin...\end`, `&`, `\\`).
* **`Shift + TAB`**: Salto estructural inverso (hacia atrás).

---

### Archivos, Buffers y Ventanas

| Atajo | Función / Descripción |
|---|---|
| `; f f` | Buscar archivo en el sistema / proyecto (`consult-find`) |
| `; f b` | Conmutar entre buffers abiertos (`consult-buffer`) |
| `; f s` | Guardar buffer actual (`save-buffer`) |
| `; f e` | Editar directorio actual estilo Oil.nvim (`wdired`) |
| `; f n` | Crear nuevo archivo vacío (`my/create-empty-file`) |
| `; w w` | Saltar rápidamente entre ventanas con Ace-Window (`ace-window`) |
| `; w o` | Saltar al siguiente frame (`other-frame`) |
| `; w d` | Cerrar ventana actual (`delete-window`) |
| `; w l` | Activar disposición de pantalla para Tesis (`tesis-layout-activate`) |
| `; w p` | Disposición de pantalla Redactor + PDF (`my/layout-writer`) |
| `; w r` | Disposición de pantalla Investigador / Referencias (`my/layout-researcher`) |
| `; e c` | Buscar y abrir cualquier archivo `.el` de la configuración |
| `; e i` | Editar `init.el` directamente |
| `; e r` | Reiniciar Emacs (`restart-emacs`) |

---

### Harpoon, Proyectos y Git

| Atajo | Función / Descripción |
|---|---|
| `; h a` | Marcar archivo actual en Harpoon (`harpoon-add-file`) |
| `; h h` | Abrir menú completo de Harpoon (`harpoon-toggle-fileline`) |
| `; h 1` ... `9` | Saltar instantáneamente al archivo 1 al 9 de Harpoon |
| `; p f` | Buscar archivo dentro del proyecto Projectile (`projectile-find-file`) |
| `; p r` | Búsqueda global en el proyecto con Ripgrep (`consult-ripgrep`) |
| `; p p` | Cambiar de proyecto (`projectile-switch-project`) |
| `; p b` | Buffers del proyecto actual (`projectile-switch-to-buffer`) |
| `; p k` | Cerrar todos los buffers del proyecto (`projectile-kill-buffers`) |
| `; g s` | Panel de control Git con Magit (`magit-status`) |

---

### Bibliografía y Citas (`; b`)

| Atajo | Función / Descripción |
|---|---|
| `; b b` | Abrir biblioteca bibliográfica de Zotero con Citar (`citar-open`) |
| `; b n` | Abrir o crear nota bibliográfica asociada (`citar-open-notes`) |
| `; b p` | Vista previa de la entrada de Zotero bajo cursor (`my/citar-preview-at-point`) |
| `; b e` | Exportar `.bib` local limpio para el proyecto actual |
| `; b l` | Insertar Magic Link hacia PDF anotado (`my/insert-pdf-link`) |
| `; b o` | Abrir archivo PDF vinculado al Magic Link (`my/open-pdf-link`) |

---

### Segundo Cerebro y Notas (`; k`)

| Atajo | Función / Descripción |
|---|---|
| `; k n` | Crear nueva nota en el Segundo Cerebro (`my/brain-new-entry`) |
| `; k s` | Búsqueda semántica / neuronal en notas (`my/brain-neural-search`) |
| `; k B` | Regenerar archivo maestro `.bib` del cerebro (`my/brain-generate-bib`) |
| `; k c` | Compilar documento maestro del cerebro (`my/smart-compile`) |
| `; k C` | Limpieza y compilación profunda (`my/brain-clean-and-compile`) |
| `; k p` | Ver PDF maestro generado (`my/brain-open-pdf`) |
| `; k F` | Asistente IA para clasificar y organizar nota (`my/brain-ai-librarian`) |
| `; k G` | Generar mapa visual de relaciones entre notas (`my/brain-generate-graph`) |
| `; k P` | Crear nuevo proyecto matemático aislado |
| `; k d` | Abrir o crear diario de hoy (`my/journal-today`) |

---

### Sincronización en la Nube / Google Drive (`; d` / `; dy`)

| Atajo | Función / Descripción |
|---|---|
| `; d d` | **Menú Transient de Google Drive** (`gdrive-sync-transient/body`) |
| `; d b` | Sincronización bidireccional completa inmediata (`bisync`) |
| `; d s` | Subir carpeta local hacia Google Drive |
| `; d S` | Descargar carpeta remota desde Google Drive |
| `; d f` | Subir archivo actual al almacenamiento remoto |
| `; d F` | Descargar archivo actual desde remoto |
| `; d m` | Montar Google Drive como sistema de archivos FUSE |
| `; d M` | Desmontar Google Drive FUSE |
| `; d n` | Explorar Google Drive vía Dired / TRAMP |
| `; d c` | Resolver conflictos de sincronización con Ediff (`gdrive-sync/resolve-conflicts`) |
| `; d r` | Forzar resincronización total (`--resync`) |
| `; d l` | Eliminar candados huérfanos de sincronización (`.lck`) |
| `; dy t` | Menú interactivo de SyncClient (`syncclient-transient-prefix`) |
| `; dy S` | Ver estado y monitoreo de sincronización |

---

### Terminal Vterm (`; v`)

| Atajo | Función / Descripción |
|---|---|
| `; v t` | Conmutar terminal desplegable en el proyecto actual (`my/toggle-term`) |
| `; v n` | Abrir nueva pestaña independiente de terminal (`my/vterm-new`) |
| `; v k` | Recompilar módulo C nativo de Vterm (`vterm-module-compile`) |

---

### Inteligencia Artificial (`; a` / `; A`)

| Atajo | Función / Descripción |
|---|---|
| `; a c` | Abrir sesión de chat con IA en buffer dedicado (`my/ai-chat`) |
| `; a C` | Abrir terminal CLI de Antigravity (`my/ai-cli`) |
| `; a m` | Conmutar modelo de IA (Gemini / Claude / GPT) |
| `; a r` | Refactorizar región seleccionada con IA (`my/ai-refactor-region`) |
| `; a e` | Explicar código o fórmula matemática seleccionada |
| `; a E` | Diagnosticar y explicar el último error de compilación de la terminal |
| `; A a` | Menú interactivo del agente Aidermacs (`aidermacs-transient-menu`) |
| `; A e` | Exportar configuración completa como TXT para análisis |
| `; A t` | Exportar archivos `.tex` del proyecto a TXT |

---

### Agenda y Org-Mode (`; o`)

| Atajo | Función / Descripción |
|---|---|
| `; o a` | Abrir panel de **Agenda Semanal** (`org-agenda`) |
| `; o c` | Captura rápida de tareas o ideas (`org-capture`) |
| `; o k` | Abrir calendario gráfico interactivo (`calfw`) |
| `; o t` | Abrir archivo maestro de planificación (`vida.org`) |
| `; o i` | Importar notas y capturas móviles (`my/org-process-mobile-inbox`) |

---

## 📐 Ecosistema LaTeX y Clases Maestras

### 1. `apuntes-scr.cls` (v4.4) - Apuntes y Artículos Académicos
Diseñada sobre **KOMA-Script** (`scrartcl` / `scrbook`) con soporte multilingüe automático (español/inglés) y tipografía **STIX Two Math**.
- **Entornos Teoremáticos:** Teoremas, lemas, proposiciones, corolarios, definiciones, ejemplos, ejercicios, soluciones, contraejemplos y algoritmos con numeración dependiente de sección o capítulo.
- **Cajas Estilizadas:** `notabox` (azul marino), `warningbox` (rojo alerta), `controlbox` (verde verificación), `afirmacion` con remate `\lozenge`.
- **Bloques de Código Ejecutables:** Entornos Minted para Python (`pythoncode`, `pythonlib`, `pythonexec` con captura automática de `stdout`).
- **Optimización y Cálculo:** Paquete `optidef` traducido con macros `\optmin`, `\optmax`, `\optst`.

### 2. `tesis-uni.cls` (v22.0) - Arquitectura Editorial IHÉS / EGA Bourbaki
Diseñada para investigaciones matemáticas profundas con tipografía **TeX Gyre Termes / Heros / Cursor** bajo LuaLaTeX.
- **Formato Visual Bourbaki:** Párrafos numerados `\numpar[(1.1.1)]`, marcas marginales `\viragedangereux` (⚠️), separadores estrellados `\egabreak` (`* * *`).
- **Demostraciones Estructuradas:** Pasos formales `\directstep` ($(\Rightarrow)$), `\reversestep` ($(\Leftarrow)$), `\containedstep` ($(\subseteq)$), subcasos con `proofcases` y afirmaciones anidadas con `claimproof`.
- **Suite de Referencias Inteligentes:** `\sref`, `\csref`, `\namedsref`, `\titref`, `\autonamedsref`, `\srefname`.
- **Suite de Geometría Algebraica y Haces:** Funtor de haces con kerning IHÉS (`\shHom`, `\shExt`, `\shTor`, `\shDer`), gavillas (`\Ox`, `\Fsh`, `\Gsh`) y categorías en negrita Bourbaki (`\Set`, `\Sch`, `\QCoh`, `\Ab`, `\CRing`).

---

## 🎨 Integración Gráfica con Inkscape

La suite incluye un puente bidireccional entre Emacs, GNOME Wayland e Inkscape:

1. **Atajos de Teclado Estilo Castel:** En Inkscape, teclas directas (`w`, `a`, `c`, `f`, `s`, `o`, `u`, `p`) ciclan propiedades de grosor, color, relleno, opacidad y flechas sin deseleccionar los trazos.
2. **Math Pad Flotante (`<Alt>m>`):** 
   - Abre instantáneamente una ventana compacta y centrada de Emacs sobre Inkscape.
   - Escribe fórmulas en LaTeX con autocompletado y snippets.
   - Al presionar `Enter` o `C-c C-c`, la ventana se cierra y el texto se inserta en Inkscape a través del demonio `/dev/uinput` (`wayland-paste.service`) sin retrasos ni pérdidas de foco.
3. **Exportación `.pdf_tex`:** Inserta y edita figuras SVG vectoriales con texto renderizado nativamente por LaTeX (`; i i` y `; t E`).

---

## 🛠️ Instalación y Requisitos del Sistema

### Dependencias Principales (Ubuntu / Debian)

```bash
# 1. Herramientas base y compiladores
sudo apt install -y emacs-pgtk texlive-full zathura zathura-pdf-poppler \
                    ripgrep fd-find libvterm-dev libtool-bin cmake \
                    rclone python3-evdev python3-pyperclip inkscape wl-clipboard

# 2. Permisos de teclado virtual para Wayland Paste
sudo usermod -aG uinput $USER
echo 'KERNEL=="uinput", GROUP="uinput", MODE="0660"' | sudo tee /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Despliegue de la Configuración de Inkscape
```bash
cd ~/.emacs.d/inkscape
./install.sh
```

### Arranque
Al iniciar Emacs por primera vez, `my-packages.el` descargará y compilará automáticamente todos los paquetes faltantes de MELPA y ELPA sin necesidad de intervención manual.
