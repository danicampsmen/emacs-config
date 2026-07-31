;;; tesis-layout.el --- Gestor de Layouts de Trabajo -*- lexical-binding: t; -*-

;; Dependencias necesarias para el manejo de ventanas y visores
(require 'windmove)
(require 'project)

;; Definición del grupo de personalización
(defgroup tesis-layout nil
  "Configuración del layout de tesis."
  :group 'tools
  :prefix "tesis-layout-")

;; Variables globales
(defvar tesis-layout-history nil
  "Historial de libros de referencia.")

;; ==================================================================
;; --- LAYOUT 1: MODO TESIS COMPLETO (3 Ventanas) ---
;; ==================================================================
;;;###autoload
(defun tesis-layout-activate ()
  "Configura el layout: Código (Izq) | Tesis (Der-Arriba) | Libro (Der-Abajo).
Detecta automáticamente el PDF de la tesis, pide el libro de referencia,
y guarda el layout previo en el registro 't' por seguridad."
  (interactive)
  
  ;; 0. SALVAVIDAS: Guardar layout actual en el registro 't'
  (window-configuration-to-register ?t)
  
  (let* ((tex-buffer (current-buffer))
         (tex-filename (buffer-file-name tex-buffer))
         ;; Deduce el PDF de la tesis automáticamente
         (thesis-pdf (if tex-filename
                         (concat (file-name-sans-extension tex-filename) ".pdf")
                       nil))
         ;; Pide el libro al usuario filtrando solo por PDFs
         (book-pdf (read-file-name "Libro de referencia (PDF): " nil nil t nil
                                   (lambda (f) (string-suffix-p ".pdf" f t)))))
    
    ;; 1. Destruir el layout anterior
    (delete-other-windows)
    
    ;; 2. Activar el Modo Zen en el buffer de código 
    (when (fboundp 'my/latex-visual-mode)
      (my/latex-visual-mode 1))
    
    ;; 3. Dividir la pantalla (Mitad izquierda para código, derecha para visores)
    (split-window-right)
    
    ;; 4. Moverse a la derecha y dividir (Arriba / Abajo)
    (windmove-right)
    (split-window-below)
    
    ;; 5. Ventana superior derecha: PDF de la tesis
    (if (and thesis-pdf (file-exists-p thesis-pdf))
        (my/open-pdf thesis-pdf)
      (message "⚠️ No se encontró el PDF de la tesis. ¡Compila primero!"))
    
    ;; 6. Ventana inferior derecha: Libro de Referencia
    (windmove-down)
    (if (and book-pdf (file-exists-p book-pdf))
        (my/open-pdf book-pdf)
      (message "⚠️ Libro de referencia no válido."))
    
    ;; 7. Devolver el foco al código fuente
    (windmove-left)
    (message "✅ Layout de Tesis activado. Presiona 'C-x r j t' para restaurar tu vista anterior.")))

;; ==================================================================
;; --- LAYOUT 2: MODO ESCRITOR (2 Ventanas) ---
;; ==================================================================
;;;###autoload
(defun my/layout-writer ()
  "Divide la pantalla: Código LaTeX (Izquierda) - PDF Compilado (Derecha)."
  (interactive)
  (unless (derived-mode-p 'LaTeX-mode)
    (message "AVISO: Se recomienda abrir primero el archivo .tex"))
  (let ((pdf-file (concat (file-name-sans-extension (buffer-file-name)) ".pdf")))
    (delete-other-windows)
    (split-window-right)
    (other-window 1)
    (if (file-exists-p pdf-file)
        (my/open-pdf pdf-file)
      (message "No encuentro el PDF. Compila primero (SPC t c o ;tc)."))
    (other-window 1)
    (message "Layout Escritor activado.")))

;; ==================================================================
;; --- LAYOUT 3: MODO INVESTIGADOR (2 Ventanas con Zotero) ---
;; ==================================================================
;;;###autoload
(defun my/layout-researcher ()
  "Divide la pantalla: Código (Izquierda) - Biblioteca Zotero (Derecha)."
  (interactive)
  ;; Intentar cargar la bibliografía local del proyecto si existe
  (when (fboundp 'my/detect-project-bibliography)
    (my/detect-project-bibliography))
  
  (delete-other-windows)
  (split-window-right)
  (other-window 1)
  
  ;; Abrir el buscador de Citar
  (if (fboundp 'citar-open)
      (call-interactively #'citar-open)
    (message "Error: El paquete 'citar' no está cargado.")))

(provide 'tesis-layout)
;;; tesis-layout.el ends here
