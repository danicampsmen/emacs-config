;;; my-latex-core.el --- AUCTeX, LSP y Compilación -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'server)

(unless (server-running-p)
  (server-start))

;; ==================================================================
;; --- 1. CARGA Y CONFIGURACIÓN BASE DE AUCTEX ---
;; ==================================================================
(defcustom my/latex-pdf-viewer "zathura"
  "El ejecutable preferido para visualizar archivos PDF."
  :type 'string
  :group 'my-latex)

(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . my/latex-mode-setup))
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq-default TeX-engine 'luatex)

  (setq-default TeX-auto-parse-length 4000)
  (setq-default TeX-auto-regexp-list 'LaTeX-auto-minimal-regexp-list)
  (setq-default TeX-arg-input-file-search nil)

  (setq TeX-view-program-list `((,my/latex-pdf-viewer
                                 (,my/latex-pdf-viewer " %o"))))
  (setq TeX-view-program-selection '((output-pdf "Zathura")))

  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)

  (setq-default TeX-show-compilation nil)

  (add-hook 'TeX-after-compilation-finished-functions
            (lambda (_output-file)
              (when (bound-and-true-p TeX-command-buffer)
                (with-current-buffer TeX-command-buffer
                  (message "✅ Compilación exitosa. Sincronizando Zathura...")
                  (my/tex-view-with-focus)))))

  (setq TeX-parse-all-errors t)
  (setq TeX-error-overview-open-after-TeX-run t)
  (setq TeX-error-overview-setup nil))

;; ==================================================================
;; --- 2. PREPARACIÓN DEL ENTORNO DE EDICIÓN (.tex) ---
;; ==================================================================
(defun my/latex-mode-setup ()
  "Configuraciones fundamentales que se ejecutan al abrir un archivo LaTeX."
  (message "Configurando núcleo de LaTeX-mode...")
  (abbrev-mode 1)
  (auto-save-mode 1)
  (auto-fill-mode -1)
  (setq-local fill-column 120)
  (setq-local LaTeX-fill-column 120)
  
  ;; 1. Envoltura visual estricta (evita que la pantalla se desplace hacia los lados)
  (visual-line-mode 1)
  (setq-local auto-hscroll-mode nil)          ;; <-- Desactiva el desplazamiento horizontal
  (set-window-hscroll nil 0)                   ;; <-- Resetea la vista a la columna 0
  (setq-local truncate-lines nil)

  (turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)

  ;; 2. Reglas de sangría
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local LaTeX-indent-level 4)
  (setq-local LaTeX-item-indent 0)
  (setq-local TeX-brace-indent-level 0)
  
  (eglot-ensure)
  (setq font-latex-fontify-script t)
  (setq font-latex-script-display '((raise -0.3) . (raise 0.3))))

;; ==================================================================
;; --- 3. SERVIDOR DE LENGUAJE (EGLOT + TEXLAB) ---
;; ==================================================================
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((tex-mode LaTeX-mode) . ("texlab" :initializationOptions
                                          (:texlab (:chktex (:onOpenAndSave t)
                                                    :forwardSearch (:executable ,my/latex-pdf-viewer
                                                                    :args ["--synctex-forward" "%l:1:%f" "%p"]))))))
  ;; Desactivar formateo de TexLab para que Tree-sitter tenga el control total
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (setq-local eglot-ignored-server-capabilities
                          (append eglot-ignored-server-capabilities
                                  '(:documentFormatting :documentRangeFormatting))))))

;; ==================================================================
;; --- 4. RUTAS Y COMPILACIÓN ---
;; ==================================================================
(defcustom my/texlive-bin-path
  (or (file-name-directory (or (executable-find "lualatex") ""))
      "/usr/local/texlive/bin/x86_64-linux")
  "Ruta al binario de TeX Live."
  :type 'directory
  :group 'my-latex)

(let ((local-bin (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path local-bin)
  (add-to-list 'exec-path (file-name-as-directory my/texlive-bin-path))
  (setenv "PATH" (concat local-bin ":" my/texlive-bin-path ":" (getenv "PATH"))))

(defun my/tex-view-with-focus ()
  "Abre o actualiza el PDF en el visor y salta a la línea actual con SyncTeX."
  (interactive)
  (let* ((tex-file (buffer-file-name))
          (pdf-file (and tex-file (concat (file-name-sans-extension tex-file) ".pdf")))
          (line (line-number-at-pos)))
     (cond
      ((not tex-file)
       (message "Buffer no asociado a fichero."))
      ((not (and pdf-file (file-exists-p pdf-file)))
       (message "PDF no encontrado: %s. Compila primero." pdf-file))
      ((executable-find my/latex-pdf-viewer)
       (start-process (format "%s-focus" my/latex-pdf-viewer) nil my/latex-pdf-viewer
                      "--synctex-forward" (format "%d:1:%s" line tex-file) pdf-file)
       (message "📄 %s: saltando a línea %d..." (capitalize my/latex-pdf-viewer) line))
      (t (message "Visor de PDF '%s' no encontrado." my/latex-pdf-viewer)))))

(with-eval-after-load 'texmathp
  (dolist (env '("mini" "mini*" "maxi" "maxi*" "argmini" "argmini*" "argmaxi" "argmaxi*"))
    (add-to-list 'texmathp-tex-commands (list env 'env-on)))
  (texmathp-compile))

(provide 'my-latex-core)
;;; my-latex-core.el ends here
