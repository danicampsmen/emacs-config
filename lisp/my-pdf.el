;;; my-pdf.el --- Visor de PDFs con Zathura -*- lexical-binding: t; -*-

;; --- Detección del sistema de ventanas (usado por tesis-tools.el) ---
(defconst my/is-wayland
  (not (string-empty-p (or (getenv "WAYLAND_DISPLAY") "")))
  "Verdadero si el sistema de ventanas es Wayland.")

;; ==================================================================
;; --- FUNCIONES DE APERTURA DE PDFS (ZATHURA) ---
;; ==================================================================

(defun my/open-pdf (pdf-path)
  "Abre un PDF con Zathura (visor externo)."
  (interactive "fPDF: ")
  (let ((pdf (expand-file-name pdf-path)))
    (cond
     ((not (file-exists-p pdf))
      (message "El archivo PDF no existe: %s" pdf))
     ((not (string-suffix-p ".pdf" pdf t))
      (message "No es un archivo PDF: %s" pdf))
     ((executable-find "zathura")
      (start-process "zathura" nil "zathura" pdf)
      (message "Abriendo PDF con Zathura: %s" (file-name-nondirectory pdf)))
     (t
      (message "Zathura no está instalado. Instálalo para ver PDFs.")))))

(provide 'my-pdf)
;;; my-pdf.el ends here
