;;; my-second-brain.el --- Zotero, Agenda y Segundo Cerebro LaTeX -*- lexical-binding: t; -*-

(defvar my/second-brain-path (expand-file-name "~/Documentos/Segundo-Cerebro/")
  "Ruta raíz del Segundo Cerebro.")

;; ==================================================================
;; --- 1. ZOTERO Y BIBLIOGRAFÍA (CITAR) ---
;; ==================================================================
(require 'projectile)
(require 'citar)
(require 'citar-embark)

(defvar my/global-bibliography (list (expand-file-name "referencias.bib" my/second-brain-path)))
(setq citar-bibliography my/global-bibliography)
(setq citar-library-paths (list (expand-file-name "~/Zotero/storage/")
                                (expand-file-name "~/Documentos/Books/")))
(setq citar-notes-paths (list (expand-file-name "~/Documentos/Notas_Tesis/")))
(setq citar-templates
      '((main . "${author editor:30} ${date year issued:4} ${title:48}")
        (suffix . " ${tags keywords:*}")
        (preview . "${author editor} (${year issued date}) ${title}, ${journal publisher container-title}...")
        (note . "\\section*{Notas: ${title}}\n\\textbf{Autor:} ${author}\n\\textbf{Año:} ${date}\n\n")))

(citar-embark-mode)

;; (defun my/insert-citation-with-page ()
;;   "Inserta cita de Citar preguntando por la página específica."
;;   (interactive)
;;   (let* ((page (read-string "Página: "))
;;          (refs (citar-select-ref))
;;          (keys (if (listp refs) (mapconcat #'identity refs ",") refs)))
;;     (insert (format "\\cite[p.%s]{%s}" page keys))))

(defun my/insert-pdf-link ()
  "Inserta un enlace mágico al PDF de la referencia seleccionada."
  (interactive)
  (let* ((keys (citar-select-ref))                     
         (first-key (car keys))                        
         (files-hash (citar-get-files keys))           
         (file-list (gethash first-key files-hash))    
         (file (car file-list)))                       
    (if file
        (let ((page (read-string "Página del PDF: ")))
          (insert (format "%% PDF: %s::%s" file page)))
      (message "❌ JARVIS: No se encontró ningún PDF asociado a esta referencia en Zotero."))))

(defun my/open-pdf-link ()
  "Lee el enlace mágico y abre el PDF en la página indicada."
  (interactive)
  (save-excursion
    (beginning-of-line)
    ;; FIX: Regex corregida (\\(.+\\)) en lugar de (\\(+\\))
    (if (re-search-forward "% PDF: \\(.*\\)::\\(.+\\)" (line-end-position) t)
        (my/open-pdf (match-string 1))
      (message "No se encontró ningún enlace PDF en esta línea."))))

(defun my/detect-project-bibliography ()
  "Busca archivos .bib en la raíz del proyecto y los establece localmente."
  (if (and (bound-and-true-p projectile-mode) (projectile-project-p))
      (let* ((root (projectile-project-root))
             (files (projectile-current-project-files))
             (bib-files (cl-remove-if-not (lambda (f) (string-suffix-p ".bib" f t)) files)))
        (if bib-files
            (progn
              (setq bib-files (mapcar (lambda (f) (expand-file-name f root)) bib-files))
              (setq-local citar-bibliography bib-files)
              (setq-local citar-library-paths (append (list root) citar-library-paths))
              (message "📚 [Layout] Usando bibliografía local: %s" (mapconcat #'file-name-nondirectory bib-files ", ")))
          (message "🌐 [Layout] No hay .bib en el proyecto. Usando Global.")))
    (message "🌐 [Layout] Fuera de proyecto. Usando Global.")))

;; ==================================================================
;; --- 2. ORG MODE, AGENDA Y CALENDARIO ---
;; ==================================================================
(require 'org)
(require 'org-modern)

(setq org-directory "~/Documentos/Agenda/")
(setq org-agenda-files (list (expand-file-name "vida.org" org-directory)
                             (expand-file-name "inbox-mobile.org" org-directory)))

(with-eval-after-load 'org
  (global-org-modern-mode)
  (setq org-modern-star '("◉" "○" "◈" "◇" "✳")
        org-modern-list '((43 . "➤") (45 . "•")))
  (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d!)" "CANCELLED(c)")))
  (setq org-capture-templates
        '(("t" "Tarea" entry (file+headline "vida.org" "Bandeja de Entrada") "* TODO %?\n  %i\n  %a")
          ("m" "Nota Móvil" entry (file+headline "inbox-mobile.org" "Capturas") "* %?\n  Añadido: %U"))))

(defun my/org-process-mobile-inbox ()
  "Mueve las notas capturadas en el celular hacia el archivo maestro vida.org."
  (interactive)
  (let ((inbox (expand-file-name "inbox-mobile.org" org-directory))
        (target (expand-file-name "vida.org" org-directory)))
    (if (and (file-exists-p inbox) (> (nth 7 (file-attributes inbox)) 0))
        (progn
          (find-file target)
          (goto-char (point-max))
          (insert "\n\n* 📱 NOTAS DEL MÓVIL [" (format-time-string "%Y-%m-%d %H:%M") "]\n")
          (insert-file-contents inbox)
          (with-temp-file inbox (insert ""))
          (save-buffer)
          (message "✅ Notas importadas exitosamente."))
      (message "📭 Nada nuevo en el móvil."))))

(require 'calfw)
(require 'calfw-org)
(defun my/open-calendar () (interactive) (cfw:open-org-calendar))

;; ==================================================================
;; --- 3. DIARIO INTELIGENTE ---
;; ==================================================================
(defvar my/journal-path (expand-file-name "00-Diario/" my/second-brain-path))

(defun my/journal-today ()
  "Abre o crea la nota del diario de hoy y la vincula en la bitácora."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
         (day-name (capitalize (format-time-string "%A")))
         (display-date (concat day-name (format-time-string ", %d de %B de %Y")))
         (year (format-time-string "%Y"))
         (month (format-time-string "%m"))
         (daily-dir (expand-file-name (concat year "/" month "/") my/journal-path))
         (daily-file (expand-file-name (concat date ".tex") daily-dir))
         (master-file (expand-file-name "Bitácora-Personal.tex" my/journal-path))
         (is-new-file (not (file-exists-p daily-file))))
    (unless (file-exists-p daily-dir) (make-directory daily-dir t))
    (find-file daily-file)
    (when is-new-file
      (insert (format "\\section*{%s}\n\\label{day:%s}\n\n" display-date date))
      (save-buffer)
      (my/journal-register-in-master master-file date year month))
    (goto-char (point-max))
    (when (fboundp 'evil-insert-state) (evil-insert-state))))

(defun my/journal-register-in-master (master-file filename year month)
  "Inyecta el \\input del diario en la Bitácora-Personal."
  (if (file-exists-p master-file)
      (let ((input-line (format "\\input{%s/%s/%s.tex}\n" year month filename)))
        (with-current-buffer (find-file-noselect master-file)
          (goto-char (point-max))
          (if (search-backward "\\end{document}" nil t)
              (progn (beginning-of-line) (insert input-line))
            (goto-char (point-max))
            (insert input-line))
          (save-buffer)))))

;; ==================================================================
;; --- 4. ARQUITECTURA DEL CEREBRO: LIMPIEZA Y ESCANEO ---
;; ==================================================================
(defun my/brain-nuclear-cleanup ()
  "BORRADO PROFUNDO: Elimina imports.tex, referencias.bib y TODA la basura _region_.tex recursivamente."
  (interactive)
  (let ((root (expand-file-name my/second-brain-path))
        (count 0))
    (dolist (f '("imports.tex" "referencias.bib" "main.pdf" "main.bbl" "main.bcf" "main.run.xml"))
      (let ((file (expand-file-name f root)))
        (when (file-exists-p file) (delete-file file))))
    (dolist (file (directory-files-recursively root "_region_.*\\.tex$"))
      (delete-file file)
      (setq count (1+ count)))
    (message "☢️ LIMPIEZA NUCLEAR: %d archivos basura eliminados. Estructura reseteada." count)))

(defun my/brain-is-root-file-p (filepath)
  "Devuelve 't' si el archivo tiene \\documentclass o \\begin{document}."
  (when (and (stringp filepath) (file-exists-p filepath))
    (with-temp-buffer
      (insert-file-contents filepath nil 0 4096)
      (goto-char (point-min))
      (re-search-forward "\\\\\\(documentclass\\|begin{document}\\)" nil t))))

;; ==================================================================
;; --- 5. GENERADORES (IMPORTS Y BIBLIOGRAFÍA HÍBRIDA) ---
;; ==================================================================
(defvar my/brain-pretty-names
  '(("Diario" . "Diario Personal y Bitácora")
    ("Main"   . "Introducción al Segundo Cerebro")
    ("Apuntes-Programacion" . "Ciencias de la Computación")
    ("Apuntes-Algebraic-Topology" . "Topología Algebraica")
    ("Apuntes-Analisis-Fourier" . "Análisis de Fourier"))
  "Diccionario para traducir nombres de archivo (.tex) a Títulos en el PDF.")

(defun my/brain-generate-imports ()
  "Genera imports.tex organizando por Carpetas (Visual) y Archivos (Partes)."
  (interactive)
  (let ((imports-file (expand-file-name "imports.tex" my/second-brain-path))
        (base-path (file-name-as-directory (expand-file-name my/second-brain-path)))
        (counter 0)
        (ignored-patterns '("^\\." "^_" "^flycheck_" "preamble" "imports" "main" "region" "auto" "backup" "_region_")))
    (with-temp-file imports-file
      (insert "% --- CEREBRO DINÁMICO: ESTRUCTURA v6.2 (Balanced) ---\n\n")
      (dolist (cat-dir (sort (directory-files base-path t "^[0-9]+-") #'string-lessp))
        (when (file-directory-p cat-dir)
          (let* ((cat-raw-name (file-name-nondirectory cat-dir))
                 (cat-clean-name (capitalize (replace-regexp-in-string "-" " " (replace-regexp-in-string "^[0-9]+-" "" cat-raw-name)))))
            (insert (format "\n%% ==========================================\n"))
            (insert (format "%% === GRUPO: %s ===\n" cat-clean-name))
            (insert (format "%% ==========================================\n"))
            (insert "\\cleardoublepage\n\\phantomsection\n")
            (insert (format "\\part*{%s}\n\n" cat-clean-name))
            (let ((items (directory-files cat-dir t)))
              (dolist (item items)
                (let ((name (file-name-nondirectory item)))
                  (unless (cl-some (lambda (pat) (string-match-p pat name)) ignored-patterns)
                    (let ((chosen-file nil))
                      (cond
                       ((file-directory-p item)
                        (let ((tex-files (directory-files item t "\\.tex$")) (candidates nil))
                          (dolist (f tex-files) (when (my/brain-is-root-file-p f) (push f candidates)))
                          (setq chosen-file (or (cl-find-if (lambda (f) (string-match-p "/main\\.tex$" f)) candidates)
                                                (cl-find-if (lambda (f) (string-equal (file-name-nondirectory f) (concat name ".tex"))) candidates)
                                                (car candidates)))))
                       ((and (string-suffix-p ".tex" name) (my/brain-is-root-file-p item))
                        (setq chosen-file item)))
                      (when chosen-file
                        (let* ((filename-no-ext (file-name-sans-extension (file-name-nondirectory chosen-file)))
                               (pretty-title (or (cdr (assoc filename-no-ext my/brain-pretty-names))
                                                 (capitalize (replace-regexp-in-string "-" " " filename-no-ext))))
                               (rel-path (file-relative-name (file-name-directory chosen-file) base-path)))
                          (insert (format "\\part{%s}\n" pretty-title)) 
                          (insert (format "\\label{part:%s}\n" filename-no-ext)) 
                          (insert (format "\\import{%s}{%s}\n" (file-name-as-directory rel-path) (file-name-nondirectory chosen-file)))
                          (setq counter (1+ counter)))))))))))))
    (message "✅ Cerebro actualizado: %d notas vinculadas." counter)))

(require 'bibtex)
(defun my/brain-generate-bib ()
  "Genera referencias.bib. Usa 'bibtool' si existe (Rápido), si no usa Emacs (Lento)."
  (interactive)
  (let ((root-dir (expand-file-name my/second-brain-path))
        (output-file (expand-file-name "referencias.bib" my/second-brain-path))
        (all-bib-files (directory-files-recursively root-dir "\\.bib$")))
    (when (member output-file all-bib-files)
      (setq all-bib-files (delete output-file all-bib-files)))

    (if (executable-find "bibtool")
        (progn
          (message "🚀 Biblio: Usando bibtool (Motor de alto rendimiento)...")
          (let* ((args (append all-bib-files (list "-s" "-d")))
                 (process (apply #'process-file (executable-find "bibtool") nil `(,output-file nil) nil args)))
            (set-process-sentinel process
                                  (lambda (p e) (when (string= e "finished\n") (message "📚 Bibliografía regenerada instantáneamente."))))))
      (message "🐢 Biblio: 'bibtool' no encontrado. Usando motor nativo (Lento)...")
      (let ((seen-keys (make-hash-table :test 'equal))
            (count-removed 0))
        (with-temp-buffer
          (insert "% --- BIBLIOGRAFÍA GENERADA (MODO NATIVO) ---\n\n")
          (dolist (file all-bib-files)
            (insert-file-contents file)
            (goto-char (point-max))
            (insert "\n\n"))
          (bibtex-mode)
          (bibtex-set-dialect 'biblatex)
          (goto-char (point-min))
          (while (re-search-forward bibtex-entry-head nil t)
            (let* ((beg (match-beginning 0))
                   (key (progn (goto-char beg) (bibtex-key-in-head))))
              (if (and key (gethash key seen-keys))
                  (progn (bibtex-end-of-entry) (delete-region beg (point)) (setq count-removed (1+ count-removed)))
                (when key (puthash key t seen-keys))
                (bibtex-end-of-entry))))
          (write-region (point-min) (point-max) output-file))
        (message "📚 Bibliografía unificada (Nativa): %d duplicados eliminados." count-removed)))))

;; ==================================================================
;; --- 6. MOTOR DE COMPILACIÓN ASÍNCRONO ---
;; ==================================================================
(defun my/brain-git-backup ()
  "Guarda el estado del cerebro en Git automáticamente."
  (interactive)
  (let ((default-directory my/second-brain-path))
    (if (file-exists-p ".git")
        (start-process-shell-command "brain-git" nil (format "git add . && git commit -m 'Auto-save: %s'" (format-time-string "%Y-%m-%d %H:%M")))
      (message "⚠️ Brainkeeper: No se detectó repositorio Git."))))

(defun my/brain-compile-incremental ()
  "Compila main.tex RÁPIDAMENTE sin regenerar estructura ni bibliografía."
  (interactive)
  (save-buffer)
  (let ((default-directory my/second-brain-path)
        (TeX-master (expand-file-name "main.tex" my/second-brain-path)))
    (message "🚀 Cerebro: Compilación INCREMENTAL (Solo cambios de texto)...")
    (TeX-command-run-all nil)))

(defun my/brain-build-and-view ()
  "Regenera estructura, bibliografía y compila asincrónicamente usando latexmk."
  (interactive)
  (save-some-buffers t)
  (my/brain-generate-bib)
  (my/brain-generate-imports)
  (let* ((default-directory my/second-brain-path)
         (args '("-pdflua" "-shell-escape" "-interaction=nonstopmode" "main.tex"))
         (out-buf (get-buffer-create " *brain-compile* "))
         (proc (apply #'process-file (executable-find "latexmk") nil out-buf nil args)))
    (message "🚀 Reconstrucción asíncrona iniciada (vía latexmk). El Brainkeeper vigila...")
    (set-process-sentinel proc
                          (lambda (p event)
                            (when (string-match-p "finished" event)
                              (message "✅ Compilación del Cerebro Exitosa.")
                              (my/brain-git-backup))))))

(defun my/brain-clean-and-compile ()
  "Borra archivos temporales y recompila desde cero."
  (interactive)
  (let ((default-directory my/second-brain-path))
    (shell-command "latexmk -C") 
    (ignore-errors (delete-file "imports.tex"))
    (my/brain-build-and-view)))

(defun my/smart-compile ()
  "Enruta la compilación según el contexto (Incremental vs Standalone)."
  (interactive)
  (if (not (buffer-file-name))
      (message "⚠️ No se puede compilar: Este buffer no es un archivo guardado.")
    (progn
      (save-buffer)
      (if (my/brain-is-root-file-p (buffer-file-name))
          (my/brain-build-and-view) ;; <--- Usar Latexmk en lugar de TeX-command-run-all
        (my/brain-compile-incremental)))))

;; ==================================================================
;; --- 7. HERRAMIENTAS EXTRAS (VISUALIZACIÓN Y CREACIÓN) ---
;; ==================================================================
(defun my/brain-open-pdf ()
  "Abre el PDF final del Segundo Cerebro."
  (interactive)
  (let ((pdf (expand-file-name "main.pdf" my/second-brain-path)))
    (if (file-exists-p pdf) (my/open-pdf pdf) (message "Primero compila con ;kc"))))

(defun my/brain-neural-search ()
  "Busca en el cerebro usando Ripgrep."
  (interactive)
  (consult-ripgrep my/second-brain-path ""))

(defun my/brain-new-entry ()
  "Crea una nota nueva en su propia subcarpeta."
  (interactive)
  (let* ((dirs (directory-files my/second-brain-path nil "^[0-9]+-"))
         (cat (completing-read "Categoría: " dirs))
         (raw-name (read-string "Nombre del Apunte: "))
         (name (replace-regexp-in-string " " "-" raw-name))
         (note-dir (concat (expand-file-name my/second-brain-path) cat "/" name "/"))
         (note-file (expand-file-name (concat name ".tex") note-dir)))
    (make-directory note-dir t)
    (find-file note-file)
    (save-buffer)
    (message "✨ Apunte creado en carpeta: %s/%s/" cat name)))

(defun my/brain-generate-graph ()
  "Genera un grafo visual de las conexiones del cerebro usando Graphviz."
  (interactive)
  (unless (executable-find "dot")
    (user-error "Error: Instala graphviz (sudo apt install graphviz)."))
  (let ((dot-file (expand-file-name "brain_map.dot" my/second-brain-path))
        (img-file (expand-file-name "brain_map.png" my/second-brain-path))
        (files (directory-files-recursively my/second-brain-path "\\.tex$")))
    (with-temp-file dot-file
      (insert "digraph Brain {\n  node [shape=box, style=filled, fillcolor=\"#E0E0E0\", fontname=\"Helvetica\", fontsize=10];\n  edge [color=\"#555555\", arrowsize=0.5];\n  bgcolor=\"#1E1E1E\";\n  rankdir=LR;\n")
      (dolist (file files)
        (with-temp-buffer
          (insert-file-contents file)
          (let ((node-name (file-name-base file)))
            (goto-char (point-min))
            (while (re-search-forward "\\\\(?:input\\|import){.*?\\([^/}]+\\)}\\(?:\\.tex\\)?" nil t)
              (insert (format "  \"%s\" -> \"%s\";\n" node-name (match-string 1)))))))
      (insert "}"))
    (let ((process (process-file (executable-find "dot") nil `(,img-file nil) nil "-Tpng" dot-file)))
      (set-process-sentinel process
                            (lambda (p e)
                              (when (string= e "finished\n")
                                (message "✅ Grafo del cerebro generado.")
                                (my/open-pdf img-file)))))))

;; ==================================================================
;; --- INICIALIZACIÓN AUTÓNOMA DEL SEGUNDO CEREBRO ---
;; ==================================================================
;; Hook dinámico: Ejecutar la detección de bibliotecas locales al 
;; cargar cualquier archivo LaTeX en el editor.
;;;###autoload
(defun my/citar-preview-at-point ()
  "Muestra una vista previa de la ficha de Zotero para la cita bajo el cursor."
  (interactive)
  (let ((key (thing-at-point 'symbol t)))
    (if (and key (fboundp 'citar-get-entry))
        (let ((entry (citar-get-entry key)))
          (if entry
              (let ((title (cdr (assoc "title" entry)))
                    (author (cdr (assoc "author" entry)))
                    (year (cdr (assoc "year" entry))))
                (message "📖 Cita Zotero: [%s] (%s) %s — %s" key (or year "????") (or author "Sin autor") (or title "Sin título")))
            (message "⚠️ No se encontró la entrada de Zotero para la clave '%s'." key)))
      (message "⚠️ El cursor no está sobre una clave de cita válida."))))

;;;###autoload
(defun my/brain-export-local-bib ()
  "Genera un archivo referencias.bib local filtrado solo con las citas usadas en el documento .tex actual."
  (interactive)
  (when (derived-mode-p 'LaTeX-mode 'latex-mode)
    (let ((keys nil)
          (content (buffer-string))
          (dest-bib (expand-file-name "referencias.bib" (file-name-directory (buffer-file-name)))))
      (while (string-match "\\\\\\(?:cite\\|cref\\|ref\\){\\([^}]+\\)}" content)
        (let ((raw-keys (split-string (match-string 1 content) "[\t\n, ]+" t)))
          (setq keys (append keys raw-keys)))
        (setq content (replace-match "" nil nil content)))
      (setq keys (delete-dups keys))
      (if (null keys)
          (message "⚠️ No se encontraron claves \\cite{...} en el documento actual.")
        (let ((master-bib (expand-file-name "referencias.bib" my/second-brain-path)))
          (if (not (file-exists-p master-bib))
              (message "⚠️ No se encontró el archivo maestro referencias.bib en %s." master-bib)
            (with-temp-file dest-bib
              (insert (format "%% Archivo referencias.bib generado automáticamente para %s\n\n" (file-name-nondirectory (buffer-file-name))))
              (dolist (key keys)
                (let ((bib-content (with-temp-buffer
                                     (insert-file-contents master-bib)
                                     (goto-char (point-min))
                                     (when (re-search-forward (format "@[a-zA-Z]+{\\s-*%s\\s-*," (regexp-quote key)) nil t)
                                       (let ((start (match-beginning 0)))
                                         (forward-sexp)
                                         (buffer-substring-no-properties start (point)))))))
                  (when bib-content
                    (insert bib-content "\n\n")))))
            (message "✅ Citas exportadas (%d claves) hacia %s." (length keys) dest-bib)))))))

(provide 'my-second-brain)
;;; my-second-brain.el ends here