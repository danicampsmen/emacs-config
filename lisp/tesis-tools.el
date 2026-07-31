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

;; ================================================================== 
;; --- 1. HERRAMIENTAS DE REDACCIÓN Y UTILIDADES 
;; ==================================================================

;;;###autoload 
(defun tesis-tools-status () 
  "Muestra un reporte de progreso (conteo de palabras)." 
  (interactive) 
  (let ((count (count-words (point-min) (point-max)))) 
    (message "Progreso Buffer: %d palabras." count)))

;;;###autoload 
(defun tesis-tools-insert-note () 
  "Inserta un comentario de nota con fecha." 
  (interactive) 
  (let ((date (format-time-string "%Y-%m-%d"))) 
    (insert (format "%% NOTE (%s) [%s]: " tesis-tools-author-name date))))

;;;###autoload 
(defun tesis-tools-wrap-in-environment (env-name) 
  "Envuelve la región seleccionada en un entorno LaTeX." 
  (interactive "sNombre del entorno: ") 
  (if (use-region-p) 
      (let ((start (region-beginning)) 
            (end (region-end))) 
        (save-excursion 
          (goto-char end) 
          (insert "\\end{" env-name "}\n") 
          (goto-char start) 
          (insert "\\begin{" env-name "}\n"))) 
    (message "¡No has seleccionado texto!")))

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
  "Inserta una cita con Citar, preguntando tipo (con opciones extendidas), número y página."
  (interactive)
  (let* ((opciones '("Teorema" "Proposición" "Lema" "Corolario" 
                     "Definición" "Ejemplo" "Observación" 
                     "Ecuación" "Sección" "Capítulo" "Apéndice"
                     "Theorem" "Proposition" "Lemma" "Corollary" 
                     "Definition" "Example" "Remark" 
                     "Equation" "Section" "Chapter" "Appendix"
                     "Teo." "Prop." "Lem." "Cor." "Def." "Ej." "Obs." "Ec." "Sec." "Cap." "Ap."
                     "Thm." "Ex." "Rem." "Eq." "Chap." "App."))
         (tipo (completing-read "Tipo de referencia (vacío para omitir): " opciones nil nil))
         (numero (if (not (string= tipo ""))
                     (read-string (format "Número de %s (vacío para omitir): " tipo))
                   ""))
         (pagina (read-string "Número de página (vacío para omitir): "))
         (refs (citar-select-ref))
         (keys (if (listp refs) (mapconcat #'identity refs ",") refs))
         (elemento (if (string= numero "")
                       tipo
                     (format "%s %s" tipo numero)))
         (opt-args (cond
                    ((and (not (string= elemento "")) (not (string= pagina "")))
                     (format "%s, p. %s" elemento pagina))
                    ((not (string= elemento ""))
                     elemento)
                    ((not (string= pagina ""))
                     (format "p. %s" pagina))
                    (t ""))))
    (if (string= opt-args "")
        (insert (format " \\cite{%s}" keys))
      (insert (format " \\cite[%s]{%s}" opt-args keys)))))

;; ================================================================== 
;; --- 4. INTEGRACIÓN INKSCAPE -> PDF_TEX (MÁXIMO RENDIMIENTO) 
;; ==================================================================

;;;###autoload 
(defun tesis-tools-insert-inkscape-pdftex () 
  "Dibuja en Inkscape, genera el código .pdf_tex e inserta un import puro en LaTeX." 
  (interactive) 
  (let* ((fig-dir (expand-file-name "figuras" (file-name-directory (buffer-file-name)))) 
         (raw-name (read-string "Nombre de la figura (sin extensión): ")) 
         (fig-name (replace-regexp-in-string " " "-" raw-name)))
    (unless (file-exists-p fig-dir)
      (make-directory fig-dir t))
    (start-process-shell-command "inkscape-create" nil 
                                 (format "inkscape-figures create %s %s"
                                         (shell-quote-argument fig-name)
                                         (shell-quote-argument fig-dir)))
    (insert (format "\\begin{figure}[htpb]\n  \\centering\n  \\incfig{%s}\n  \\caption{%s}\n  \\label{fig:%s}\n\\end{figure}\n"
                    fig-name raw-name fig-name))))

;;;###autoload 
(defun tesis-tools-edit-inkscape-pdftex () 
  "Edita el SVG asociado al .pdf_tex bajo el cursor y lo re-exporta al cerrar Inkscape." 
  (interactive) 
  (save-excursion 
    (let* ((line (thing-at-point 'line t)) 
           (filename nil))
      (when (string-match "\\\\incfig{\\([^}]+\\)}" line)
        (setq filename (match-string 1 line)))
      (if filename
          (let ((fig-dir (expand-file-name "figuras" (file-name-directory (buffer-file-name)))))
            (start-process-shell-command "inkscape-edit" nil 
                                         (format "inkscape-figures edit %s %s"
                                                 (shell-quote-argument fig-dir)
                                                 (shell-quote-argument filename)))
            (message "☁️ Abriendo figura '%s' en Inkscape..." filename))
        (message "❌ Error: No se encontró el comando \\incfig{...} en la línea actual.")))))

;;;###autoload 
(defun tesis-tools-inkscape-math-popup () 
  "Popup efímero: Escribe matemáticas, se cierra solo y hace auto-paste en Inkscape." 
  (interactive) 
  (let ((cmd (if (and (bound-and-true-p my/is-wayland) (executable-find "wtype"))
                 "wtype -M ctrl -M shift -P v -m shift -m ctrl"
               "xdotool key ctrl+shift+v")))
    (start-process-shell-command "inkscape-paste" nil cmd)
    (message "✅ Comando de auto-pegado enviado al servidor gráfico.")))

;; ================================================================== 
;; --- 5. REPORTE DE TODOS DEL PROYECTO 
;; ==================================================================

;;;###autoload
(defun tesis-tools-todo-report ()
  "Escanea recursivamente todos los archivos .tex del proyecto en busca de
% TODO, % NOTE, % FIXME, % HACK, % XXX y los presenta en un buffer organizado."
  (interactive)
  (unless (and (bound-and-true-p projectile-mode) (projectile-project-p))
    (user-error "No estás dentro de un proyecto de Projectile"))
  (let* ((root (projectile-project-root))
         (tex-files (directory-files-recursively root "\\.tex$"))
         (report-buf (get-buffer-create "*Tesis TODO Report*"))
         (total-todos 0)
         (total-notes 0))
    (with-current-buffer report-buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert "=== REPORTE DE TODOS DEL PROYECTO ===\n")
        (insert (format "Proyecto: %s\n" root))
        (insert (format "Fecha: %s\n\n" (format-time-string "%Y-%m-%d %H:%M")))
        (dolist (file tex-files)
          (unless (or (string-match-p "auto/" file)
                      (string-match-p "\\*region\\*" file))
            (with-temp-buffer
              (insert-file-contents file)
              (let ((file-todos 0)
                    (file-notes 0)
                    (rel-file (file-relative-name file root)))
                (goto-char (point-min))
                (while (re-search-forward
                        "%[ ]*\\(TODO\\|NOTE\\|FIXME\\|HACK\\|XXX\\)[ :]?\\(.*\\)$"
                        nil t)
                  (let ((tag (match-string 1)))
                    (if (string= tag "NOTE")
                        (progn (cl-incf file-notes) (cl-incf total-notes))
                      (progn (cl-incf file-todos) (cl-incf total-todos)))))
                (when (or (> file-todos 0) (> file-notes 0))
                  (insert (format "\n📄 %s (%d TODOs, %d NOTEs)\n"
                                  rel-file file-todos file-notes))
                  (goto-char (point-min))
                  (while (re-search-forward
                          "%[ ]*\\(TODO\\|NOTE\\|FIXME\\|HACK\\|XXX\\)[ :]?\\(.*\\)$"
                          nil t)
                    (let ((tag (match-string 1))
                          (msg (string-trim (or (match-string 2) "")))
                          (line-num (line-number-at-pos (match-beginning 0))))
                      (insert (format "  L%-4d [%s] %s\n" line-num tag msg)))))))))
        (insert "\n=== RESUMEN ===\n")
        (insert (format "Total TODOs: %d\n" total-todos))
        (insert (format "Total NOTEs: %d\n" total-notes))
        (goto-char (point-min))))
    (with-current-buffer report-buf
      (special-mode))
    (pop-to-buffer report-buf)
    (message "Reporte generado: %d TODOs, %d NOTEs encontrados."
             total-todos total-notes)))

(provide 'tesis-tools) 
;;; tesis-tools.el ends here