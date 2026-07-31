;;; early-init.el --- Optimizaciones de pre-arranque -*- lexical-binding: t; -*-

;; 1. Desactivar UI nativa antes de que se dibuje (ahorra tiempo y evita parpadeos)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; 2. Acelerar el inicio retrasando la recolección de basura
(setq gc-cons-threshold most-positive-fixnum)

;; 3. Optimización de IPC para LSP/Vterm (3MB de buffer de lectura en lugar de 4KB)
(setq read-process-output-max (* 3 1024 1024))

;; 4. Compilación rápida de Autoloads en Emacs 27+
(setq package-quickstart t)

;; 5. Silenciar popups de advertencia de compilación nativa
(defvar native-comp-async-report-warnings-errors)
(setq native-comp-async-report-warnings-errors 'silent)

;; 6. Evitar el pantallazo de inicio
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)

;; 7. Desactivar la carga nativa de paquetes (ya que my-packages.el se encarga)
(setq package-enable-at-startup nil)

;; 8. Sincronizar PATH del sistema antes de cargar paquetes
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

(provide 'early-init)
;;; early-init.el ends here
