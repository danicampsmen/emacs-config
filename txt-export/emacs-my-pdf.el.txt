;;; my-pdf.el --- Visor de PDFs con Zathura -*- lexical-binding: t; -*-

;; --- Detección del sistema de ventanas (usado por tesis-tools.el) ---
(defconst my/is-wayland
  (not (string-empty-p (or (getenv "WAYLAND_DISPLAY") "")))
  "Verdadero si el sistema de ventanas es Wayland.")

;; ==================================================================
;; --- FUNCIONES DE APERTURA DE PDFS (ZATHURA) ---
;; ==================================================================

(defun my/open-pdf (pdf-path)
  "Abre un PDF con un visor externo, prefiriendo Zathura."
  (interactive "fPDF: ")
  (let ((pdf (expand-file-name pdf-path)))
    (unless (and (file-exists-p pdf) (string-suffix-p ".pdf" pdf t))
      (message "Ruta inválida o no es un archivo PDF: %s" pdf)
      (progn))
    (let ((viewer (or (executable-find "zathura")
                      (executable-find "xdg-open"))))
      (if viewer
          (progn
            (start-process "pdf-viewer" nil viewer pdf)
            (message "Abriendo PDF con %s: %s" (file-name-nondirectory viewer) (file-name-nondirectory pdf)))
        (message "No se encontró un visor de PDF (Zathura, xdg-open).")))))

(provide 'my-pdf)
;;; my-pdf.el ends here
