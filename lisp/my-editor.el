;;; my-editor.el --- Evil mode, Herramientas y Edición -*- lexical-binding: t; -*-

(declare-function aggressive-indent-mode "aggressive-indent" (&optional arg))
(declare-function LaTeX-fill-buffer "tex" ())
(declare-function tempel-insert "tempel" (template))
(declare-function reftex-access-scan-info "reftex" ())
(declare-function gptel "gptel" (name &optional initial interactive))
(declare-function gptel-send "gptel" (&optional arg))

;; ==================================================================
;; --- 1. EVIL MODE (Navegación Modal) ---
;; ==================================================================
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq evil-normal-state-cursor '(box "goldenrod1")
        evil-visual-state-cursor '(box "orangered")
        evil-insert-state-cursor '(bar "cyan")
        evil-replace-state-cursor '(bar "red")
        evil-emacs-state-cursor '(box "green")))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-mc
  :after evil
  :ensure t
  :config
  (global-evil-mc-mode 1))

(evil-set-initial-state 'magit-status-mode 'emacs)

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
(global-jinx-mode 1)

(put 'upcase-region 'disabled nil)

;; ==================================================================
;; --- 4. TERMINAL (VTERM) ---
;; ==================================================================
(require 'vterm)
(require 'vterm-toggle)

(setq vterm-toggle-scope 'project)
(setq vterm-environment '("TERM=xterm-256color"))

(add-hook 'vterm-mode-hook 
          (lambda ()
            (evil-set-initial-state 'vterm-mode 'insert)
            (font-lock-mode 1)      
            (display-line-numbers-mode -1) 
            (display-fill-column-indicator-mode -1)
            (setq-local global-hl-line-mode nil)
            (hl-line-mode -1)        
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
  
(let ((secrets-file (expand-file-name "my-secrets.el" (file-name-directory (or load-file-name buffer-file-name)))))
  (when (file-exists-p secrets-file)
    (require 'my-secrets secrets-file t)))

;; ==================================================================
;; --- 5. DATA SCIENCE (JULIA) ---
;; ==================================================================
(require 'julia-mode)
(require 'julia-repl)

(defun my/julia-mode-setup ()
  "Configura el entorno al abrir archivos .jl."
  (eglot-ensure)
  (julia-repl-mode 1)
  (display-line-numbers-mode 1))

(add-hook 'julia-mode-hook #'my/julia-mode-setup)

(add-hook 'julia-repl-mode-hook
          (lambda ()
            (with-eval-after-load 'vterm
              (setq julia-repl-terminal-type 'vterm))))

;; ==================================================================
;; --- 6. HERRAMIENTAS DE EDICIÓN ---
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

(defun my/insert-matrix (rows cols type)
  "Inserta una matriz dinámica usando Tempel."
  (interactive "nFilas: \nnColumnas: \nsTipo (p/b/v/V/blank): ")
  (let ((matrix-template (list (format "\\begin{%smatrix}\n" (if (string= type "blank") "" type)))))
    (dotimes (_r rows)
      (dotimes (c cols)
        (push 'p matrix-template) 
        (unless (= c (1- cols)) (push " & " matrix-template)))
      (push " \\\\\n" matrix-template))
    (push (format "\\end{%smatrix}" (if (string= type "blank") "" type)) matrix-template)
    (tempel-insert (nreverse matrix-template))))

(defun my/insert-cref ()
  "Inserta \\cref{} buscando etiquetas con Vertico/Orderless."
  (interactive)
  (reftex-access-scan-info)
  (let ((labels nil))
    (dolist (item (symbol-value reftex-docstruct-symbol))
      (when (and (listp item) (stringp (car item)))
        (push (car item) labels)))
    (if labels
        (let ((selected (completing-read "Etiqueta para \\cref: " (nreverse labels) nil t)))
          (when (and selected (not (string= selected "")))
            (insert (format "\\cref{%s}" selected))))
      (message "No se encontraron etiquetas definidas (\\label{}) en este documento."))))
      
;; ==================================================================
;; --- 7. SNIPPETS Y UTILIDADES IA ---
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

    (if (string= prefix "")
        (tempel-insert '("\\label{" p "}" q))
      (tempel-insert `("\\label{" ,prefix ":" p "}" q)))
      
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
    (let ((search-term
	   (cond
	    ((string= type "Math")   "defvar my-latex-math-snippets")
	    ((string= type "General") "defvar my-latex-general-snippets")
	    (t                       "defvar my-latex-common-snippets"))))
      (unless (re-search-forward search-term nil t)
        (error "No se encontró '%s' en el archivo de snippets." search-term)))
    (search-forward "'(")
    (forward-line 1)
    (let ((inserted nil))
      (while (and (not inserted)
		  (re-search-forward "^\\s-*(\\([a-zA-Z0-9_---]+\\)\\s-*\\..*" nil t))
	(let ((existing-key (match-string 1)))
	  (when (string< key existing-key)
	    (beginning-of-line)
	    (newline)
	    (indent-according-to-mode)
	    (insert (format "(%s . (\"%s\" q))" key
			    (replace-regexp-in-string "\"" "\\\\\"" content)))
	    (setq inserted t))))
      (unless inserted
	(goto-char (point-min))
	(let ((search-term
	       (cond
		((string= type "Math")   "defvar my-latex-math-snippets")
		((string= type "General") "defvar my-latex-general-snippets")
		(t                       "defvar my-latex-common-snippets"))))
	  (re-search-forward search-term nil t))
	(search-forward "'(")
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
   
(defun my/export-config-as-txt ()
  "Copia tus archivos .el a txt-export ignorando archivos de secretos."
  (interactive)
  (let* ((dest-dir (expand-file-name "txt-export" user-emacs-directory))
         (lisp-dir (expand-file-name "lisp" user-emacs-directory))
         (init-file (expand-file-name "init.el" user-emacs-directory))
         (early-init-file (expand-file-name "early-init.el" user-emacs-directory))
         (files (if (file-directory-p lisp-dir)
                    (directory-files-recursively lisp-dir "\\.el$")
                  nil))
         (count 0))

    (unless (file-exists-p dest-dir)
      (make-directory dest-dir t))

    (when (file-exists-p init-file) (push init-file files))
    (when (file-exists-p early-init-file) (push early-init-file files))

    (dolist (file files)
      (unless (string-match-p "secrets" (file-name-nondirectory file))
        (let* ((base-name (file-name-nondirectory file))
               (dest-file (expand-file-name (concat "emacs-" base-name ".txt") dest-dir)))
          (copy-file file dest-file t)
          (setq count (1+ count)))))

    (message "✅ Exportación completada: %d archivos copiados en %s" count dest-dir)))

(defun my/export-project-tex-as-txt ()
  "Exporta todos los archivos .tex del proyecto actual a la carpeta txt-export."
  (interactive)
  (let* ((root (if (and (bound-and-true-p projectile-mode) (projectile-project-p))
                   (projectile-project-root)
                 default-directory))
         (dest-dir (expand-file-name "txt-export" root))
         (tex-files (directory-files-recursively root "\\.tex$"))
         (count 0))
    (unless (file-exists-p dest-dir) (make-directory dest-dir t))
    (dolist (file tex-files)
      (unless (string-match-p "/txt-export/" file)
        (let* ((base (file-name-sans-extension (file-relative-name file root)))
               (safe-name (replace-regexp-in-string "/" "__" base))
               (dest (expand-file-name (concat safe-name ".txt") dest-dir)))
          (copy-file file dest t)
          (setq count (1+ count)))))
    (message "✅ %d archivos .tex exportados como .txt a %s" count dest-dir)))

;; ==================================================================
;; --- 8. PROJECTILE Y PARES ---
;; ==================================================================
(require 'projectile)
(projectile-mode 1)

(electric-pair-mode 1)
(setq electric-pair-preserve-balance t)

(provide 'my-editor)
;;; my-editor.el ends here
