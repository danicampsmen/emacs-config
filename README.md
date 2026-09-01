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

---

## 📂 Estructura de la Configuración

```text
~/.emacs.d/
├── early-init.el                 # Optimizaciones de pre-arranque
├── init.el                       # Controlador maestro
├── custom.el                     # Variables personalizadas
├── lisp/                         # Módulos modularizados
│   ├── my-packages.el            # Bootstrap de paquetes
│   ├── my-ui.el                  # Interfaz y tema
│   ├── my-editor.el              # Evil mode y edición
│   ├── my-keys.el                # Atajos líder
│   ├── my-ai.el                  # Antigravity / GPTel / Aider
│   ├── my-pdf.el                 # Visor PDF (Zathura)
│   ├── my-latex-core.el          # AUCTeX + LSP
│   ├── my-latex-tree-sitter.el   # AST formateo 120 cols
│   ├── my-latex-snippets.el      # Snippets Tempel
│   ├── my-latex-expansions.el    # Corfu + LAAS + TAB inteligente
│   ├── my-latex-visuals.el       # Zen mode + TeX-Fold
│   ├── tesis-tools.el            # Herramientas tesis
│   ├── tesis-layout.el           # Layouts de trabajo
│   ├── tesis-snippets.el         # Snippets Geometría Compleja
│   ├── gdrive-sync.el            # Rclone bisync
│   ├── syncclient.el             # SyncClient local
│   └── my-second-brain.el        # Zotero / Segundo Cerebro
├── docs/                         # Manuales LaTeX
│   ├── manual-apuntes-scr.tex
│   ├── manual-emacs.tex
│   ├── manual-zathura.tex
│   ├── manual-kitty.tex
│   ├── manual-sway-waybar.tex
│   └── cheatsheet-ecosistema.tex
└── documentclasses/              # Clases LaTeX maestras
    ├── apuntes-scr.cls           # Clase KOMA-Script Bourbaki/IHÉS
    └── tesis-uni.cls             # Clase tesis institucional
```

---

## 🔧 Configuración del Sistema

### Dependencias Principales

| Paquete | Versión | Función |
|---|---|---|
| GNU Emacs | 30+ | Editor base con compilación nativa |
| LuaLaTeX | TL2026 | Motor de composición tipográfica |
| TexLab | latest | LSP para LaTeX (eglot) |
| Zathura | latest | Visor PDF con SyncTeX |
| Rclone | latest | Sincronización Google Drive |
| Kitty | latest | Terminal GPU acelerada |
| Sway | latest | Gestor de ventanas Wayland |

### Variables de Entorno

```bash
# Ruby para LSP (si aplica)
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"

# TeX Live
export PATH="/usr/local/texlive/2026/bin/x86_64-linux:$PATH"

# Binarios locales
export PATH="$HOME/.local/bin:$PATH"
```

---

## 📖 Manuales de Referencia

La documentación completa se encuentra en formato LaTeX dentro de [`docs/`](./docs/):

- **`manual-apuntes.tex`**: Referencia completa de la clase `apuntes-scr.cls` con ejemplos de teoremas, demostraciones, listas Bourbaki y estructuras EGA.
- **`manual-emacs.tex`**: Guía operativa del ecosistema Emacs: atajos, snippets AAS/LAAS, plegado visual, Segundo Cerebro y Antigravity.
- **`manual-zathura.tex`**: Configuración y uso del visor PDF con SyncTeX bidireccional.
- **`manual-kitty.tex`**: Terminal GPU acelerada con tipografía matemática integrada.
- **`manual-sway-waybar.tex`**: Gestor de ventanas tiling y barra de estado.
- **`cheatsheet-ecosistema.tex`**: Resumen visual de atajos en formato hoja rápida.

---

## 🎓 Filosofía de Diseño

### 1. **Control Total por Teclado**
Todas las operaciones de edición, navegación, compilación y control de versiones se realizan exclusivamente desde el teclado, eliminando la latencia del ratón.

### 2. **Modalidad Ergonómica**
Combina los movimientos y operadores de Vim con un menú estructurado bajo la tecla líder `;` (punto y coma), gestionado por `general.el` y `which-key`.

### 3. **Completado Inteligente**
Sistema ultrarrápido compuesto por Vertico (lista vertical), Orderless (búsqueda difusa) y Marginalia (descripciones contextuales).

### 4. **Estética Científica**
Tema Modus Vivendi Deuteranopia sobre fondo negro puro (`#000000`) con tipografía Iosevka Term y iconos vectoriales Nerd Fonts.

---

## 🔗 Enlaces Externos

- **Repositorio**: [github.com/fayfer/emacs-config](https://github.com/fayfer/emacs-config)
- **Documentación apuntes-scr.cls**: [`docs/manual-apuntes-scr.tex`](./docs/manual-apuntes-scr.tex)
- **Cheat Sheet Visual**: [`docs/cheatsheet-ecosistema.tex`](./docs/cheatsheet-ecosistema.tex)

---

*Generado automáticamente por `my/export-config-as-txt` | Última actualización: `2026-09-01`*
