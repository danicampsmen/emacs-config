;;; my-latex-core.el --- AUCTeX, LSP y Compilación -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'server)

;; Asegurarnos de que el servidor de Emacs está corriendo para la búsqueda inversa
(unless (server-running-p)
  (server-start))

;; ==================================================================
;; --- 1. CARGA Y CONFIGURACIÓN BASE DE AUCTEX ---
;; ==================================================================
(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . my/latex-mode-setup))
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq-default TeX-engine 'luatex)

  ;; --- ACELERACIÓN DE PARSEO ---
  (setq-default TeX-auto-parse-length 4000)
  (setq-default TeX-auto-regexp-list 'LaTeX-auto-minimal-regexp-list)

  ;; --- LIMITE DE BÚSQUEDA LOCAL ---
  (setq-default TeX-arg-input-file-search nil)

  ;; --- CONFIGURACIÓN DEL VISOR: ZATHURA ---
  (setq TeX-view-program-selection '((output-pdf "Zathura")))

  ;; Habilitar SyncTeX para búsqueda Inversa/Directa
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)

  ;; ==================================================================
  ;; FIX ARQUITECTÓNICO: BLINDAJE DE COMPILACIÓN SILENCIOSA
  ;; ==================================================================
  ;; Mantenemos el Zen Mode ocultando la consola de compilación por defecto
  (setq-default TeX-show-compilation nil)

  ;; Hook dinámico: Este anclaje de AUCTeX SOLO se dispara si NO hubo errores.
  ;; Lo aprovechamos para que Zathura se abra/actualice automáticamente.
  (add-hook 'TeX-after-compilation-finished-functions
            (lambda (output-file)
              ;; ⚠️ FIX: AUCTeX dispara este hook desde el buffer oculto del proceso.
              ;; Usamos 'with-current-buffer' para volver al buffer de tu código (.tex)
              ;; y así capturar la línea exacta del cursor para el SyncTeX.
              (when (bound-and-true-p TeX-command-buffer)
                (with-current-buffer TeX-command-buffer
                  (message "✅ Compilación exitosa. Sincronizando Zathura...")
                  (my/tex-view-with-focus)))))

  ;; --- GESTIÓN NATIVA DE ERRORES ---
  ;; 1. Forzar a AUCTeX a parsear todo el archivo .log en lugar de la terminal
  (setq TeX-parse-all-errors t)

  ;; 2. Activar la interfaz de diagnóstico SOLO si ocurren errores reales 
  (setq TeX-error-overview-open-after-TeX-run t)
  (setq TeX-error-overview-setup nil) ;; Mostrar dividiendo la ventana actual
  )

;; ==================================================================
;; --- 2. PREPARACIÓN DEL ENTORNO DE EDICIÓN (.tex) ---
;; ==================================================================
(defun my/latex-mode-setup ()
  "Configuraciones fundamentales que se ejecutan al abrir un archivo LaTeX."
  (message "Configurando núcleo de LaTeX-mode...")
  (abbrev-mode 1)
  (auto-save-mode 1)
  (auto-fill-mode 1)
  (setq-local fill-column 100)
  (setq-local LaTeX-fill-column 100)
  (visual-line-mode 1)

  ;; --- ACTIVACIÓN DE REFTEX ---
  (turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)

  ;; --- REGLAS DE INDENTACIÓN ---
  (setq-local fill-indent-according-to-mode t)
  (setq-local tab-width 4)
  (setq-local indent-tabs-mode nil)
  (setq-local LaTeX-indent-level 4)
  (setq-local LaTeX-item-indent 0)
  (setq-local TeX-brace-indent-level 4)
  (setq-local TeX-electric-math (cons "  $" "$  "))
  (setq-local LaTeX-fill-break-at-separators '("\\}" "\\]"))

  (make-local-variable 'LaTeX-indent-environment-list)
  (add-to-list 'LaTeX-indent-environment-list '("equation" current-indentation))
  (add-to-list 'LaTeX-indent-environment-list '("align" current-indentation))
  (add-to-list 'LaTeX-indent-environment-list '("tikzcd" current-indentation))

  ;; --- ACTIVAR SERVIDOR DE LENGUAJE (LSP) ---
  (eglot-ensure)

  ;; --- SUPERÍNDICES Y SUBÍNDICES VISUALES ---
  (setq font-latex-fontify-script t) ;; Oculta las llaves y sube/baja los caracteres
  (setq font-latex-script-display '((raise -0.3) . (raise 0.3))))

;; ==================================================================
;; --- 3. SERVIDOR DE LENGUAJE (EGLOT + TEXLAB) ---
;; ==================================================================
(require 'eglot)
(with-eval-after-load 'eglot
  ;; Evita que Eglot guarde un historial infinito de mensajes JSON
  (setq eglot-events-buffer-config '(:size 0 :format full))
  ;; Opcional: silenciar logs por completo para máxima velocidad
  (fset #'jsonrpc--log-event #'ignore)
  (setq eglot-connect-timeout 60)

  (setq eglot-server-programs
        (cl-remove-if (lambda (p) (memq 'LaTeX-mode (ensure-list (car p))))
                      eglot-server-programs))

  (add-to-list 'eglot-server-programs
               '((tex-mode LaTeX-mode) . ("texlab" :initializationOptions
                                          (:texlab (:chktex (:onOpenAndSave t)
                                                    :forwardSearch (:executable "zathura"
                                                                    :args ["--synctex-forward" "%l:1:%f" "%p"])))))))

;; ==================================================================
;; --- 4. FUNCIONES DE COMPILACIÓN Y VISUALIZACIÓN ---
;; ==================================================================
;; Asegurar que Emacs y LaTeX siempre encuentren latexminted y TeX Live
(defcustom my/texlive-year "2026"
  "Año de instalación de TeX Live para rutas de ejecutables."
  :type 'string
  :group 'my-latex)

(let* ((texlive-bin (format "/usr/local/texlive/%s/bin/x86_64-linux" my/texlive-year))
       (fallback-bin (executable-find "lualatex")))
  (add-to-list 'exec-path (expand-file-name "~/.local/bin"))
  (if (file-directory-p texlive-bin)
      (progn
        (add-to-list 'exec-path texlive-bin)
        (setenv "PATH" (concat (expand-file-name "~/.local/bin") ":"
                               texlive-bin ":" (getenv "PATH"))))
    ;; Fallback: si la ruta no existe, confiar en executable-find
    (when fallback-bin
      (add-to-list 'exec-path (file-name-directory fallback-bin)))))

(defun my/latex-compile-and-view-on-save ()
  "Compila con latexmk (LuaTeX). Solo se ejecuta si el archivo es .tex."
  (interactive)
  (when (and (derived-mode-p 'LaTeX-mode)
             (buffer-file-name)
             (string= (file-name-extension (buffer-file-name)) "tex"))
    (save-restriction
      (widen)
      (let* ((master-file (TeX-master-file t))
             (extra-opts (or TeX-command-extra-options ""))
             ;; Compilación ultrarrápida SIN -shell-escape
             (command (format "latexmk -pdflua %s -synctex=1 -interaction=nonstopmode %s"
                              extra-opts
                              (shell-quote-argument master-file))))
        (compile command)))))

(defun my/tex-view-with-focus ()
  "Abre o actualiza el PDF en Zathura y salta a la línea actual con SyncTeX."
  (interactive)
  (if (and (buffer-file-name) (TeX-master-file "pdf"))
      (let* ((pdf-file (expand-file-name (TeX-master-file "pdf")))
             (tex-file (expand-file-name (buffer-file-name)))
             (line (line-number-at-pos)))
        (if (executable-find "zathura")
            (progn
              (start-process "zathura-focus" nil "zathura" "--synctex-forward"
                             (format "%d:1:%s" line tex-file) pdf-file)
              (message "Zathura: Saltando a línea %d..." line))
          (message "Zathura no está instalado.")))
    (message "Error: No se encontró el PDF. ¡Compila primero!")))

;; ==================================================================
;; --- 5. HABILITAR MATEMÁTICAS EN ENTORNOS PERSONALIZADOS (OPTIDEF)
;; ==================================================================
(with-eval-after-load 'texmathp
  ;; Añadimos los entornos de optimización a la lista de matemáticas de AUCTeX
  (dolist (env '("mini" "mini*" "maxi" "maxi*" "argmini" "argmini*" "argmaxi" "argmaxi*"))
    (add-to-list 'texmathp-tex-commands (list env 'env-on)))

  ;; Forzamos a AUCTeX a recompilar su base de datos interna de entornos
  (texmathp-compile))

(provide 'my-latex-core)
;;; my-latex-core.el ends here
