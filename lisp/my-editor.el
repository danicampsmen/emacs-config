;;; my-editor.el --- Evil mode, Herramientas, IA y Lenguajes -*- lexical-binding: t; -*-

(declare-function aggressive-indent-mode "aggressive-indent" (&optional arg))
(declare-function LaTeX-fill-buffer "tex" ())
(declare-function tempel-insert "tempel" (template))
(declare-function reftex-access-scan-info "reftex" ())
(declare-function gptel "gptel" (name &optional initial interactive))
(declare-function gptel-send "gptel" (&optional arg))

;; ==================================================================
;; --- 1. EVIL MODE (Navegación Modal) ---
;; ==================================================================
(setq evil-want-integration t
      evil-want-keybinding nil)
(require 'evil)
(evil-mode 1)

(require 'evil-collection)
(evil-collection-init)

(require 'evil-surround)
(global-evil-surround-mode 1)

(require 'evil-mc)
(global-evil-mc-mode 1)

;; ==================================================================
;; --- 2. GIT Y VISUALIZACIÓN DE CAMBIOS ---
;; ==================================================================
(require 'diff-hl)
(global-diff-hl-mode)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
(add-hook 'dired-mode-hook 'diff-hl-dired-mode)

(require 'goggles)
(goggles-mode 1)
(setq-default goggles-pulse t)

;; ==================================================================
;; --- 3. ORTOGRAFÍA Y TEXTO ---
;; ==================================================================
(require 'jinx)
(setq jinx-languages "es_PE en_US")
(global-jinx-mode 1) ;; Encendido directo y global

;; Permitir usar el comando nativo para pasar a mayúsculas sin avisos
(put 'upcase-region 'disabled nil)

;; ==================================================================
;; --- 4. TERMINAL (VTERM) ---
;; ==================================================================
(require 'vterm)
(require 'vterm-toggle)

(setq vterm-toggle-scope 'project)

;; 1. Engañar al Shell: Forzar compatibilidad de color universal
(setq vterm-environment '("TERM=xterm-256color"))

(add-hook 'vterm-mode-hook 
          (lambda () 
            ;; 2. Apagar el coloreado de sintaxis de Emacs (Vterm usa ANSI puro)
            (font-lock-mode 1)      
            
            ;; 3. Apagar márgenes y líneas superpuestas globales
            (display-line-numbers-mode -1) 
            (display-fill-column-indicator-mode -1)
            
            ;; 4. Apagar el resaltado de línea actual
            (setq-local global-hl-line-mode nil)
            (hl-line-mode -1)        
            
            ;; 5. Apagar indentación automática
            (aggressive-indent-mode -1)))

(with-eval-after-load 'evil-collection
  (evil-collection-vterm-setup))

(defun my/toggle-term ()
  "Abre o cierra la terminal inferior en el contexto del proyecto actual."
  (interactive)
  (let ((default-directory (if (and (bound-and-true-p projectile-mode) (projectile-project-p))
                               (projectile-project-root)
                             default-directory)))
    (vterm-toggle)))

(defun my/vterm-new ()
  "Abre una nueva pestaña de terminal independiente."
  (interactive)
  (vterm (generate-new-buffer-name "*vterm*")))
  
;; Cargar archivo de secretos si está presente
(let ((secrets-file (expand-file-name "my-secrets.el" (file-name-directory (or load-file-name buffer-file-name)))))
  (when (file-exists-p secrets-file)
    (require 'my-secrets secrets-file t)))

;; ==================================================================
;; --- 5. INTELIGENCIA ARTIFICIAL (Movido al módulo my-ai.el) ---
;; ==================================================================

;; ==================================================================
;; --- 6. DATA SCIENCE (JULIA) ---
;; ==================================================================
(require 'julia-mode)
(require 'julia-repl)

(defun my/julia-mode-setup ()
  "Configura el entorno al abrir archivos .jl."
  (eglot-ensure)
  (julia-repl-mode 1)
  (display-line-numbers-mode 1))

(add-hook 'julia-mode-hook #'my/julia-mode-setup)

;; Hacer que la consola REPL de Julia use el poder de Vterm
(add-hook 'julia-repl-mode-hook
          (lambda ()
            (with-eval-after-load 'vterm
              (setq julia-repl-terminal-type 'vterm))))

;; ==================================================================
;; --- 7. HERRAMIENTAS DE FORMATEO Y EDICIÓN ---
;; ==================================================================

(defun my/yank-clean ()
  "Pega el texto del portapapeles eliminando saltos de línea molestos."
  (interactive)
  (let ((text (current-kill 0)))
    (when text
      (setq text (replace-regexp-in-string "[\n\r]+" " " text))
      (setq text (replace-regexp-in-string " +" " " text))
      (setq text (string-trim text))
      (insert text)
      (message "Texto pegado sin saltos de línea."))))

(defun my/format-buffer-native ()
  "Aplica el formateo nativo seguro de AUCTeX."
  (interactive)
  (if (derived-mode-p 'LaTeX-mode)
      (save-excursion
        (message "Aplicando formato Nativo (AuCTeX)...")
        (indent-region (point-min) (point-max))
        (LaTeX-fill-buffer nil)
        (message "Formato Nativo completado."))
    (message "No es un buffer LaTeX.")))

(defun my/format-buffer-latexindent ()
  "Aplica formateo avanzado usando latexindent."
  (interactive)
  (if (derived-mode-p 'LaTeX-mode)
      (if (executable-find "latexindent")
          (let* ((original-point (point))
                 (in-file (make-temp-file "indent_in" nil ".tex"))
                 (out-file (make-temp-file "indent_out" nil ".tex"))
                 (err-file (make-temp-file "indent_err"))
                 (yaml-config (expand-file-name "~/.latexindent.yaml")))
            (unwind-protect
                (progn
                  (write-region (point-min) (point-max) in-file nil 'silent)
                  
                  ;; CORRECCIÓN: Usar "-l" para el archivo YAML y omitir "-w"
                  (let ((exit-code (call-process "latexindent" nil (list nil err-file) nil
                                                 "-l" yaml-config
                                                 in-file "-o" out-file)))
                    (if (zerop exit-code)
                        (progn
                          (erase-buffer)
                          (insert-file-contents out-file)
                          (goto-char original-point)
                          (message "Formato Avanzado completado."))
                      (message "Error en latexindent (código %d). Revisa *Messages* con ;Ad" exit-code))))
              ;; Limpieza garantizada de archivos temporales
              (when (file-exists-p in-file) (delete-file in-file))
              (when (file-exists-p out-file) (delete-file out-file))
              (when (file-exists-p err-file) (delete-file err-file))))
        (message "latexindent no encontrado en el sistema."))
    (message "No es un buffer LaTeX.")))

(defun my/debug-latexindent ()
  "Diagnóstico: Ejecuta latexindent y muestra la salida detallada en un buffer."
  (interactive)
  (let* ((in-file (make-temp-file "debug_in" nil ".tex"))
         (err-file (make-temp-file "debug_err"))
         (yaml-config (expand-file-name "~/.latexindent.yaml"))
         (args (list "-l" yaml-config in-file)))
    (write-region (point-min) (point-max) in-file nil 'silent)
    (let ((debug-buf (get-buffer-create "*latexindent-debug*")))
      (with-current-buffer debug-buf
        (erase-buffer)
        (insert "=== DIAGNÓSTICO DE LATEXINDENT ===\n")
        (insert (format "1. Archivo YAML: %s\n" yaml-config))
        (insert (format "   ¿Existe?: %s\n" (if (file-exists-p yaml-config) "SÍ" "NO")))
        (insert (format "2. Comando Exacto:\n   latexindent %s\n\n" (string-join args " ")))
        (insert "=== INICIO DE SALIDA (STDOUT) ===\n"))
      ;; CORRECCIÓN AQUÍ TAMBIÉN
      (call-process "latexindent" nil (list debug-buf err-file) nil
                    "-l" yaml-config in-file)
      (with-current-buffer debug-buf
        (goto-char (point-max))
        (insert "\n=== FIN DE SALIDA ===\n\n")
        (insert "=== ERRORES (STDERR) ===\n")
        (insert-file-contents err-file)
        (special-mode))
      (pop-to-buffer debug-buf)
      (message "Diagnóstico completado."))))

(defun my/insert-matrix (rows cols type)
  "Inserta una matriz dinámica usando Tempel."
  (interactive "nFilas: \nnColumnas: \nsTipo (p/b/v/V/blank): ")
  (let ((matrix-template (list (format "\\begin{%smatrix}\n" (if (string= type "blank") "" type)))))
    (dotimes (r rows)
      (dotimes (c cols)
        ;; En Tempel, 'p' crea un punto de tabulación
        (push 'p matrix-template) 
        (unless (= c (1- cols)) (push " & " matrix-template)))
      (push " \\\\\n" matrix-template))
    (push (format "\\end{%smatrix}" (if (string= type "blank") "" type)) matrix-template)
    
    ;; Invertimos la lista porque usamos push, y la evaluamos con Tempel
    (tempel-insert (nreverse matrix-template))))

(defun my/insert-cref ()
  "Inserta \\cref{} buscando etiquetas con Vertico/Orderless en lugar del menú antiguo de RefTeX."
  (interactive)
  ;; 1. Asegura que RefTeX ha escaneado el documento actual y conoce las etiquetas
  (reftex-access-scan-info)
  
  ;; 2. Extrae todas las etiquetas de la base de datos interna de RefTeX
  (let ((labels nil))
    (dolist (item (symbol-value reftex-docstruct-symbol))
      ;; Las etiquetas en RefTeX son listas cuyo primer elemento es un String (el nombre)
      (when (and (listp item) 
                 (stringp (car item)))
        (push (car item) labels)))
    
    ;; 3. Muestra el buscador moderno si hay etiquetas
    (if labels
        (let ((selected (completing-read "Etiqueta para \\cref: " (nreverse labels) nil t)))
          (when (and selected (not (string= selected "")))
            (insert (format "\\cref{%s}" selected))))
      (message "No se encontraron etiquetas definidas (\\label{}) en este documento."))))
      
;; ==================================================================
;; --- 8. FUNCIONES AUXILIARES (SNIPPETS E IA) ---
;; ==================================================================
(defun my/smart-latex-label ()
  "Inserta un \\label{} inteligente usando Tempel y pasa a modo Inserción."
  (interactive)
  (let* ((env (if (fboundp 'LaTeX-current-environment)
                  (LaTeX-current-environment)
                "document"))
         (env-prefix (cdr (assoc env '(("equation" . "eq")
                                       ("align" . "eq")
                                       ("theorem" . "thm")
                                       ("lemma" . "lem")
                                       ("proposition" . "prop")
                                       ("corollary" . "cor")
                                       ("definition" . "def")
                                       ("example" . "ejm")
                                       ("remark" . "obs")
                                       ("figure" . "fig")
                                       ("table" . "tab")
                                       ("enumerate" . "item")))))
         (sec-prefix (when (string= env "document")
                       (save-excursion
                         (beginning-of-line)
                         (cond
                          ((looking-at-p ".*\\\\chapter") "cha")
                          ((looking-at-p ".*\\\\section") "sec")
                          ((looking-at-p ".*\\\\subsection") "subsec")
                          ((looking-at-p ".*\\\\part") "part")
                          (t nil)))))
         (prefix (or env-prefix sec-prefix "")))

    ;; 4. Insertar la etiqueta con Tempel
    (if (string= prefix "")
        (tempel-insert '("\\label{" p "}" q))
      (tempel-insert `("\\label{" ,prefix ":" p "}" q)))
      
    ;; 5. PASAR A MODO INSERT AUTOMÁTICAMENTE (La Magia)
    (when (fboundp 'evil-insert-state)
      (evil-insert-state))))

(defun my/quick-add-snippet ()
  "Crea un nuevo snippet de Tempel dinámicamente con inserción ordenada."
  (interactive)
  (let* ((type (completing-read "Tipo de Snippet: " '("General" "Math" "Common")))
         (key (read-string "Trigger (lo que escribes): "))
         (content (if (use-region-p)
		      (buffer-substring-no-properties (region-beginning) (region-end))
		    (read-string "Contenido del snippet: ")))
         (file (expand-file-name "lisp/my-latex-snippets.el" user-emacs-directory)))
    (find-file file)
    (goto-char (point-min))
    ;; Encontrar la sección correcta
    (let ((search-term
	   (cond
	    ((string= type "Math")   "defvar my-latex-math-snippets")
	    ((string= type "General") "defvar my-latex-general-snippets")
	    (t                       "defvar my-latex-common-snippets"))))
      (unless (re-search-forward search-term nil t)
        (error "No se encontró '%s' en el archivo de snippets." search-term)))
    ;; Ubicar el inicio de la lista y avanzar una línea
    (search-forward "'(")
    (forward-line 1)
    ;; Encontrar posición correcta en orden alfabético
    (let ((inserted nil))
      (while (and (not inserted)
		  (re-search-forward "^\\s-*(\\([a-zA-Z-]+\\)\\s-*\\." nil t))
	(let ((existing-key (match-string 1)))
	  (when (string< key existing-key)
	    ;; Insertar antes de este elemento
	    (beginning-of-line)
	    (newline)
	    (indent-according-to-mode)
	    (insert (format "(%s . (\"%s\" q))" key
			    (replace-regexp-in-string "\"" "\\\\\"" content)))
	    (setq inserted t))))
      ;; Si no se encontró posición, añadir al final
      (unless inserted
	;; Buscar el último elemento y el cierre
	(goto-char (point-min))
	(let ((search-term
	       (cond
		((string= type "Math")   "defvar my-latex-math-snippets")
		((string= type "General") "defvar my-latex-general-snippets")
		(t                       "defvar my-latex-common-snippets"))))
	  (re-search-forward search-term nil t))
	(search-forward "'(")
	;; Buscar el `))` de cierre
	(re-search-forward "^\\s-*))" nil t)
	(beginning-of-line)
	(newline)
	(indent-according-to-mode)
	(insert (format "(%s . (\"%s\" q))" key
			(replace-regexp-in-string "\"" "\\\\\"" content))))
      (save-buffer)
      (my/reload-snippets)
      (message "Snippet '%s' agregado, guardado y recargado." key))))

(defun my/reload-snippets ()
  "Recarga el archivo de snippets de LaTeX en caliente."
  (interactive)
  (load-file (expand-file-name "lisp/my-latex-snippets.el" user-emacs-directory))
  (message "Snippets recargados correctamente."))

(defun my/jarvis-chat-session ()
  "Abre un buffer dedicado de GPTel simulando al agente JARVIS."
  (interactive)
  (gptel (generate-new-buffer-name "*JARVIS*")))

(defun my/jarvis-oneshot-command ()
  "Envía la región seleccionada o un prompt a JARVIS sin abrir chat."
  (interactive)
  (call-interactively #'gptel-send))
  
;;;###autoload
(defun my/export-config-as-txt ()
  "Copia tus archivos de configuración .el a una carpeta con el prefijo emacs- y terminación .el.txt para compartirlos con la IA."
  (interactive)
  (let* ((dest-dir (expand-file-name "txt-export" user-emacs-directory))
         (lisp-dir (expand-file-name "lisp" user-emacs-directory))
         (init-file (expand-file-name "init.el" user-emacs-directory))
         (early-init-file (expand-file-name "early-init.el" user-emacs-directory)) ;; <--- NUEVO
         ;; Recopilamos todos los .el recursivamente de la carpeta lisp
         (files (if (file-directory-p lisp-dir)
                    (directory-files-recursively lisp-dir "\\.el$")
                  nil))
         (count 0))

    ;; 1. Crea el directorio de destino si no existe.
    (unless (file-exists-p dest-dir)
      (make-directory dest-dir t))

    ;; 2. Añade los archivos maestros a la lista (init.el y early-init.el)
    (when (file-exists-p init-file)
      (push init-file files))
    (when (file-exists-p early-init-file) ;; <--- NUEVO
      (push early-init-file files))

    ;; 3. Copia y renombra cada archivo iterativamente
    (dolist (file files)
      (let* ((base-name (file-name-nondirectory file))
             (dest-file (expand-file-name (concat "emacs-" base-name ".txt") dest-dir)))
        
        ;; Copiamos el archivo al destino sobreescribiendo si ya existe
        (copy-file file dest-file t)
        (setq count (1+ count))))

    (message "✅ Exportación completada: %d archivos copiados en %s" count dest-dir)))

;;;###autoload
(defun my/export-project-tex-as-txt ()
  "Busca los archivos .tex del proyecto actual y los guarda con extensión .tex.txt."
  (interactive)
  ;; Verificamos que estamos dentro de un proyecto gestionado por Projectile
  (if (and (bound-and-true-p projectile-mode) (projectile-project-p))
      (let* ((project-root (projectile-project-root))
             ;; Creamos la ruta para la carpeta de destino
             (dest-dir (expand-file-name "txt-export" project-root))
             ;; Buscamos todos los archivos .tex recursivamente
             (tex-files (directory-files-recursively project-root "\\.tex$"))
             (count 0))
        
        ;; Si la carpeta no existe, la creamos (con permisos para subcarpetas)
        (unless (file-exists-p dest-dir)
          (make-directory dest-dir t))
        
        (dolist (file tex-files)
          ;; Evitamos procesar archivos basura de AUCTeX y no nos copiamos a nosotros mismos
          (unless (or (string-match-p (regexp-quote dest-dir) file)
                      (string-match-p "auto/" file)
                      (string-match-p "\\*region\\*" file))
            (let* ((filename (file-name-nondirectory file))
                   (new-name (concat filename ".txt"))
                   (dest-file (expand-file-name new-name dest-dir)))
              ;; Copiamos el archivo al destino y lo sobreescribimos si ya existe
              (copy-file file dest-file t)
              (setq count (1+ count)))))
        (message "✅ IA Export: %d archivos .tex.txt guardados en %s" count dest-dir))
    (user-error "No estás dentro de un proyecto de Projectile.")))

 ;;;###autoload
(defun my/export-files-by-extension (src-dir dest-dir src-ext dest-ext)
  "Busca archivos con SRC-EXT en SRC-DIR y sus subcarpetas, 
y los copia a DEST-DIR cambiándoles la extensión a DEST-EXT."
  (interactive
   (list
    (read-directory-name "Directorio origen (donde buscar): ")
    (read-directory-name "Directorio destino (donde guardar): ")
    (read-string "Extensión origen (sin punto, ej. tex o el): ")
    (read-string "Nueva extensión (sin punto, ej. txt o tex.txt): ")))
  
  (let* ((regexp (concat "\\." (regexp-quote src-ext) "$"))
         ;; Busca recursivamente todos los archivos con la extensión indicada
         (files (directory-files-recursively src-dir regexp))
         (dest-dir-exp (expand-file-name dest-dir))
         (count 0))
    
    ;; Crea el directorio destino si no existe
    (unless (file-exists-p dest-dir-exp)
      (make-directory dest-dir-exp t))
    
    (dolist (file files)
      ;; Medida de seguridad: Evitar procesar archivos que ya estén dentro de la carpeta destino
      (unless (string-prefix-p dest-dir-exp (expand-file-name file))
        (let* ((filename (file-name-nondirectory file))
               ;; Extrae el nombre base sin la extensión original
               (base (file-name-sans-extension filename))
               ;; Construye el nuevo nombre con la extensión deseada
               (new-name (concat base "." dest-ext))
               (dest-file (expand-file-name new-name dest-dir-exp)))
          ;; Copia el archivo y sobreescribe si ya existe
          (copy-file file dest-file t)
          (setq count (1+ count)))))
    (message "✅ Exportación completada: %d archivos '.%s' guardados como '.%s' en %s" 
             count src-ext dest-ext dest-dir-exp)))
;; ==================================================================
;; --- PROJECTILE ---
;; ==================================================================
(require 'projectile)
(projectile-mode 1)

;; ==================================================================
;; --- 9. AUTO-CIERRE DE PARÉNTESIS Y LLAVES ---
;; ==================================================================
(electric-pair-mode 1)

;; Opcional: Hacer que no sea tan agresivo si estás borrando código
(setq electric-pair-preserve-balance t)

(provide 'my-editor)
;;; my-editor.el ends here
