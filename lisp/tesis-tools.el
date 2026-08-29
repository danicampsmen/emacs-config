;;; tesis-tools.el --- Herramientas auxiliares para Tesis -*- lexical-binding: t; -*-

(require 'windmove) 
(require 'projectile) 
(require 'citar)

(defgroup tesis-tools nil
  "Herramientas para la escritura de la tesis y layouts."
  :group 'tex
  :prefix "tesis-tools-")

(defcustom tesis-tools-author-name "Tu Nombre"
  "Nombre del autor para insertar en notas."
  :type 'string
  :group 'tesis-tools)

(defcustom tesis-tools-figures-directory "figuras"
  "Nombre del directorio donde se guardan las figuras del proyecto."
  :type 'string
  :group 'tesis-tools)

(defcustom tesis-tools-todo-keywords '("TODO" "NOTE" "FIXME" "HACK" "XXX")
  "Lista de palabras clave para buscar en el reporte de TODOs."
  :type '(repeat string)
  :group 'tesis-tools)

;; ==================================================================
;; --- 1. HERRAMIENTAS DE REDACCIÓN Y UTILIDADES
;; ==================================================================

;;;###autoload
(defun tesis-tools-status ()
  "Muestra un reporte de progreso (conteo de palabras)."
  (interactive)
  (message "Progreso Buffer: %d palabras." (count-words (point-min) (point-max))))

;;;###autoload
(defun tesis-tools-insert-note ()
  "Inserta un comentario de nota con fecha y autor."
  (interactive)
  (insert (format "%% NOTE (%s) [%s]: "
                  tesis-tools-author-name
                  (format-time-string "%Y-%m-%d"))))

;;;###autoload
(defun tesis-tools-wrap-in-environment (env-name)
  "Envuelve la región seleccionada en un entorno LaTeX y la indenta."
  (interactive "sNombre del entorno: ")
  (if (use-region-p)
      (let ((start (region-beginning))
            (end (region-end)))
        (save-excursion
          (goto-char end)
          (insert "\n\\end{" env-name "}")
          (goto-char start)
          (insert "\\begin{" env-name "}\n")
          ;; Indentar el contenido del nuevo entorno
          (indent-region (line-beginning-position) (line-end-position (1- end)))))
    (message "Región no activa.")))

;; ==================================================================
;; --- 2. LAYOUTS RÁPIDOS PARA ESCRITURA E INVESTIGACIÓN
;; ==================================================================
;; (Las definiciones de layouts residen en tesis-layout.el)

;; ==================================================================
;; --- 3. INTEGRACIÓN CON CITAR / ZOTERO MAGIA
;; ==================================================================
;; (Configuraciones de Zotero manejadas por my-second-brain.el)

;;;###autoload
(defun tesis-tools-insert-citation-advanced ()
  "Inserta una cita con Citar, preguntando tipo, número y página."
  (interactive)
  (let* ((tipos '(("Teorema" . "Teo.") ("Proposición" . "Prop.") ("Lema" . "Lem.")
                 ("Corolario" . "Cor.") ("Definición" . "Def.") ("Ejemplo" . "Ej.")
                 ("Observación" . "Obs.") ("Ecuación" . "Ec.") ("Sección" . "Sec.")
                 ("Capítulo" . "Cap.") ("Apéndice" . "Ap.")))
         (tipo-str (completing-read "Tipo de referencia (o abreviatura): "
                                    (append (mapcar #'car tipos) (mapcar #'cdr tipos))
                                    nil nil))
         (numero (unless (string-empty-p tipo-str)
                   (read-string (format "Número de %s: " tipo-str))))
         (pagina (read-string "Página (opcional): "))
         (refs (citar-select-ref))
         (keys (mapconcat #'identity refs ",")))
    (when keys
      (let ((elemento (if (and tipo-str numero (not (string-empty-p numero)))
                          (format "%s %s" tipo-str numero)
                        tipo-str))
            (pagina-str (unless (string-empty-p pagina)
                          (format "p. %s" pagina))))
        (insert " "
                (format "\\cite%s{%s}"
                        (if (or elemento pagina-str)
                            (format "[%s]" (string-trim (concat elemento " " pagina-str)))
                          "")
                        keys))))))

;; ==================================================================
;; --- 4. INTEGRACIÓN INKSCAPE -> PDF_TEX (MÁXIMO RENDIMIENTO)
;; ==================================================================

(defcustom tesis-tools-figure-canvas-width 75
  "Ancho estándar en milímetros (mm) del lienzo de figuras en Inkscape (75mm = estándar de columna)."
  :type 'integer
  :group 'tesis-tools)

(defcustom tesis-tools-figure-canvas-height 45
  "Alto estándar en milímetros (mm) del lienzo de figuras en Inkscape."
  :type 'integer
  :group 'tesis-tools)

(defun tesis-tools--generate-svg-template (&optional width height)
  "Genera la plantilla SVG inicial con dimensiones proporcionales estándar."
  (let ((w (or width tesis-tools-figure-canvas-width))
        (h (or height tesis-tools-figure-canvas-height)))
    (format "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<svg
   xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
   xmlns:cc=\"http://creativecommons.org/ns#\"
   xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
   xmlns:svg=\"http://www.w3.org/2000/svg\"
   xmlns=\"http://www.w3.org/2000/svg\"
   viewBox=\"0 0 %d %d\"
   width=\"%dmm\"
   height=\"%dmm\"
   version=\"1.1\">
</svg>
" w h w h)))

(defun tesis-tools--project-root ()
  "Obtiene la raíz del proyecto (Projectile / Git) o el directorio actual."
  (or (when (fboundp 'projectile-project-root)
        (projectile-project-root))
      (locate-dominating-file default-directory ".git")
      default-directory))

(defun tesis-tools--export-svg-to-pdftex (svg-file pdf-file)
  "Exporta de forma asíncrona SVG-FILE a PDF-FILE y .pdf_tex usando Inkscape."
  (let ((cmd (format "inkscape --export-area-drawing --export-filename=%s --export-latex %s"
                     (shell-quote-argument pdf-file)
                     (shell-quote-argument svg-file))))
    (start-process-shell-command "inkscape-export-pdftex" "*Inkscape Export*" cmd)))

;;;###autoload
(defun tesis-tools-insert-inkscape-pdftex ()
  "Crea una figura Inkscape (.svg), abre la GUI y exporta a .pdf_tex al guardar."
  (interactive)
  (let* ((project-root (tesis-tools--project-root))
         (fig-dir (expand-file-name tesis-tools-figures-directory project-root))
         (raw-name (read-string "Nombre de la figura (sin extensión): "))
         (fig-name (replace-regexp-in-string "[[:space:]]+" "-" (string-trim raw-name))))
    (when (string-empty-p fig-name)
      (user-error "El nombre de la figura no puede estar vacío"))
    (unless (file-directory-p fig-dir)
      (make-directory fig-dir t))
    (let* ((svg-file (expand-file-name (concat fig-name ".svg") fig-dir))
           (pdf-file (expand-file-name (concat fig-name ".pdf") fig-dir)))
      ;; 1. Crear plantilla inicial si el SVG no existe
      (unless (file-exists-p svg-file)
        (with-temp-file svg-file
          (insert (tesis-tools--generate-svg-template))))
      ;; 2. Exportación inicial de base
      (tesis-tools--export-svg-to-pdftex svg-file pdf-file)
      ;; 3. Abrir la interfaz gráfica de Inkscape con vigilante de auto-exportación al cerrar
      (let ((proc (start-process-shell-command
                   "inkscape-gui" nil
                   (format "inkscape %s" (shell-quote-argument svg-file)))))
        (set-process-sentinel
         proc
         (lambda (p event)
           (when (string-match-p "\\(?:finished\\|exited\\)" event)
             (tesis-tools--export-svg-to-pdftex svg-file pdf-file)
             (message "✅ Figura '%s.pdf_tex' exportada con éxito desde Inkscape." fig-name)))))
      (message "🎨 Abriendo Inkscape para '%s'..." (file-relative-name svg-file project-root))
      ;; 4. Insertar el bloque de código LaTeX en el buffer
      (insert (format (string-join
                       '("\\begin{figure}[htpb]"
                         "  \\centering"
                         "  \\incfig{%s}"
                         "  \\caption{%s}"
                         "  \\label{fig:%s}"
                         "\\end{figure}") "\n")
                      fig-name raw-name fig-name)))))

;;;###autoload
(defun tesis-tools-edit-inkscape-pdftex ()
  "Edita el SVG asociado al .pdf_tex bajo el cursor en Inkscape y lo re-exporta."
  (interactive)
  (let ((fig-name
         (save-excursion
           (let ((line-str (thing-at-point 'line t))
                 (regex "\\\\incfig\\(?:\\[[^]]*\\]\\)?{\\([^}]+\\)}"))
             (cond
              ;; 1. En la línea actual
              ((and line-str (string-match regex line-str))
               (match-string 1 line-str))
              ;; 2. En el entorno figure / párrafo circundante
              ((re-search-backward "\\\\begin{figure}" (max (point-min) (- (point) 500)) t)
               (when (re-search-forward regex (min (point-max) (+ (point) 500)) t)
                 (match-string 1)))
              ;; 3. Buscar hacia adelante cerca del cursor
              ((re-search-forward regex (min (point-max) (+ (point) 300)) t)
               (match-string 1)))))))
    (if fig-name
        (let* ((filename (string-trim (replace-regexp-in-string "\\.pdf_tex\\'" "" fig-name)))
               (project-root (tesis-tools--project-root))
               (fig-dir (expand-file-name tesis-tools-figures-directory project-root))
               (svg-file (expand-file-name (concat filename ".svg") fig-dir))
               (pdf-file (expand-file-name (concat filename ".pdf") fig-dir)))
          (if (file-exists-p svg-file)
              (let ((proc (start-process-shell-command
                           "inkscape-edit" nil
                           (format "inkscape %s" (shell-quote-argument svg-file)))))
                (set-process-sentinel
                 proc
                 (lambda (p event)
                   (when (string-match-p "\\(?:finished\\|exited\\)" event)
                     (tesis-tools--export-svg-to-pdftex svg-file pdf-file)
                     (message "✅ Figura '%s.pdf_tex' re-exportada con éxito desde Inkscape." filename))))
                (message "🎨 Abriendo '%s' en Inkscape..." (file-relative-name svg-file project-root)))
            (user-error "El archivo SVG no existe: %s" svg-file)))
      (user-error "❌ No se encontró \\incfig{...} en la línea ni en la figura actual."))))

;; ==================================================================
;; --- MATH PAD FLOTANTE PARA INKSCAPE ---
;; ==================================================================

(defvar tesis-tools--math-pad-buffer-name "*Inkscape Math Pad*")

(defun tesis-tools--trigger-wayland-paste (&optional text)
  "Envía la señal de pegado al demonio de wayland-paste de forma inmediata y asíncrona."
  (let ((paste-bin (expand-file-name "~/.local/bin/wayland-paste")))
    (when (file-executable-p paste-bin)
      (start-process "inkscape-paste" nil paste-bin (or text "")))))

;;;###autoload
(defun tesis-tools-math-pad-confirm ()
  "Copia la fórmula del Math Pad al portapapeles de forma instantánea, cierra el marco y pega en Inkscape."
  (interactive)
  (let* ((buf (get-buffer tesis-tools--math-pad-buffer-name))
         (raw-text (if buf
                       (with-current-buffer buf
                         (buffer-substring-no-properties (point-min) (point-max)))
                     ""))
         (text (string-trim raw-text))
         (current-fr (selected-frame)))
    ;; 1. Copiar al portapapeles interno de Emacs
    (unless (string-empty-p text)
      (kill-new text)
      (when (fboundp 'gui-set-selection)
        (gui-set-selection 'CLIPBOARD text)))

    ;; 2. Disparar el portapapeles del sistema y pegado en Inkscape a través del demonio aislado
    (unless (string-empty-p text)
      (tesis-tools--trigger-wayland-paste text))

    ;; 3. Cerrar el marco flotante al instante
    (when (active-minibuffer-window)
      (abort-recursive-edit))
    (condition-case nil
        (delete-frame current-fr t)
      (error
       (when buf (kill-buffer buf))))))

;;;###autoload
(defun tesis-tools-math-pad-cancel ()
  "Cancela y cierra el Math Pad sin copiar ni pegar."
  (interactive)
  (let ((current-fr (selected-frame))
        (buf (get-buffer tesis-tools--math-pad-buffer-name)))
    (when (active-minibuffer-window)
      (abort-recursive-edit))
    (condition-case nil
        (delete-frame current-fr t)
      (error
       (when buf (kill-buffer buf))))))

(defun tesis-tools--center-frame (&optional frame)
  "Centra el marco FRAME (o el seleccionado) en el monitor activo."
  (let* ((fr (or frame (selected-frame))))
    (when (and fr (frame-live-p fr) (display-graphic-p fr))
      (let* ((attrs (frame-monitor-attributes fr))
             (workarea (cdr (assq 'workarea attrs)))
             (geom (or workarea (cdr (assq 'geometry attrs))))
             (mon-x (if geom (nth 0 geom) 0))
             (mon-y (if geom (nth 1 geom) 0))
             (mon-w (if geom (nth 2 geom) (display-pixel-width fr)))
             (mon-h (if geom (nth 3 geom) (display-pixel-height fr)))
             (fr-w (frame-pixel-width fr))
             (fr-h (frame-pixel-height fr))
             (left (max mon-x (+ mon-x (/ (- mon-w fr-w) 2))))
             (top (max mon-y (+ mon-y (/ (- mon-h fr-h) 2)))))
        (set-frame-parameter fr 'user-position t)
        (set-frame-position fr left top)))))

;;;###autoload
(defun tesis-tools-open-math-pad ()
  "Abre el buffer interactivo del Math Pad para escribir fórmulas LaTeX para Inkscape."
  (interactive)
  (let ((buf (get-buffer-create tesis-tools--math-pad-buffer-name))
        (fr (selected-frame)))
    ;; Asegurar que el marco se sitúe siempre en primer plano y centrado
    (set-frame-parameter fr 'z-group 'above)
    (set-frame-parameter fr 'auto-raise t)
    (tesis-tools--center-frame fr)
    (raise-frame fr)
    (select-frame-set-input-focus fr)

    (with-current-buffer buf
      ;; Usar modo LaTeX o AUCTeX si está disponible
      (if (fboundp 'LaTeX-mode)
          (LaTeX-mode)
        (latex-mode))

      ;; Limpiar buffer
      (erase-buffer)

      ;; Configurar encabezado visual
      (setq header-line-format
            (propertize " 󰐝 Inkscape Math Pad | [Enter] o [C-c C-c] o [ZZ]: Pegar | [Esc] o [q]: Cancelar "
                        'face '(:foreground "#1e88e5" :weight bold)))

      ;; Mapear atajos de confirmación y cancelación
      (local-set-key (kbd "<return>") #'tesis-tools-math-pad-confirm)
      (local-set-key (kbd "RET") #'tesis-tools-math-pad-confirm)
      (local-set-key (kbd "C-<return>") #'tesis-tools-math-pad-confirm)
      (local-set-key (kbd "C-c C-c") #'tesis-tools-math-pad-confirm)
      (local-set-key (kbd "C-c C-k") #'tesis-tools-math-pad-cancel)
      (local-set-key (kbd "C-g") #'tesis-tools-math-pad-cancel)
      (local-set-key (kbd "<escape>") #'tesis-tools-math-pad-cancel)

      ;; Soporte para Evil Mode
      (when (bound-and-true-p evil-mode)
        (evil-local-set-key 'insert (kbd "<return>") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'insert (kbd "RET") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'insert (kbd "C-c C-c") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'insert (kbd "C-c C-k") #'tesis-tools-math-pad-cancel)
        (evil-local-set-key 'normal (kbd "<return>") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'normal (kbd "RET") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'normal (kbd "ZZ") #'tesis-tools-math-pad-confirm)
        (evil-local-set-key 'normal (kbd "ZQ") #'tesis-tools-math-pad-cancel)
        (evil-local-set-key 'normal (kbd "q") #'tesis-tools-math-pad-cancel)
        (evil-local-set-key 'normal (kbd "<escape>") #'tesis-tools-math-pad-cancel)
        (evil-insert-state)))

    (set-window-buffer (frame-selected-window fr) buf)
    (select-window (frame-selected-window fr))
    (when (fboundp 'evil-insert-state)
      (evil-insert-state))
    (tesis-tools--center-frame fr)
    (run-at-time "0.03 sec" nil (lambda (f) (tesis-tools--center-frame f)) fr)
    (raise-frame fr)
    (select-frame-set-input-focus fr)
    buf))

;; Alias por retrocompatibilidad
(defalias 'tesis-tools-inkscape-math-popup #'tesis-tools-open-math-pad)

;; ==================================================================
;; --- 5. REPORTE DE TODOS DEL PROYECTO (CON RIPGREP)
;; ==================================================================

;;;###autoload
(defun tesis-tools-todo-report ()
  "Escanea el proyecto con ripgrep en busca de TODOs y los muestra en un buffer interactivo."
  (interactive)
  (unless (executable-find "rg")
    (user-error "ripgrep (rg) no está instalado en tu sistema."))
  (unless (and (bound-and-true-p projectile-mode) (projectile-project-p))
    (user-error "No estás dentro de un proyecto de Projectile."))

  (let* ((root (projectile-project-root))
         (keywords-regex (concat "%[[:space:]]*\\(" (regexp-opt tesis-tools-todo-keywords) "\\)"))
         (report-title "*Tesis TODO Report*")
         (report-buf (get-buffer-create report-title)))
    (with-current-buffer report-buf
      (let ((inhibit-read-only nil)) (read-only-mode -1))
      (erase-buffer)
      (insert (format "#+TITLE: Reporte de TODOs del Proyecto\n"))
      (insert (format "#+SUBTITLE: %s\n" root))
      (insert (format "#+DATE: %s\n\n" (format-time-string "%Y-%m-%d %H:%M")))

      (let ((process-connection-type nil)) ; Usar tubería
        (start-process-shell-command "rg-todos" report-buf
                                     (format "rg --type tex --line-number --heading --no-messages '%s' ."
                                             keywords-regex)))
      (set-buffer-process-sentinel
       (get-buffer-process report-buf)
       (lambda (proc event)
         (when (memq (process-status proc) '(exit signal))
           (with-current-buffer (process-buffer proc)
             (goto-char (point-min))
             (while (re-search-forward "^\\(.*?\\):\\([0-9]+\\):.*%[[:space:]]*\\(.*?\\):\\(.*\\)$" nil t)
               (let* ((file (match-string 1))
                      (line (match-string 2))
                      (tag (match-string 3))
                      (msg (string-trim (match-string 4)))
                      (start (match-beginning 0))
                      (end (match-end 0)))
                 (replace-match
                  (format "- [%s] [[file:%s::%s][%s:%s]] %s"
                          tag (expand-file-name file root) line file line msg)
                  t nil nil 0)))
             (org-mode)
             (read-only-mode +1)
             (message "Reporte de TODOs generado."))))))
    (pop-to-buffer report-buf)))

(provide 'tesis-tools) 
;;; tesis-tools.el ends here