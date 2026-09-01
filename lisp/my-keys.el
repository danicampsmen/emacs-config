;;; my-keys.el --- Atajos de teclado líder -*- lexical-binding: t; -*-

(require 'general) ;; Aseguramos que general esté cargado
(require 'my-ai)   ;; Carga explícita del módulo de IA

(declare-function undo-fu-only-undo "undo-fu" ())
(declare-function undo-fu-only-redo "undo-fu" ())
(declare-function evil-visual-line "evil-commands" ())
(declare-function evil-repeat-find-char "evil-commands" (count))
(declare-function evil-repeat-find-char-reverse "evil-commands" (count))

;; ==================================================================
;; --- 1. SILENCIAR TECLAS MULTIMEDIA Y ATAJOS GLOBALES ---
;; ==================================================================
(general-def
  ;; Silenciar teclas multimedia
  "<XF86AudioLowerVolume>"  'ignore
  "<XF86AudioRaiseVolume>"  'ignore
  "<XF86AudioMute>"         'ignore
  "<XF86MonBrightnessDown>" 'ignore
  "<XF86MonBrightnessUp>"   'ignore
  "C-<"                     'ignore
  "C->"                     'ignore

  ;; Atajos Globales Base
  "C-."     'embark-act
  "C-;"     'embark-dwim
  "C-="     'er/expand-region
  "M-y"     'consult-yank-pop
  "M-'"     'jinx-correct
  "C-M-'"   'jinx-languages
  "C-c h"   'my/select-all-buffer)

;; ==================================================================
;; --- 2. UNDO/REDO EN EVIL MODE ---
;; ==================================================================

;; Undo/Redo en Evil Mode (Usando undo-fu)
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-z") #'undo-fu-only-undo)
  (define-key evil-insert-state-map (kbd "C-z") #'undo-fu-only-undo)
  (define-key evil-normal-state-map (kbd "C-S-z") #'undo-fu-only-redo)
  (define-key evil-insert-state-map (kbd "C-S-z") #'undo-fu-only-redo)
  ;; Liberar el corchete de conflictos en modo insert
  (define-key evil-insert-state-map (kbd "]") nil))

;; ==================================================================
;; --- 3. PLUGINS DE NAVEGACIÓN GLOBAL ---
;; ==================================================================
(require 'which-key)
(setq which-key-idle-delay 0.3)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode 1)

(require 'ace-window)
(setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
(setq aw-scope 'global)
(setq aw-minibuffer-flag t)

(require 'drag-stuff)
(drag-stuff-global-mode 1)
(drag-stuff-define-keys)

;; ==================================================================
;; --- FUNCIONES AUXILIARES DE ATAJOS ---
;; ==================================================================

(defun my/find-config-file ()
  "Busca y abre rápidamente cualquier archivo de configuración de Emacs."
  (interactive)
  (let* ((config-dir user-emacs-directory)
         (lisp-dir (expand-file-name "lisp" config-dir))
         ;; 1. Archivos principales en la raíz de ~/.emacs.d/
         (base-files '("init.el" "early-init.el" "custom.el"))
         (valid-base (cl-remove-if-not 
                      (lambda (f) (file-exists-p (expand-file-name f config-dir))) 
                      base-files))
         ;; 2. Archivos modulares dentro de lisp/
         (lisp-files (if (file-exists-p lisp-dir)
                         (directory-files lisp-dir nil "\\.el$")
                       nil))
         ;; Le añadimos el prefijo "lisp/" visualmente para que sepas dónde están
         (lisp-files-format (mapcar (lambda (f) (concat "lisp/" f)) lisp-files))
         
         ;; 3. Unimos ambas listas y se la pasamos a Vertico
         (all-files (append valid-base lisp-files-format))
         (selected (completing-read "⚙️ Config Emacs: " all-files nil t)))
    
    ;; 4. Abrimos el archivo seleccionado
    (find-file (expand-file-name selected config-dir))))

(defun my/create-empty-file (filename)
  "Crea un archivo vacío con el nombre FILENAME en el directorio actual.
Si estás en Dired, actualiza el buffer automáticamente para mostrarlo."
  (interactive "sNombre del nuevo archivo: ")
  (let ((path (expand-file-name filename default-directory)))
    (if (file-exists-p path)
        (message "⚠️ El archivo ya existe: %s" filename)
      (write-region "" nil path)
      (when (derived-mode-p 'dired-mode)
        (revert-buffer))
      (message "✅ Archivo '%s' creado con éxito." filename))))
      
(defun my/open-init-file ()
  "Abre el archivo de configuración maestro."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun my/open-apuntes-cls ()
  "Abre la plantilla de apuntes."
  (interactive)
  (find-file "~/texmf/tex/latex/apuntes/apuntes-scr.cls"))

(defun my/dired-edit-directory ()
  "Abre Dired en el directorio actual e inicia WDired para editarlo (estilo Oil.nvim)."
  (interactive)
  (require 'wdired)
  (if (derived-mode-p 'dired-mode)
      (wdired-change-to-wdired-mode)
    (dired default-directory)
    (wdired-change-to-wdired-mode)))

(defun my/select-all-buffer ()
  "Selecciona visualmente todo el contenido del buffer y activa el estado visual de Evil."
  (interactive)
  (goto-char (point-min))
  (evil-visual-line)
  (goto-char (point-max)))

;; ==================================================================
;; --- 4. GESTIÓN DEL LÍDER (GENERAL.EL) ---
;; ==================================================================
(require 'general)
(require 'harpoon)

;; Configuración segura de estados
(setq general-override-states '(insert emacs hybrid normal visual motion operator replace))
(general-auto-unbind-keys)

;; Definición maestra de la tecla Líder (";")
(general-create-definer my/leader-keys
  :prefix ";"
  :states '(normal visual motion)
  :keymaps 'override)

;; ==================================================================
;; --- 5. DICCIONARIO MAESTRO DE ATAJOS DEL LÍDER ---
;; ==================================================================
(my/leader-keys
  ;; --- Globales Rápidos ---
  "SPC" '(execute-extended-command :which-key "M-x")
  "sa"  '(my/select-all-buffer :which-key "Seleccionar Todo")

  ;; --- Inteligencia Artificial (Google Antigravity) ---
  "a"   '(:ignore t :which-key "Antigravity IA")
  "aa"  '(my/antigravity-menu :which-key "Menú Transient Antigravity")
  "ac"  '(my/antigravity-cli :which-key "Terminal Interactiva (vterm)")
  "aC"  '(my/antigravity-continue :which-key "Reanudar Última Sesión (-c)")
  "ap"  '(my/antigravity-plan :which-key "Modo Planificación")
  "aq"  '(my/antigravity-ask :which-key "Preguntar / Consultar")
  "ai"  '(my/antigravity-inline-edit :which-key "Edición Inline (Diff)")
  "ar"  '(my/antigravity-refactor-region :which-key "Refactorizar Región")
  "ae"  '(my/antigravity-explain-region :which-key "Explicar Selección / Fórmula")
  "aE"  '(my/antigravity-diagnose-terminal-error :which-key "Diagnosticar Error Terminal")
  "am"  '(my/antigravity-switch-model :which-key "Cambiar Modelo Antigravity")
  "ax"  '(my/antigravity-switch-effort :which-key "Nivel Razonamiento (Effort)")
  "a/"  '(my/antigravity-send-slash-command :which-key "Slash Commands")
  "ag"  '(my/antigravity-git-commit-message :which-key "Generar Commit Git")
  "aA"  '(aidermacs-transient-menu :which-key "Agente Aider (Fallback)")

  ;; --- Archivos e Inserción ---
  "i"   '(:ignore t :which-key "Insertar/Pegar") 
  "is"  '(tempel-insert :which-key "Insertar Snippet")
  "ip"  '(my/yank-clean :which-key "Pegar Limpio")
  "if"  '(cape-file :which-key "Autocompletar Archivo")
  "ii"  '(tesis-tools-insert-inkscape-pdftex :which-key "Dibujo Inkscape (Nuevo)")
  "im"  '(tesis-tools-inkscape-math-popup :which-key "Math Pad para Inkscape")


  "e"   '(:ignore t :which-key "Emacs")
  "ec"  '(my/find-config-file :which-key "Buscar Config (.el)")
  "ei"  '(my/open-init-file :which-key "Editar Init")
  "er"  '(restart-emacs :which-key "Reiniciar")
  "et"  '(my-terminal-gui-mode :which-key "Modo Terminal-GUI")


  "f"   '(:ignore t :which-key "Archivos")
  "ff"  '(consult-find :which-key "Find File")
  "fb"  '(consult-buffer :which-key "Buffers")
  "fs"  '(save-buffer :which-key "Save")
  "fe"  '(my/dired-edit-directory :which-key "Editar Directorio (Oil)")
  "fn"  '(my/create-empty-file :which-key "Nuevo Archivo Vacío")

  ;; --- Harpoon (Navegación Rápida) ---
  "h"   '(:ignore t :which-key "Harpoon")
  "ha"  '(harpoon-add-file :which-key "Marcar Archivo")
  "hh"  '(harpoon-toggle-fileline :which-key "Menú Completo")
  "h1"  '(harpoon-go-to-1 :which-key "Archivo 1")
  "h2"  '(harpoon-go-to-2 :which-key "Archivo 2")
  "h3"  '(harpoon-go-to-3 :which-key "Archivo 3")
  "h4"  '(harpoon-go-to-4 :which-key "Archivo 4")
  "h5"  '(harpoon-go-to-5 :which-key "Archivo 5")
  "h6"  '(harpoon-go-to-6 :which-key "Archivo 6")
  "h7"  '(harpoon-go-to-7 :which-key "Archivo 7")
  "h8"  '(harpoon-go-to-8 :which-key "Archivo 8")
  "h9"  '(harpoon-go-to-9 :which-key "Archivo 9")
	
  ;; --- Proyecto (Projectile) ---
  "p"   '(:ignore t :which-key "Project")
  "pf"  '(projectile-find-file :which-key "Find File")
  "pr"  '(consult-ripgrep :which-key "Ripgrep")
  "pp"  '(projectile-switch-project :which-key "Switch Project")
  "pb"  '(projectile-switch-to-buffer :which-key "Project Buffers")
  "pk"  '(projectile-kill-buffers :which-key "Kill Buffers")
  
  ;; --- Git ---
  "g"   '(:ignore t :which-key "Git")
  "gs"  '(magit-status :which-key "Status")
  
  ;; --- Google Drive / Sync ---
  "d"   '(:ignore t :which-key "Google Drive / Sync")
  "dd"  '(gdrive-sync-transient/body :which-key "Menú Transient GDrive")
  "dn"  '(gdrive-sync/browse-remote :which-key "Navegar GDrive (Dired TRAMP)")
  "di"  '(gdrive-sync/navigate-remote :which-key "Explorador Interactivo")
  "dm"  '(gdrive-sync/mount-remote :which-key "Montar GDrive (FUSE)")
  "dM"  '(gdrive-sync/unmount-remote :which-key "Desmontar GDrive (FUSE)")
  "db"  '(gdrive-sync/bisync-now :which-key "Sincronizar Todo (bisync)")
  "ds"  '(gdrive-sync/sync-local-to-remote :which-key "Local ➔ Remoto (Carpeta)")
  "dS"  '(gdrive-sync/sync-remote-to-local :which-key "Remoto ➔ Local (Carpeta)")
  "df"  '(gdrive-sync/upload-current-file :which-key "Subir Archivo Actual")
  "dF"  '(gdrive-sync/download-remote-file :which-key "Descargar Archivo Remoto")
  "du"  '(gdrive-sync/upload-modified :which-key "Subir Modificados en Sesión")
  "dr"  '(gdrive-sync/bisync-resync-global :which-key "Forzar Resincronización (--resync)")
  "dl"  '(gdrive-sync/force-unlock :which-key "Eliminar Candados (.lck)")
  "dc"  '(gdrive-sync/resolve-conflicts :which-key "Resolver Conflictos (Ediff)")
  "dR"  '(gdrive-sync/refresh-folder-cache :which-key "Refrescar Caché de Carpetas")

  "dy"  '(:ignore t :which-key "SyncClient")
  "dyS" '(syncclient-status :which-key "Ver Estado")
  "dyf" '(syncclient-force-sync-current :which-key "Forzar Sync Seleccionado")
  "dyc" '(syncclient-clean-duplicates-current :which-key "Limpiar Duplicados Seleccionado")
  "dya" '(syncclient-add-pair :which-key "Agregar Par")
  "dyb" '(syncclient-browse-remote :which-key "Explorar Carpetas Remotas")
  "dyi" '(syncclient-current-activity :which-key "Ver Actividad Actual")
  "dyt" '(syncclient-transient-prefix :which-key "Menú Transient")

  ;; --- Ventanas / Frames ---
  "w"   '(:ignore t :which-key "Windows/Frames")
  "ww"  '(ace-window :which-key "Saltar (Ace)")
  "wo"  '(other-frame :which-key "Siguiente Frame")
  "wd"  '(delete-window :which-key "Cerrar Ventana")
  "wl"  '(tesis-layout-activate :which-key "Layout Tesis")
  "wp"  '(my/layout-writer :which-key "Layout Tesis (PDF)")
  "wr"  '(my/layout-researcher :which-key "Layout Referencia")
  
;; --- LaTeX / Texto ---
  "t"   '(:ignore t :which-key "TeX/Texto")
  "ta"  '(my/toggle-latex-auto-format-on-save :which-key "Toggle Auto-Format al Guardar")
  "tA"  '(my/open-apuntes-cls :which-key "Editar apuntes.cls")
  "tb"  '(tesis-tools-insert-citation-advanced :which-key "Citar Avanzado")
  "tc"  '(my/smart-compile :which-key "Compilar (Smart)")
  "tC"  '(my/insert-cref :which-key "Citar con cref")
  "tp"  '(prettify-symbols-mode :which-key "Símbolos")
  "td"  '(rainbow-delimiters-mode :which-key "Rainbow Delimiters")
  "tl"  '(my/smart-latex-label :which-key "Label Inteligente")
  "te"  '(LaTeX-environment :which-key "Env")
  "tE"  '(tesis-tools-edit-inkscape-pdftex :which-key "Editar SVG en Inkscape")
  "ts"  '(LaTeX-section :which-key "Sec")
  "tv"  '(my/tex-view-with-focus :which-key "Ver PDF (Zathura Sync)")
  "tz"  '(my/latex-visual-mode :which-key "Toggle Visual Zen")
  "ti"  '(citar-insert-citation :which-key "Citar")
  "to"  '(consult-imenu :which-key "Índice")
  "tf"  '(my/ts-format-buffer :which-key "Formatear Buffer (Tree-sitter)") ;; <-- AQUÍ
  "tn"  '(my/quick-add-snippet :which-key "Nuevo Snippet")
  "tR"  '(my/reload-snippets :which-key "Recargar Snippets")
  "tm"  '(my/insert-matrix :which-key "Matriz Dinámica")
  "th"  '(my-latex-snippet-hydra/body :which-key "Hydra Snippets")
  "tr"  '(my/ts-rename-environment :which-key "TS Renombrar Entorno")
  "tV"  '(my/ts-select-environment :which-key "TS Seleccionar Entorno")
  "tS"  '(my/ts-search-environments :which-key "TS Buscar Entornos")

  ;; --- IA JARVIS, Antigravity y Debugging ---
  "A"   '(:ignore t :which-key "Agente IA / Debug")
  "AM"  '(my/antigravity-menu :which-key "Menú Antigravity")
  "Al"  '(my/antigravity-live-output :which-key "Salida Terminal en Vivo (Tail)")
  "Av"  '(my/antigravity-live-vterm :which-key "Terminal vterm en Vivo")
  "Aa"  '(aidermacs-transient-menu :which-key "Agente Aider (R1)")
  "Aj"  '(my/jarvis-chat-session :which-key "Abrir Chat")
  "Ac"  '(my/jarvis-oneshot-command :which-key "Comando Rápido")
  "Ae"  '(my/export-config-as-txt :which-key "Exportar Config a TXT")
  "AE"  '(my/export-files-by-extension :which-key "Exportar extensión general")
  "At"  '(my/export-project-tex-as-txt :which-key "Exportar .tex a TXT")
    
  ;; --- Terminal (Vterm) ---
  "v"   '(:ignore t :which-key "Terminal")
  "vt"  '(my/toggle-term :which-key "Toggle (Smart)")
  "vn"  '(my/vterm-new :which-key "Nueva Pestaña")
  "vk"  '(vterm-module-compile :which-key "Recompilar Módulo")
  
  ;; --- Bibliografía / Zotero ---
  "b"   '(:ignore t :which-key "Bib/Zotero")
  "bb"  '(citar-open :which-key "Abrir Biblioteca")
  "bn"  '(citar-open-notes :which-key "Nota LaTeX")
  "bp"  '(my/citar-preview-at-point :which-key "Vista Previa Cita Zotero")
  "be"  '(my/brain-export-local-bib :which-key "Exportar .bib Local")
  "bl"  '(my/insert-pdf-link :which-key "Insert Magic Link")
  "bo"  '(my/open-pdf-link :which-key "Open Magic Link")
  
  ;; --- Búsqueda / Avy ---
  "j"   '(:ignore t :which-key "Jump/Avy")
  "jj"  '(avy-goto-char-timer :which-key "Saltar a texto")
  "jl"  '(avy-goto-line :which-key "Saltar a línea")
  "ss"  '(consult-line :which-key "Buscar línea")
    
  ;; --- Segundo Cerebro ---
  "k"   '(:ignore t :which-key "Segundo Cerebro")
  "kn"  '(my/brain-new-entry :which-key "Nueva Nota")
  "ks"  '(my/brain-neural-search :which-key "Búsqueda Neuronal")
  "kB"  '(my/brain-generate-bib :which-key "Regenerar Bib")
  "kc"  '(my/smart-compile :which-key "Compilar (Smart)")
  "kC"  '(my/brain-clean-and-compile :which-key "Limpiar y Compilar")
  "kp"  '(my/brain-open-pdf :which-key "Ver PDF Maestro")
  "kF"  '(my/brain-ai-librarian :which-key "Clasificar Nota")
  "kG"  '(my/brain-generate-graph :which-key "Ver Mapa")
  "kP"  '(my/project-new-isolated :which-key "Nuevo Proyecto")
  "kd"  '(my/journal-today :which-key "Diario Hoy")
  
  ;; --- Org Mode / Agenda ---
  "o"   '(:ignore t :which-key "Org/Agenda")
  "oa"  '(org-agenda :which-key "Ver Agenda")
  "oc"  '(org-capture :which-key "Captura Rápida")
  "oi"  '(my/org-process-mobile-inbox :which-key "Importar Móvil")
  "ok"  '(my/open-calendar :which-key "Calendario Gráfico")
  "ot"  '(lambda () (interactive) (find-file (expand-file-name "vida.org" org-directory)) :which-key "Abrir vida.org")
  )

;; ==================================================================
;; --- 6. RESCATE DE NAVEGACIÓN VIM (EVIL) ---
;; ==================================================================
(with-eval-after-load 'evil
  ;; Al usar ';' como líder global, trasladamos la repetición de búsqueda horizontal
  ;; hacia adelante a la tecla coma (',')
  (define-key evil-motion-state-map (kbd ",") #'evil-repeat-find-char)
  
  ;; Reasignamos la repetición inversa (hacia atrás) a la barra invertida ('\')
  ;; para no perder la capacidad de retroceder rápidamente si nos pasamos del caracter
  (define-key evil-motion-state-map (kbd "\\") #'evil-repeat-find-char-reverse)
  
  ;; Desvinculamos preventivamente la coma en el mapa normal para evitar 
  ;; conflictos con funciones legacy y garantizar que herede limpiamente del motion-map
  (define-key evil-normal-state-map (kbd ",") nil))

(provide 'my-keys)
;;; my-keys.el ends here
