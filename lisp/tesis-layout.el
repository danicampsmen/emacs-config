;;; tesis-layout.el --- Gestor de Layouts de Trabajo -*- lexical-binding: t; -*-

(require 'windmove)
(require 'transient)

(defgroup tesis-layout nil
  "Configuración del layout de tesis."
  :group 'tools
  :prefix "tesis/")

(defcustom tesis/layout-split-direction 'right
  "Dirección en la que se divide la ventana principal."
  :type '(choice (const :tag "Vertical (derecha)" right)
                 (const :tag "Horizontal (abajo)" below))
  :group 'tesis-layout)

(defcustom tesis/layout-split-ratio 0.5
  "Proporción de la pantalla para la nueva ventana.
El valor debe estar entre 0.1 y 0.9."
  :type 'float
  :group 'tesis-layout)

(defcustom tesis/layout-register ?l
  "Registro para guardar y restaurar la configuración de ventanas."
  :type 'character
  :group 'tesis-layout)

;; --- Funciones auxiliares internas

(defun tesis--get-main-pdf-file ()
  "Devuelve la ruta al PDF maestro de la tesis o documento actual."
  (let* ((master (if (fboundp 'TeX-master-file)
                     (TeX-master-file "pdf")
                   (when-let ((bfn (buffer-file-name)))
                     (concat (file-name-sans-extension bfn) ".pdf"))))
         (full-path (when master (expand-file-name master))))
    (when (and full-path (file-exists-p full-path))
      full-path)))

(defun tesis--save-window-config ()
  "Guarda la configuración de ventanas actual en el registro."
  (window-configuration-to-register tesis/layout-register)
  (message "Configuración de ventanas guardada en el registro '%c'" tesis/layout-register))

(defun tesis--setup-split ()
  "Prepara el layout base: borra ventanas y divide según la dirección configurada."
  (delete-other-windows)
  (pcase tesis/layout-split-direction
    ('right (split-window-right (round (* (window-width) tesis/layout-split-ratio))))
    ('below (split-window-below (round (* (window-height) tesis/layout-split-ratio)))))
  (other-window 1))


;; --- Comandos de Layout Individuales (sufijos para transient)

(defun tesis/layout-writer ()
  "Layout Escritor: Código | PDF Tesis."
  (interactive)
  (tesis--save-window-config)
  (if-let ((pdf-file (tesis--get-main-pdf-file)))
      (progn
        (tesis--setup-split)
        (my/open-pdf pdf-file)
        (other-window -1))
    (user-error "El PDF de la tesis no existe. ¡Compila primero!")))

(defun tesis/layout-full ()
  "Layout Completo: Código | Tesis (Arr) | Referencia (Abj)."
  (interactive)
  (tesis--save-window-config)
  (let ((book-pdf (read-file-name "Libro de referencia (PDF): " nil nil t nil
                                  (lambda (f) (string-suffix-p ".pdf" f t)))))
    (unless (and book-pdf (file-exists-p book-pdf))
      (user-error "Libro de referencia no válido"))
    (if-let ((thesis-pdf (tesis--get-main-pdf-file)))
        (progn
          (tesis--setup-split)
          (split-window-below)
          ;; Ventana superior: Tesis
          (my/open-pdf thesis-pdf)
          ;; Ventana inferior: Libro
          (other-window 1)
          (my/open-pdf book-pdf)
          ;; Foco de vuelta al código
          (other-window -2))
      (user-error "El PDF de la tesis no existe. ¡Compila primero!"))))

(defun tesis/layout-researcher ()
  "Layout Investigador: Código | Citar/Zotero."
  (interactive)
  (tesis--save-window-config)
  (tesis--setup-split)
  (when (fboundp 'my/detect-project-bibliography)
    (my/detect-project-bibliography))
  (if (fboundp 'citar-open)
      (call-interactively #'citar-open)
    (user-error "El paquete 'citar' no está disponible."))
  (other-window -1))

;; --- Comando Principal (Transient)

;;;###autoload
(transient-define-prefix tesis/set-layout ()
  "Activa un layout de trabajo para la tesis."
  ["Layout" 
   ("w" "Escritor" tesis/layout-writer)
   ("f" "Completo" tesis/layout-full)
   ("r" "Investigador" tesis/layout-researcher)])

;;;###autoload
(defun tesis/restore-layout ()
  "Restaura la configuración de ventanas guardada."
  (interactive)
  (jump-to-register tesis/layout-register))

(provide 'tesis-layout)
;;; tesis-layout.el ends here
