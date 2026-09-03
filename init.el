;;; init.el --- Controlador Maestro -*- lexical-binding: t; -*-

;; 1. Optimizaciones de Rutas (El resto se movió a early-init.el)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(setq auth-sources '("~/.authinfo"))

;; 2. Carga de Módulos (NUEVO ORDEN)
(require 'my-packages)           

(when (memq window-system '(mac ns x pgtk))
  (require 'exec-path-from-shell nil t)
  (when (fboundp 'exec-path-from-shell-initialize)
    (exec-path-from-shell-initialize)))

;; Activar GC diferido inmediatamente después de cargar paquetes
(require 'gcmh)
(setq gcmh-idle-delay 2.0
      gcmh-high-cons-threshold (* 512 1024 1024))
(gcmh-mode 1)

(require 'my-ui)                 
(require 'my-editor)             
(require 'my-ai)                 
(require 'my-pdf)                

;; 3. Ecosistema LaTeX y Escritura
(require 'my-latex-core)         
(require 'my-latex-tree-sitter)   ;; <-- Cargado antes de snippets/expansiones
(require 'my-latex-snippets)     
(require 'my-latex-expansions)   
(require 'my-latex-visuals)
(require 'my-latex-template)  

;; 4. Herramientas del Segundo Cerebro	
(require 'tesis-tools)           
(require 'tesis-layout)          
(require 'gdrive-sync)           
(require 'syncclient)            
(require 'my-second-brain)       

;; 5. ATAJOS DE TECLADO (Al final, para evitar warnings de compilación)
(require 'my-keys)  

(put 'dired-find-alternate-file 'disabled nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "🚀 Carga modular completada en %.2fs."
                     (float-time (time-subtract (current-time) before-init-time)))))

(provide 'init)
;;; init.el ends here
