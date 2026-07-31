;;; my-ui.el --- Interfaz base -*- lexical-binding: t; -*-

;; --- BARRAS Y GUI ---
(tool-bar-mode -1)
(menu-bar-mode 1)
(scroll-bar-mode -1)
(setq visible-bell t)
(global-hl-line-mode 1)
(save-place-mode 1) ; Recordar posición del cursor
(require 'minions) 
(minions-mode 1)

;; ==================================================================
;; --- INTEGRACIÓN CON EL PORTAPAPELES DEL SISTEMA (WAYLAND/X11) ---
;; ==================================================================
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq save-interprogram-paste-before-kill t)

;; ==================================================================
;; --- PANTALLA DE INICIO PERSONALIZADA ---
;; ==================================================================
;; 1. Desactivar la pantalla de inicio (splash screen) nativa por completo
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)

;; 2. Definir tu nueva pantalla de inicio (Elige una opción)

;; Opción A: Iniciar siempre en tu archivo maestro "vida.org" de tu agenda
;; (setq initial-buffer-choice "~/Documentos/Agenda/vida.org")

;; Opción B: Descomenta esto si prefieres iniciar en un buffer *scratch* totalmente en blanco
(setq initial-scratch-message "")

;; --- LÍMITE DE COLUMNA Y LÍNEAS ---
(setq-default fill-column 120)
(global-display-fill-column-indicator-mode 1)
(set-face-attribute 'fill-column-indicator nil :foreground "#333333")

(global-font-lock-mode 1)
;; --- NUEVO: Excluir a vterm del "aspirador" de colores global ---
(setq font-lock-global-modes '(not vterm-mode)) 

(setq font-lock-maximum-decoration t)
(setq-default tab-width 4 indent-tabs-mode 1)

;; --- RENDIMIENTO Y BACKUPS ---
(setq fast-but-imprecise-scrolling t)
(setq jit-lock-defer-time 0.1)
(setq redisplay-skip-fontification-on-input nil)
(setq undo-limit (* 8 1024 1024))
(setq undo-strong-limit (* 128 1024 1024))

(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves" user-emacs-directory) t))
      create-lockfiles nil)

;; --- COMPLETADO BASE (Vertico/Orderless/Marginalia) ---
(require 'vertico)
(vertico-mode 1)             ; Muestra la lista vertical AUTOMÁTICAMENTE

(require 'marginalia)
(marginalia-mode 1)          ; Añade descripciones bonitas a la derecha de las opciones

(require 'orderless)
(setq completion-styles '(orderless basic))
(setq completion-category-defaults nil)
(setq completion-category-overrides '((file (styles . (partial-completion)))))

;; --- GESTIÓN DE ARCHIVOS Y VENTANAS ---
(require 'recentf)
(setq recentf-max-saved-items 200)
(setq recentf-exclude '("~/.emacs.d/var/" "~/.emacs.d/elpa/" "/tmp/" "/ssh:"))
(recentf-mode 1)

(require 'winner)
(winner-mode 1)

(require 'savehist)
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'tesis-layout-last-thesis)
(add-to-list 'savehist-additional-variables 'tesis-layout-last-book)
(add-to-list 'savehist-additional-variables 'tesis-layout-history)

;; Enrutar TODOS los buffers de compilación y logs de AUCTeX a un cajón inferior
(add-to-list 'display-buffer-alist
             '("^\\*\\(brain-compile\\|compilation\\|.*LaTeX.*\\|.*TeX.*\\|biber.*\\|BibTeX.*\\|latexmk.*\\|.*output.*\\)\\*$"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 12)
               (preserve-size . (nil . t))
               (window-parameters . ((no-other-window . t)
                                     (no-delete-other-windows . t)))))

;; --- DIRED ---
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-dwim-target t)
(setq dired-listing-switches "-agho --group-directories-first")
(setq dired-auto-revert-buffer t)
(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode 1)
            (hl-line-mode 1)))

;; --- TIPOGRAFÍAS ---

;; 1. Fuente Principal: Iosevka para todo el texto
(set-face-attribute 'default t
                    :family "CMU Typewriter Text"
                    :slant 'normal
                    :weight 'light  ;; 'normal o 'medium suelen verse mejor en Iosevka
                    :height '150
                    :width 'normal)

;; 2. El Truco (Fallback Matemático): STIX Two Math solo para lo que Iosevka no tenga
(set-fontset-font t 'unicode "STIX Two Math" nil 'append)
(set-fontset-font t 'symbol  "STIX Two Math" nil 'append)

;; 3. Fallback de Iconos (Evita cuadraditos en la modeline/nerd-icons)
(when (member "Symbols Nerd Font Mono" (font-family-list))
  (set-fontset-font t 'symbol "Symbols Nerd Font Mono" nil 'append)
  (set-fontset-font t 'unicode "Symbols Nerd Font Mono" nil 'append))

(setq-default line-spacing 4) ;; Reduje un poco el espaciado porque Iosevka es alta

;; --- TEMAS Y MODELINE ---
(require 'modus-themes)
(load-theme 'modus-vivendi-deuteranopia t)

(require 'doom-modeline)
(setq doom-modeline-height 30)
(setq doom-modeline-minor-modes t)
(doom-modeline-mode 1)

;; --- HIGHLIGHT TODO ---
(require 'hl-todo)
(global-hl-todo-mode 1)
(setq hl-todo-keyword-faces
      '(("TODO"   . "#ff9900")
        ("FIXME"  . "#ff0000")
        ("DEBUG"  . "#a020f0")
        ("NOTE"   . "#00ccff")))
        
(global-auto-revert-mode 1)	
(setq global-auto-revert-non-file-buffers t)	

;; Auto-instalador oficial de nerd-icons (Verifica si la fuente existe en Ubuntu)
(when (member system-type '(gnu gnu/linux))
  (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
    (nerd-icons-install-fonts t)))

;; ==================================================================
;; --- 1. CONFIGURACIÓN INICIAL DE INICIO SIN BARRA DE TÍTULO ---
;; ==================================================================
;; Hace que todas las ventanas de Emacs se inicien por defecto sin la barra del OS
(add-to-list 'default-frame-alist '(undecorated . t))

;; ==================================================================
;; --- 2. MOTOR DE DESACTIVACIÓN DEL MOUSE ---
;; ==================================================================
(defvar my-no-mouse-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Redirige todos los eventos físicos del mouse a 'ignore'
    (dolist (key '([mouse-1] [down-mouse-1] [drag-mouse-1] [double-mouse-1] [triple-mouse-1]
                   [mouse-2] [down-mouse-2] [drag-mouse-2] [double-mouse-2] [triple-mouse-2]
                   [mouse-3] [down-mouse-3] [drag-mouse-3] [double-mouse-3] [triple-mouse-3]
                   [mouse-4] [down-mouse-4] [mouse-5] [down-mouse-5]
                   [wheel-up] [wheel-down] [double-wheel-up] [double-wheel-down]
                   [drag-n-drop] [mode-line] [header-line]))
      (define-key map key #'ignore))
    map)
  "Mapa de teclas para anular por completo las interacciones del mouse.")

(define-minor-mode my-no-mouse-mode
  "Modo global que deshabilita clics, arrastres y scroll con el mouse."
  :init-value nil
  :global t
  :keymap my-no-mouse-mode-map)

;; Oculta el puntero del mouse al comenzar a escribir
(setq make-pointer-invisible t)

;; ==================================================================
;; --- 3. MODO TERMINAL-GUI (CONMUTADOR DE ENTORNO) ---
;; ==================================================================
(define-minor-mode my-terminal-gui-mode
  "Alterna una experiencia puramente de teclado y minimalista en modo gráfico."
  :init-value nil
  :global t
  (if my-terminal-gui-mode
      (progn
        ;; Activar restricciones de terminal
        (my-no-mouse-mode 1)
        (set-frame-parameter nil 'undecorated t)
        (menu-bar-mode -1)
        (message "Modo Terminal-GUI activo: Mouse desactivado y decoraciones ocultas."))
    ;; Restaurar entorno GUI estándar
    (my-no-mouse-mode -1)
    (set-frame-parameter nil 'undecorated nil)
    (menu-bar-mode 1)
    (message "Modo GUI estándar restaurado.")))
    
;; ==================================================================
;; --- ADAPTACIÓN PARA EL REFRESCO DE BORDES EN EL GESTOR DE VENTANAS ---
;; ==================================================================
;(defun my/refresh-frame-decorations (frame param value)
;  "Refresca el marco si se oculta o muestra la barra de título en Wayland/GNOME."
 ; (when (eq param 'undecorated)
  ;  (make-frame-invisible frame)
   ; (make-frame-visible frame)))

;(advice-add 'set-frame-parameter :after #'my/refresh-frame-decorations)


(provide 'my-ui)
;;; my-ui.el ends here
