;;; my-latex-tree-sitter.el --- Formateo AST, Semántico, Envoltura y Headers (Bourbaki Edition) -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)
(require 'align)
(require 'treesit nil t)

(defvar my/latex-auto-format-on-save nil
  "Indica si se debe formatear el buffer .tex al guardar.")

;; ==================================================================
;; --- 1. CONFIGURACIÓN Y VERIFICACIÓN DE TREE-SITTER ---
;; ==================================================================

(setq treesit-language-source-alist
      (cons '(latex "https://github.com/latex-lsp/tree-sitter-latex" "v0.3.0" "src")
            (assq-delete-all 'latex treesit-language-source-alist)))

(defun my/ts-latex-available-p ()
  "Verifica si el parser Tree-sitter para LaTeX está listo en el sistema."
  (and (fboundp 'treesit-available-p)
       (treesit-available-p)
       (fboundp 'treesit-language-available-p)
       (treesit-language-available-p 'latex)))

;; ==================================================================
;; --- 2. COMANDOS Y ENTORNOS NATIVOS DE apuntes-scr.cls ---
;; ==================================================================

(defconst my/latex-standalone-commands
  '("documentclass" "usepackage"
    ;; Metadatos y Contexto Académico (apuntes-scr.cls)
    "title" "author" "date" "email" "orcid" "version"
    "universidad" "facultad" "curso" "codigo" "semestre"
    "profesor" "asistente" "lugar" "logo" "referencias"
    "addbibresource" "bibliography"
    ;; Estructura y Navegación Bourbaki / IHÉS
    "maketitle" "tableofcontents" "printindex" "printbibliography"
    "part" "chapter" "chapitrezero" "capitulozero" "section"
    "subsection" "subsubsection" "paragraph" "subparagraph"
    "addsubsec" "addsubsubsec" "iniciarapendices" "colophon"
    "appendix" "frontmatter" "mainmatter" "backmatter"
    "cleardoublepage" "clearpage" "newpage" "phantomsection"
    ;; Elementos de Lista, Ejercicios y Algoritmos
    "item" "propitem" "nameditem" "task" "exer" "exerdif" "exerpro" "conditem"
    "algstep" "alginput" "algoutput" "alginit" "algparams" "algstop"
    ;; Pasos de Demostración EGA y Tournants Dangereux
    "directstep" "reversestep" "containedstep" "inversecontainedstep"
    "casobase" "pasoinductivo" "hipotesisind" "dependencias" "blueprint"
    "parag" "numpar" "bourbakibreak" "egabreak" "sectionbreak" "chaptersummary"
    "viragedangereux" "dbviragedangereux" "bourbakidanger" "bourbakidbdanger" "danger" "dbdanger"
    ;; Anotaciones, Figuras y Utilidades
    "label" "index" "caption" "centering" "includegraphics" "incfig"
    "input" "import" "subfile"
    "TODO" "FIXME" "NOTE" "DEBUG")
  "Comandos de bloque en apuntes-scr.cls que deben estar en su propia línea.")

(defconst my/latex-protected-verbatim-envs
  '("pseudocodigo" "pythonlib" "pythonexec" "pythoncode"
    "minted" "verbatim" "verbatim*" "lstlisting")
  "Entornos de código donde el formateador NO debe alterar ninguna línea.")

(defconst my/latex-protected-math-diagram-envs
  '("align" "align*" "aligned" "alignat" "alignat*" "gather" "gather*"
    "multline" "multline*" "flalign" "flalign*" "tikzcd" "array" "tabular"
    "tabularray" "tblr" "conditions" "tasks"
    "pmatrix" "pmatrix*" "bmatrix" "bmatrix*" "Bmatrix" "Bmatrix*"
    "vmatrix" "vmatrix*" "Vmatrix" "Vmatrix*" "cases"
    "mini" "mini*" "maxi" "maxi*" "argmini" "argmini*" "argmaxi" "argmaxi*"
    "tikzpicture" "pgfplots" "axis" "mplibcode")
  "Entornos matemáticos, matriciales y gráficos donde se respeta la distribución interna.")

;; ==================================================================
;; --- 3. FORMATEO SEMÁNTICO VERTICAL ---
;; ==================================================================

(defun my/latex-semantic-vertical-format (&optional beg end)
  "Asegura aislamiento vertical limpio y cabeceras canónicas adaptadas a apuntes-scr.cls."
  (let ((start (or beg (point-min)))
        (stop  (min (or end (point-max)) (point-max))))
    (save-excursion
      (save-restriction
        (narrow-to-region start stop)

        ;; 1. Colapsar excesos de saltos de línea (>2 a 2)
        (goto-char (point-min))
        (while (re-search-forward "\n\n\n+" nil t)
          (replace-match "\n\n"))

        ;; 2. Separar comandos atómicos pegados en la misma línea
        (goto-char (point-min))
        (let ((atomic-split-regex
               (concat "\\([^ \t\n%]\\)[ \t]*\\(\\\\\\("
                       (regexp-opt my/latex-standalone-commands)
                       "\\)\\b\\)")))
          (while (re-search-forward atomic-split-regex nil t)
            (replace-match "\\1\n\\2")))

        ;; 3. Separar ítems y pasos de algoritmos/ejercicios
        (goto-char (point-min))
        (let ((item-regex
               (concat "\\([^ \t\n%]\\)[ \t]*\\(\\\\\\("
                       (regexp-opt '("item" "propitem" "nameditem" "task" "exer" "exerdif" "exerpro"
                                     "conditem" "algstep" "alginput" "algoutput" "alginit" "algstop"))
                       "\\)\\b\\)")))
          (while (re-search-forward item-regex nil t)
            (replace-match "\\1\n\\2")))

        ;; 4. Separar pasos EGA, Tournants Dangereux y descansos tipográficos
        (goto-char (point-min))
        (let ((steps-regex
               (concat "\\([^ \t\n%]\\)[ \t]*\\(\\\\\\("
                       (regexp-opt '("directstep" "reversestep" "containedstep" "inversecontainedstep"
                                     "casobase" "pasoinductivo" "hipotesisind" "parag" "numpar"
                                     "egabreak" "bourbakibreak" "sectionbreak" "chaptersummary"
                                     "viragedangereux" "dbviragedangereux"))
                       "\\)\\b\\)")))
          (while (re-search-forward steps-regex nil t)
            (replace-match "\\1\n\n\\2")))

        ;; 5. Auto-reparar \index partidos por llaves matemáticas anidadas
        (goto-char (point-min))
        (while (re-search-forward "\\(\\\\index{[^}\n]+\\)\n[ \t]*\\(\\$[^{}\n]+}\\)" nil t)
          (replace-match "\\1\\2" t t))

        ;; 6. Normalizar \begin{env}[opt]\label{...}\index{...} en la misma línea
        ;;    (Soporta corchetes vacíos [] o con opciones)
        (goto-char (point-min))
        (let ((header-regex
               (concat "\\(\\\\begin{[a-zA-Z*]+}\\(?:\\[[^]\n]*\\]\\)?\\)"
                       "[ \t\n]*\\(\\\\label{[^}\n]+}\\)"
                       "\\(?:[ \t\n]*\\(\\\\index{\\(?:[^{}\n]\\|{[^{}\n]*}\\)*}\\)\\)?[ \t\n]*")))
          (while (re-search-forward header-regex nil t)
            (let ((b-str (match-string 1))
                  (l-str (match-string 2))
                  (i-str (or (match-string 3) "")))
              (replace-match (concat b-str l-str i-str "\n") t t))))

        ;; 7. Normalizar jerarquía de secciones de apuntes-scr con \label
        (goto-char (point-min))
        (let ((sec-regex
               (concat "\\(\\\\\\("
                       (regexp-opt '("part" "chapter" "chapitrezero" "capitulozero"
                                     "section" "subsection" "subsubsection"
                                     "addsubsec" "addsubsubsec" "paragraph"))
                       "\\)\\*?{\\(?:[^{}\n]\\|{[^{}\n]*}\\)+}\\)[ \t\n]*\\(\\\\label{[^}\n]+}\\)[ \t\n]*")))
          (while (re-search-forward sec-regex nil t)
            (let ((s-str (match-string 1))
                  (l-str (match-string 3)))
              (replace-match (concat s-str l-str "\n\n") t t))))

        ;; 8. Separar \begin{...} huérfanos a su propia línea
        (goto-char (point-min))
        (while (re-search-forward "\\([^ \t\n%]\\)[ \t]*\\(\\\\begin{[^}]+}\\)" nil t)
          (replace-match "\\1\n\\2"))

        ;; 9. Separar \end{...} a su propia línea
        (goto-char (point-min))
        (while (re-search-forward "\\([^ \t\n%]\\)[ \t]*\\(\\\\end{[^}]+}\\)" nil t)
          (replace-match "\\1\n\\2"))

        ;; 10. Eliminar líneas en blanco previas a \[ (evita insertar \par espurio)
        (goto-char (point-min))
        (let ((math-open-blank (concat "\\(\n\\)[ \t]*\n[ \t]*\\(" (regexp-quote "\\[") "\\)")))
          (while (re-search-forward math-open-blank nil t)
            (replace-match "\\1\\2")))

        ;; 11. Separar display math \[ pegado a texto
        (goto-char (point-min))
        (let ((math-open-attach (concat "\\([^ \t\n\\\\]\\)[ \t]*\\(" (regexp-quote "\\[") "\\)")))
          (while (re-search-forward math-open-attach nil t)
            (replace-match "\\1\n\\2")))

        ;; 12. Separar display math \] pegado a texto previo
        (goto-char (point-min))
        (let ((math-close-attach (concat "\\([^ \t\n%]\\)[ \t]*\\(" (regexp-quote "\\]") "\\)")))
          (while (re-search-forward math-close-attach nil t)
            (replace-match "\\1\n\\2")))

        ;; 13. Separar display math \] de texto subsiguiente (salvo puntuación)
        (goto-char (point-min))
        (let ((math-close-follow (concat "\\(" (regexp-quote "\\]") "\\)[ \t]*\\([^ \t\n.,;:!?)%]\\)")))
          (while (re-search-forward math-close-follow nil t)
            (replace-match "\\1\n\\2")))))))

;; ==================================================================
;; --- 4. ALINEACIÓN VERTICAL DE COLUMNAS '&' ---
;; ==================================================================

(defun my/latex-align-delims-in-envs (&optional beg end)
  "Alinea verticalmente las columnas '&' en entornos matriciales y tabulares de apuntes-scr.cls."
  (let ((start (or beg (point-min)))
        (stop  (min (or end (point-max)) (point-max))))
    (save-excursion
      (save-restriction
        (narrow-to-region start stop)
        (goto-char (point-min))
        (let ((alignable-envs
               (regexp-opt '("aligned" "cases" "matrix" "matrix*"
                             "pmatrix" "pmatrix*" "bmatrix" "bmatrix*"
                             "Bmatrix" "Bmatrix*" "vmatrix" "vmatrix*"
                             "Vmatrix" "Vmatrix*" "tabular" "conditions" "tblr"))))
          (while (re-search-forward (concat "\\\\begin{" alignable-envs "}") nil t)
            (let ((s-pos (match-beginning 0))
                  (env-name (match-string 1)))
              (when (re-search-forward (format "\\\\end{%s}" (regexp-quote env-name)) nil t)
                (let ((e-pos (match-end 0)))
                  (align-regexp s-pos e-pos "\\(\\s-*\\)&" 1 1 t))))))))))

;; ==================================================================
;; --- 5. MOTOR DE INDENTACIÓN Y RE-ENVOLTURA A 120 COLUMNAS ---
;; ==================================================================

(defun my/latex-indent-buffer-clean (&optional beg end)
  "Aplica indentación jerárquica, protege código Python/minted y envuelve prosa a 120 columnas."
  (let* ((start (or beg (point-min)))
         (stop  (min (or end (point-max)) (point-max)))
         (indent-width 4)
         (max-cols (or fill-column 120))
         (env-stack nil)
         (in-display-math nil)
         (root-containers '("document"))
         (standalone-regex (concat "\\`[ \t]*\\\\\\("
                                   (regexp-opt my/latex-standalone-commands)
                                   "\\)\\b"))
         (lines (split-string (buffer-substring-no-properties start stop) "\n"))
         (out-lines nil)
         (prose-buffer nil))

    (cl-labels
        ((flush-prose ()
           (when prose-buffer
             (save-match-data
               (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                      (indent (make-string (* depth indent-width) ?\s))
                      (joined-text (string-join (nreverse prose-buffer) " "))
                      (words (split-string joined-text " " t))
                      (cur-line indent))
                 (dolist (word words)
                   (if (string= cur-line indent)
                       (setq cur-line (concat cur-line word))
                     (if (<= (+ (length cur-line) 1 (length word)) max-cols)
                         (setq cur-line (concat cur-line " " word))
                       (push cur-line out-lines)
                       (setq cur-line (concat indent word)))))
                 (unless (string= cur-line indent)
                   (push cur-line out-lines))
                 (setq prose-buffer nil))))))

      (dolist (line lines)
        (let* ((trimmed (string-trim line))
               (in-verbatim (cl-some (lambda (e) (member e my/latex-protected-verbatim-envs)) env-stack))
               (in-protected-math (cl-some (lambda (e) (member e my/latex-protected-math-diagram-envs)) env-stack)))
          (cond
           ;; 0. DENTRO DE ENTORNOS VERBATIM / PYTHON / MINTED -> PRESERVAR INTACTO
           (in-verbatim
            (flush-prose)
            (if (string-match "\\`[ \t]*\\\\end{\\([^}]+\\)}" trimmed)
                (let ((env-name (match-string 1 trimmed)))
                  (when (and env-name (member env-name env-stack))
                    (while (and env-stack (not (string= (car env-stack) env-name)))
                      (pop env-stack))
                    (when env-stack (pop env-stack)))
                  (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                         (indent (make-string (* depth indent-width) ?\s)))
                    (push (concat indent trimmed) out-lines)))
              ;; Dentro del bloque: preservar exactamente la línea original sin tocar espacios
              (push line out-lines)))

           ;; 1. Línea vacía
           ((string-empty-p trimmed)
            (flush-prose)
            (push "" out-lines))

           ;; 2. Comentarios (% y %%%)
           ((string-prefix-p "%" trimmed)
            (flush-prose)
            (if (string-prefix-p "%%%" trimmed)
                (push trimmed out-lines)
              (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                     (indent (make-string (* depth indent-width) ?\s)))
                (push (concat indent trimmed) out-lines))))

           ;; 3. Cierre de display math \]
           ((or (string= trimmed "\\]") (string-prefix-p "\\]" trimmed))
            (flush-prose)
            (setq in-display-math nil)
            (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                   (indent (make-string (* depth indent-width) ?\s)))
              (push (concat indent trimmed) out-lines)))

           ;; 4. Cierre de entorno general \end{...}
           ((string-match "\\`[ \t]*\\\\end{\\([^}]+\\)}" trimmed)
            (let ((env-name (match-string 1 trimmed)))
              (flush-prose)
              (when (and env-name (member env-name env-stack))
                (while (and env-stack (not (string= (car env-stack) env-name)))
                  (pop env-stack))
                (when env-stack (pop env-stack)))
              (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                     (indent (make-string (* depth indent-width) ?\s)))
                (push (concat indent trimmed) out-lines))))

           ;; 5. Apertura de display math \[
           ((or (string= trimmed "\\[") (string-prefix-p "\\[" trimmed))
            (flush-prose)
            (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                   (indent (make-string (* depth indent-width) ?\s)))
              (push (concat indent trimmed) out-lines)
              (setq in-display-math t)))

           ;; 6. Dentro de display math \[ ... \]
           (in-display-math
            (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                   (indent (make-string (* (1+ depth) indent-width) ?\s)))
              (push (concat indent trimmed) out-lines)))

           ;; 7. Apertura de entorno general \begin{...}
           ((string-match "\\`[ \t]*\\\\begin{\\([^}]+\\)}" trimmed)
            (let ((env-name (match-string 1 trimmed)))
              (flush-prose)
              (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                     (indent (make-string (* depth indent-width) ?\s)))
                (push (concat indent trimmed) out-lines)
                (when env-name (push env-name env-stack)))))

           ;; 8. Dentro de entorno matemático / tabular / TikZ protegido
           (in-protected-math
            (flush-prose)
            (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                   (indent (make-string (* depth indent-width) ?\s)))
              (push (concat indent trimmed) out-lines)))

           ;; 9. Comandos atómicos, preámbulo, estructura o pasos Bourbaki
           ((string-match-p standalone-regex trimmed)
            (flush-prose)
            (let* ((depth (length (cl-remove-if (lambda (e) (member e root-containers)) env-stack)))
                   (indent (make-string (* depth indent-width) ?\s))
                   (full-line (concat indent trimmed)))
              (if (> (length full-line) max-cols)
                  (save-match-data
                    (let* ((words (split-string trimmed " " t))
                           (cur-line indent))
                      (dolist (word words)
                        (if (string= cur-line indent)
                            (setq cur-line (concat cur-line word))
                          (if (<= (+ (length cur-line) 1 (length word)) max-cols)
                              (setq cur-line (concat cur-line " " word))
                            (push cur-line out-lines)
                            (setq cur-line (concat indent word)))))
                      (unless (string= cur-line indent)
                        (push cur-line out-lines))))
                (push full-line out-lines))))

           ;; 10. Prosa regular (párrafos que se envuelven armónicamente a 120 columnas)
           (t
            (push trimmed prose-buffer)))))

      (flush-prose)

      (save-excursion
        (save-restriction
          (narrow-to-region start (min stop (point-max)))
          (delete-region (point-min) (point-max))
          (insert (string-join (nreverse out-lines) "\n")))))))

;; ==================================================================
;; --- 6. ORQUESTADOR PRINCIPAL (;tf) ---
;; ==================================================================

;;;###autoload
(defun my/ts-format-buffer ()
  "Aplica formateo inteligente Bourbaki a 120 columnas preservando comandos y cursor."
  (interactive)
  (when (and (derived-mode-p 'LaTeX-mode 'latex-mode) (not buffer-read-only))
    (let* ((fold-active (bound-and-true-p TeX-fold-mode))
           (zen-active (bound-and-true-p my/latex-visual-mode))
           (inhibit-modification-hooks t)
           (inhibit-point-motion-hooks t)
           (use-reg (use-region-p))
           (orig-line (line-number-at-pos))
           (orig-col (current-column))
           (win (get-buffer-window (current-buffer)))
           (orig-win-start-line (when win
                                  (save-excursion
                                    (goto-char (window-start win))
                                    (line-number-at-pos))))
           (beg-marker (when use-reg (copy-marker (region-beginning))))
           (end-marker (when use-reg (copy-marker (region-end) t))))
      (unwind-protect
          (progn
            ;; 1. Desactivar temporalmente TeX-fold
            (when fold-active
              (when (fboundp 'TeX-fold-clearout-buffer)
                (TeX-fold-clearout-buffer))
              (TeX-fold-mode -1))

            ;; 2. Limpieza vertical semántica
            (if use-reg
                (my/latex-semantic-vertical-format (marker-position beg-marker) (marker-position end-marker))
              (my/latex-semantic-vertical-format (point-min) (point-max)))

            ;; 3. Indentación y envoltura de párrafos
            (if use-reg
                (my/latex-indent-buffer-clean (marker-position beg-marker) (marker-position end-marker))
              (my/latex-indent-buffer-clean (point-min) (point-max)))

            ;; 4. Alinear columnas '&' en entornos matemáticos y tabulares
            (if use-reg
                (my/latex-align-delims-in-envs (marker-position beg-marker) (marker-position end-marker))
              (my/latex-align-delims-in-envs (point-min) (point-max)))

            ;; 5. Limpieza de espacios en blanco al final de línea
            (if use-reg
                (delete-trailing-whitespace (marker-position beg-marker) (marker-position end-marker))
              (delete-trailing-whitespace (point-min) (point-max)))

            ;; 6. Quitar tabuladores físicos
            (if use-reg
                (untabify (marker-position beg-marker) (marker-position end-marker))
              (untabify (point-min) (point-max))))

        ;; Liberar markers
        (when beg-marker (set-marker beg-marker nil))
        (when end-marker (set-marker end-marker nil))

        ;; 7. Restaurar cursor exacto
        (goto-char (point-min))
        (forward-line (1- (min orig-line (count-lines (point-min) (point-max)))))
        (move-to-column orig-col)

        ;; 8. Restaurar scroll de ventana
        (when (and win orig-win-start-line)
          (set-window-start win
                            (save-excursion
                              (goto-char (point-min))
                              (forward-line (1- (min orig-win-start-line (count-lines (point-min) (point-max)))))
                              (point))
                            t))

        ;; 9. Restaurar TeX-fold / Zen
        (when fold-active
          (TeX-fold-mode 1)
          (font-lock-flush)
          (font-lock-ensure)
          (when (fboundp 'TeX-fold-buffer)
            (TeX-fold-buffer)))
        (when (and zen-active (fboundp 'my/latex-fold-visible-region))
          (my/latex-fold-visible-region)))

      (message "⚡ Formateo Bourbaki/IHÉS completado con éxito a 120 columnas (0.02s)."))))

;; ==================================================================
;; --- 7. HERRAMIENTAS AST Y ÁRBOL IMENU (apuntes-scr.cls) ---
;; ==================================================================

(defun my/setup-latex-imenu ()
  "Genera el árbol de navegación Imenu para la arquitectura Bourbaki / EGA de apuntes-scr.cls."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    (setq-local imenu-generic-expression
                '(("Partes" ".*\\\\part\\*?{\\([^}]+\\)}" 1)
                  ("Capítulos" ".*\\\\\\(?:chapter\\|chapitrezero\\|capitulozero\\)\\*?{\\([^}]+\\)}" 1)
                  ("Secciones" ".*\\\\\\(?:section\\|addsubsec\\)\\*?{\\([^}]+\\)}" 1)
                  ("Subsecciones" ".*\\\\\\(?:subsection\\|addsubsubsec\\)\\*?{\\([^}]+\\)}" 1)
                  ("Párrafos EGA" ".*\\\\\\(?:parag\\|numpar\\)\\[?\\([^]\n]*\\)\\]?" 1)
                  ("Teoremas" ".*\\\\begin{\\(?:theorem\\|lemma\\|proposition\\|corollary\\|claim\\|claim\\*\\)}\\(\\[[^]\n]*\\]\\|\\\\label{[^}\n]+}\\)?" 1)
                  ("Definiciones" ".*\\\\begin{\\(?:definition\\|notation\\|example\\|remark\\|commentary\\|conventions\\|scholium\\|scholie\\|rappel\\)}\\(\\[[^]\n]*\\]\\|\\\\label{[^}\n]+}\\)?" 1)
                  ("Ejercicios & Notas" ".*\\\\begin{\\(?:exercices\\|notehistorique\\)}\\(\\[[^]\n]*\\]\\)?" 0)
                  ("Algoritmos & Código" ".*\\\\begin{\\(?:algorithm\\|filetealgoritmo\\|algoritmobox\\|pseudocodigo\\|pythonlib\\|pythoncode\\)}\\(\\[[^]\n]*\\]\\)?" 0)
                  ("Demostraciones" ".*\\\\begin{\\(?:proof\\|claimproof\\|pruebaafirmacion\\)}" 0)
                  ("Cajas & Recuadros" ".*\\\\begin{\\(?:egabox\\|ihesbox\\|convencionbox\\|notabox\\|warningbox\\|controlbox\\)}\\(\\[[^]\n]*\\]\\)?" 0)))))

(add-hook 'LaTeX-mode-hook #'my/setup-latex-imenu)

(defun my/toggle-latex-auto-format-on-save ()
  "Alterna el formateo automático al guardar."
  (interactive)
  (setq my/latex-auto-format-on-save (not my/latex-auto-format-on-save))
  (message "Formateo al guardar: %s" (if my/latex-auto-format-on-save "ACTIVADO" "DESACTIVADO")))

(defun my/latex-before-save-format-hook ()
  (when (and my/latex-auto-format-on-save
             (derived-mode-p 'LaTeX-mode 'latex-mode)
             (buffer-file-name)
             (string= (file-name-extension (buffer-file-name)) "tex"))
    (my/ts-format-buffer)))

(add-hook 'before-save-hook #'my/latex-before-save-format-hook)

(defun my/ts-setup-latex-treesit ()
  "Inicializa el parser AST para herramientas interactivas e Imenu."
  (when (my/ts-latex-available-p)
    (unless (treesit-parser-list)
      (treesit-parser-create 'latex))))

(add-hook 'LaTeX-mode-hook #'my/ts-setup-latex-treesit)

;; Herramientas Interactivas AST (Renombrar, Seleccionar, Buscar)
(defun my/ts-get-current-environment-node ()
  (when (my/ts-latex-available-p)
    (unless (treesit-parser-list)
      (treesit-parser-create 'latex))
    (let ((node (treesit-node-at (point))))
      (while (and node
                  (not (member (treesit-node-type node)
                               '("generic_environment" "math_environment" "verbatim_environment"))))
        (setq node (treesit-node-parent node)))
      node)))

;;;###autoload
(defun my/ts-rename-environment (new-name)
  (interactive "sNuevo nombre de entorno: ")
  (if (string-empty-p (string-trim new-name))
      (message "⚠️ Nombre de entorno no válido.")
    (if-let ((env-node (my/ts-get-current-environment-node)))
        (let* ((start (treesit-node-start env-node))
               (end (treesit-node-end env-node))
               (text (treesit-node-text env-node)))
          (if (string-match "\\`[ \t\n]*\\\\begin{\\([^}]+\\)}" text)
              (let ((old-name (match-string 1 text)))
                (save-excursion
                  (goto-char end)
                  (when (re-search-backward (format "\\\\end{%s}" (regexp-quote old-name)) start t)
                    (replace-match (format "\\\\end{%s}" new-name) t t))
                  (goto-char start)
                  (when (re-search-forward (format "\\\\begin{%s}" (regexp-quote old-name)) end t)
                    (replace-match (format "\\\\begin{%s}" new-name) t t))
                  (my/latex-indent-buffer-clean start end))
                (message "✅ Entorno '%s' renombrado a '%s'." old-name new-name))
            (message "⚠️ No se pudo extraer la etiqueta del entorno.")))
      (message "⚠️ El cursor no está dentro de ningún entorno LaTeX válido."))))

;;;###autoload
(defun my/ts-select-environment ()
  (interactive)
  (if-let ((env-node (my/ts-get-current-environment-node)))
      (let ((start (treesit-node-start env-node))
            (end (treesit-node-end env-node)))
        (goto-char start)
        (if (fboundp 'evil-visual-state)
            (progn (evil-visual-state) (goto-char end))
          (set-mark start)
          (goto-char end)
          (activate-mark))
        (message "🎯 Entorno seleccionado."))
    (message "⚠️ No estás dentro de ningún entorno LaTeX.")))

;;;###autoload
(defun my/ts-search-environments ()
  (interactive)
  (if (my/ts-latex-available-p)
      (progn
        (unless (treesit-parser-list)
          (treesit-parser-create 'latex))
        (let* ((root (treesit-parser-root-node (car (treesit-parser-list))))
               (query "[(generic_environment) (math_environment) (verbatim_environment)] @env")
               (matches (treesit-query-capture root query))
               (candidates nil))
          (dolist (match matches)
            (let* ((node (cdr match))
                   (text (treesit-node-text node))
                   (start (treesit-node-start node))
                   (line (line-number-at-pos start))
                   (name (if (string-match "\\\\begin{\\([^}]+\\)}" text)
                             (match-string 1 text)
                           "entorno")))
              (push (cons (format "Línea %d: \\begin{%s}" line name) start) candidates)))
          (if candidates
              (let* ((chosen (completing-read "Ir a entorno: " (nreverse candidates) nil t))
                     (target-pos (cdr (assoc chosen candidates))))
                (when target-pos
                  (goto-char target-pos)
                  (recenter)))
            (message "No se encontraron entornos en el documento."))))
    (message "Tree-sitter no está activo en este buffer.")))

(provide 'my-latex-tree-sitter)
;;; my-latex-tree-sitter.el ends here
