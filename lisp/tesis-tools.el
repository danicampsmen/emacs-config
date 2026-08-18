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

;;;###autoload
(defun tesis-tools-insert-inkscape-pdftex ()
  "Crea una figura Inkscape (.svg), la exporta a .pdf_tex e inserta el código LaTeX."
  (interactive)
  (when-let* ((project-root (projectile-project-root))
              (fig-dir (expand-file-name tesis-tools-figures-directory project-root))
              (raw-name (read-string "Nombre de la figura (sin extensión): "))
              (fig-name (replace-regexp-in-string "[[:space:]]+" "-" raw-name)))
    (unless (file-directory-p fig-dir)
      (make-directory fig-dir t))
    (let ((svg-file (expand-file-name (concat fig-name ".svg") fig-dir)))
      (start-process-shell-command
       "inkscape-create" nil
       (format "inkscape --export-area-drawing --export-type='pdf,pdf_tex' %s"
               (shell-quote-argument svg-file)))
      (message "Lanzando Inkscape para crear %s..." (file-relative-name svg-file project-root))
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
  "Edita el SVG asociado al .pdf_tex bajo el cursor y lo re-exporta."
  (interactive)
  (save-excursion
    (when-let ((filename (when (string-match "\\\\incfig{\\([^}]+\\)}" (thing-at-point 'line t))
                           (match-string 1 (thing-at-point 'line t)))))
      (let* ((project-root (projectile-project-root))
             (fig-dir (expand-file-name tesis-tools-figures-directory project-root))
             (svg-file (expand-file-name (concat filename ".svg") fig-dir)))
        (if (file-exists-p svg-file)
            (progn
              (start-process-shell-command
               "inkscape-edit" nil
               (format "inkscape %s" (shell-quote-argument svg-file)))
              (message "☁️ Abriendo '%s' en Inkscape..." (file-relative-name svg-file)))
          (warn "El archivo SVG no existe: %s" svg-file)))
      (unless (called-interactively-p 'any)
        (message "❌ No se encontró \\incfig{...} en la línea actual.")))))

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