;;; my-latex-tree-sitter.el --- Refactorización y búsqueda sintáctica con Tree-sitter -*- lexical-binding: t; -*-

(require 'treesit)
(require 'evil nil t)

(declare-function TeX-fold-clearout-buffer "tex-fold" ())
(declare-function TeX-fold-buffer "tex-fold" ())
(declare-function TeX-fold-mode "tex-fold" (&optional arg))
(declare-function rainbow-delimiters-mode "rainbow-delimiters" (&optional arg))
(declare-function my/latex-fold-visible-region "my-latex-visuals" ())

(defvar-local my/latex-auto-format-on-save t
  "Indica si se debe formatear el buffer .tex al guardar.")

(defun my/ts-latex-available-p ()
  "Verifica si la gramática de Tree-sitter para LaTeX está disponible."
  (treesit-language-available-p 'latex))

(defun my/ts-get-current-environment-node ()
  "Devuelve el nodo AST del entorno LaTeX donde se encuentra el cursor."
  (when (my/ts-latex-available-p)
    (treesit-parent-until
     (treesit-node-at (point))
     (lambda (n)
       (memq (intern-soft (treesit-node-type n))
             '(generic_environment math_environment environment))))))

;;;###autoload
(defun my/ts-rename-environment (new-name)
  "Renombra de forma síncrona el entorno LaTeX bajo el cursor (Begin y End)."
  (interactive "sNuevo nombre del entorno: ")
  (if-let ((env-node (my/ts-get-current-environment-node)))
      (let* ((begin-node (treesit-node-child-by-field-name env-node "begin"))
             (end-node (treesit-node-child-by-field-name env-node "end"))
             (begin-name (and begin-node (treesit-node-child-by-field-name begin-node "name")))
             (end-name (and end-node (treesit-node-child-by-field-name end-node "name"))))
        (if (and begin-name end-name)
            (save-excursion
              ;; Cambiar end primero para no alterar los offsets del nodo begin
              (goto-char (treesit-node-start end-name))
              (delete-region (treesit-node-start end-name) (treesit-node-end end-name))
              (insert (format "{%s}" new-name))
              ;; Cambiar begin
              (goto-char (treesit-node-start begin-name))
              (delete-region (treesit-node-start begin-name) (treesit-node-end begin-name))
              (insert (format "{%s}" new-name))
              (message "✅ Entorno refactorizado a '%s'." new-name))
          (message "⚠️ No se pudieron obtener las etiquetas del entorno.")))
    (message "⚠️ El cursor no está dentro de ningún entorno LaTeX.")))

;;;###autoload
(defun my/ts-select-environment ()
  "Selecciona visualmente el entorno LaTeX completo delimitado por el AST."
  (interactive)
  (if-let ((env-node (my/ts-get-current-environment-node)))
      (progn
        (goto-char (treesit-node-start env-node))
        (when (fboundp 'evil-visual-make-region)
          (evil-visual-make-region (treesit-node-start env-node) (treesit-node-end env-node)))
        (message "Entorno seleccionado (%d-%d)." (treesit-node-start env-node) (treesit-node-end env-node)))
    (message "⚠️ El cursor no está dentro de ningún entorno LaTeX.")))

;;;###autoload
(defun my/ts-search-environments ()
  "Navega por los entornos LaTeX del buffer mediante Tree-sitter."
  (interactive)
  (if (my/ts-latex-available-p)
      (let* ((query '((generic_environment (begin (curly_group_text text: (text word: (word) @env_name))))
                      (math_environment (begin (curly_group_text text: (text word: (word) @env_name))))))
             (parser (treesit-parser-create 'latex))
             (matches (treesit-query-capture (treesit-parser-root-node parser) query))
             (candidates nil))
        (dolist (match matches)
          (let* ((node (cdr match))
                 (text (treesit-node-text node t))
                 (pos (treesit-node-start node))
                 (line (line-number-at-pos pos)))
            (push (cons (format "Línea %d: \\begin{%s}" line text) pos) candidates)))
        (if candidates
            (let* ((choices (nreverse candidates))
                   (choice (completing-read "🔍 Entornos AST: " choices nil t))
                   (target-pos (cdr (assoc choice choices))))
              (when target-pos
                (goto-char target-pos)))
          (message "No se encontraron entornos LaTeX en el archivo.")))
    (message "⚠️ Tree-sitter no está disponible para LaTeX.")))

;; Reglas de indentación estructuradas completas para LaTeX con Tree-sitter
(defvar my/ts-latex-indent-rules
  '((latex
     ((node-is "end") parent-bol 0)
     ((node-is "\\]") parent-bol 0)
     ((node-is "\\[") parent-bol 0)
     ((parent-is "verbatim_environment") no-indent 0)
     ((parent-is "displayed_equation") parent-bol 4)
     ((parent-is "generic_environment") parent-bol 4)
     ((parent-is "math_environment") parent-bol 4)
     ((parent-is "enum_item") parent-bol 4)
     ((parent-is "text") parent-bol 0)
     ((parent-is "inline_formula") parent-bol 0)
     ((parent-is "curly_group") parent-bol 2)
     ((parent-is "brack_group") parent-bol 2)
      ((parent-is "source_file") column-0 0))))

(defun my/ts-normalize-macro-spacing ()
  "Normaliza espacios alrededor de comandos LaTeX en el buffer.
Optimizado: solo procesa la región visible para evitar O(n²) en archivos grandes."
  (save-excursion
    ;; Limitar el procesamiento a la región visible + margen de 200 líneas
    (let ((start (max (point-min) (- (window-start) 200)))
          (end (min (point-max) (+ (window-end) 200))))
      (goto-char start)
      (while (< (point) end)
        ;; Ignorar definiciones de macros en el preámbulo o entornos verbatim
        (let ((line-str (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
          (unless (string-match-p "\\(?:\\\\\\(?:re\\)?newcommand\\|\\\\def\\|\\\\newenvironment\\|\\\\Declare\\)" line-str)
            (let ((node (and (my/ts-latex-available-p) (treesit-node-at (point)))))
              (unless (and node (treesit-parent-until node (lambda (n) (string= (treesit-node-type n) "verbatim_environment"))))
                ;; Regla A: Delimitadores, operadores, puntuación o llaves unidos a un comando \
                (let ((bound (line-end-position)))
                  (goto-char (line-beginning-position))
                  (while (re-search-forward "\\([][(){},;:=+<>|!~&^*#.-]\\)\\\\\\([A-Za-z]+\\)" bound t)
                    (replace-match "\\1 \\\\\\2" t)
                    (setq bound (line-end-position)))
                  ;; Regla B: Dos comandos consecutivos unidos sin espacio (\cmdA\cmdB)
                  (goto-char (line-beginning-position))
                  (while (re-search-forward "\\(\\\\[A-Za-z]+\\)\\\\\\([A-Za-z]+\\)" bound t)
                    (replace-match "\\1 \\\\\\2" t)
                    (setq bound (line-end-position)))
                  ;; Regla C: Letras o números unidos directamente al inicio de un comando (ej. 2\pi, x\to, a\in, V\left)
                  (goto-char (line-beginning-position))
                  (while (re-search-forward "\\([A-Za-z0-9]\\)\\\\\\([A-Za-z]+\\)" bound t)
                    (replace-match "\\1 \\\\\\2" t)
                    (setq bound (line-end-position)))
                  ;; Regla D: Despegar llave de cierre \cmd{arg} de subíndices _, exponentes ^, paréntesis, corchetes, puntuaciones u operadores
                  (goto-char (line-beginning-position))
                  (while (re-search-forward "\\(\\\\\\(\\(?:sym\\|math\\|over\\|under\\|wide\\)[A-Za-z]+\\|hat\\|tilde\\|bar\\|check\\|vec\\|dot\\|norm\\|abs\\|re\\|im\\|expectation\\|variance\\|serie\\|operatorname\\|textnormal\\|text\\|boldsymbol\\|mathscr\\){[^}\n]+}\\)\\([][_^()><,;:.=+!*~/|-]\\)" bound t)
                    (replace-match "\\1 \\3" t)
                    (setq bound (line-end-position))))))))
        (forward-line 1)))))

(defun my/ts-normalize-operator-and-index ()
  "Normaliza los comandos \\operatorname e \\index en el buffer.
Asegura la sintaxis correcta en PDF y el plegado en Modo Zen."
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (let ((line-str (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
        (unless (string-match-p "\\(?:\\\\\\(?:re\\)?newcommand\\|\\\\def\\|\\\\newenvironment\\|\\\\Declare\\)" line-str)
          (let ((node (and (my/ts-latex-available-p) (treesit-node-at (point)))))
            (unless (and node (treesit-parent-until node (lambda (n) (string= (treesit-node-type n) "verbatim_environment"))))
              (let ((bound (line-end-position)))
                ;; 1. Para \operatorname{...}: Despegar de subíndices _, exponentes ^, delimitadores u operadores algebraicos
                (goto-char (line-beginning-position))
                (while (re-search-forward "\\(\\\\operatorname\\*?{[^}\n]+}\\)\\([][_^()><|~-]\\)" bound t)
                  (replace-match "\\1 \\2" t)
                  (setq bound (line-end-position)))
                ;; 2. Para \index{...}: Respetar puntuación (, . ; : !), pero despegar si está pegado a otra palabra o comando
                (goto-char (line-beginning-position))
                (while (re-search-forward "\\(\\\\index{[^}\n]+}\\)\\([A-Za-z(0-9\\]\\)" bound t)
                  (unless (save-match-data (string-match-p "^[,.;:!)]" (match-string 2)))
                    (replace-match "\\1 \\2" t))
                  (setq bound (line-end-position)))
                ;; 3. Normalizar el contenido INTERNO de \index y \operatorname por si incluye macros sin espaciar (ej. \index{\symcal{A}})
                (goto-char (line-beginning-position))
                (while (re-search-forward "\\\\(?:index\\|operatorname\\*?){[^}\n]+}" bound t)
                  (let* ((full-str (match-string 0))
                         (cleaned (replace-regexp-in-string "\\([([,:=+<>|]\\)\\\\\\([A-Za-z]+\\)" "\\1 \\\\\\2" full-str)))
                    (unless (string= full-str cleaned)
                      (replace-match cleaned t t)))
                  (setq bound (line-end-position))))))))
      (forward-line 1))))

;;;###autoload
(defun my/ts-format-buffer ()
  "Formatea el buffer .tex a 100 columnas de texto plano con Tree-sitter."
  (interactive)
  (when (and (derived-mode-p 'LaTeX-mode 'latex-mode) (not buffer-read-only))
    (undo-boundary)
    (let ((zen-active (bound-and-true-p my/latex-visual-mode))
          (fold-active (bound-and-true-p TeX-fold-mode))
          (prettify-active (bound-and-true-p prettify-symbols-mode))
          (rainbow-active (bound-and-true-p rainbow-delimiters-mode)))
      (unwind-protect
          (save-excursion
            ;; 0. Desactivar temporalmente los efectos visuales del Modo Zen
            ;; para garantizar que el formateo y cálculo de 100 columnas operen
            ;; estrictamente sobre el CONTENIDO REAL del archivo (texto plano).
            (when fold-active
              (when (fboundp 'TeX-fold-clearout-buffer)
                (TeX-fold-clearout-buffer))
              (TeX-fold-mode -1))
            (when prettify-active
              (prettify-symbols-mode -1))
            (when rainbow-active
              (rainbow-delimiters-mode -1))
            
            (setq-local fill-column 100)
            (setq-local LaTeX-fill-column 100)
            
            ;; 1. Indentación estructurada Tree-sitter
            (when (my/ts-latex-available-p)
              (unless (treesit-parser-list)
                (ignore-errors (treesit-parser-create 'latex)))
              (when (treesit-parser-list)
                (setq-local treesit-simple-indent-rules my/ts-latex-indent-rules)
                (setq-local indent-line-function #'treesit-indent)))
            
            ;; 2. Limpiar sangrías desalineadas preexistentes en líneas normales de texto
            ;; (Sin tocar entornos de código crudo como verbatim o comandos estructurales)
            (goto-char (point-min))
            (while (re-search-forward "^[ \t]\\{2,\\}" nil t)
              (let ((node (and (my/ts-latex-available-p) (treesit-parser-list) (treesit-node-at (point)))))
                (unless (or (save-match-data (looking-at "[ \t]*\\\\\\(begin\\|end\\|item\\|label\\|chapter\\|section\\|subsection\\|subsubsection\\|part\\|\\[\\|\\]\\|\\$\\)"))
                            (and node (treesit-parent-until node (lambda (n) (string= (treesit-node-type n) "verbatim_environment")))))
                  (replace-match ""))))

            ;; 2.5. Normalizar espaciado alrededor de comandos para habilitar reemplazos del Modo Zen
            (my/ts-normalize-macro-spacing)
            (my/ts-normalize-operator-and-index)

            ;; 3. Relleno de texto plano a 100 columnas respetando entornos y matemáticas
            (when (fboundp 'LaTeX-fill-buffer)
              (ignore-errors (LaTeX-fill-buffer nil)))
            
            ;; 4. Ajuste de sangría por nodos AST y limpieza final de espacios y tabulaciones
            (indent-region (point-min) (point-max))
            (untabify (point-min) (point-max))
            (delete-trailing-whitespace (point-min) (point-max)))
        
        ;; 5. Restaurar exactamente el estado del Modo Zen y visualización
        (when prettify-active
          (prettify-symbols-mode 1))
        (when rainbow-active
          (rainbow-delimiters-mode 1))
        (when fold-active
          (TeX-fold-mode 1)
          (font-lock-flush)
          (font-lock-ensure)
          (when (fboundp 'TeX-fold-buffer)
            (TeX-fold-buffer)))
        (when (and zen-active (fboundp 'my/latex-fold-visible-region))
          (my/latex-fold-visible-region))))
    (undo-boundary)
    (message "⚡ Buffer .tex formateado inteligentemente sobre texto plano (100 columnas).")))

;;;###autoload
(defun my/toggle-latex-auto-format-on-save ()
  "Alterna el formateo automático al guardar buffers .tex."
  (interactive)
  (setq my/latex-auto-format-on-save (not my/latex-auto-format-on-save))
  (message "Formateo automático al guardar: %s"
           (if my/latex-auto-format-on-save "ACTIVADO" "DESACTIVADO")))

(defun my/latex-before-save-format-hook ()
  "Hook ejecutado antes de guardar buffers LaTeX para formatear automáticamente."
  (when (and (bound-and-true-p my/latex-auto-format-on-save)
             (derived-mode-p 'LaTeX-mode 'latex-mode)
             (buffer-file-name)
             (string= (file-name-extension (buffer-file-name)) "tex"))
    (my/ts-format-buffer)))

;; Registrar el formateador silencioso al guardar
(add-hook 'before-save-hook #'my/latex-before-save-format-hook)

;;;###autoload
(defun my/ts-setup-latex-treesit ()
  "Inicializa el parser de Tree-sitter en buffers de LaTeX."
  (when (my/ts-latex-available-p)
    (treesit-parser-create 'latex)
    (setq-local treesit-simple-indent-rules my/ts-latex-indent-rules)
    (setq-local indent-line-function #'treesit-indent)
    (treesit-major-mode-setup)))

(defun my/setup-latex-imenu ()
  "Configura imenu para indexar estructuras del Zen Mode (secciones, definiciones, afirmaciones, claims)."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    (setq-local imenu-generic-expression
                '(("Capítulo" "\\\\chapter\\*?{\\([^}]+\\)}" 1)
                  ("Sección" "\\\\section\\*?{\\([^}]+\\)}" 1)
                  ("Subsección" "\\\\subsection\\*?{\\([^}]+\\)}" 1)
                  ("Teorema/Lema" "\\\\begin{\\(theorem\\|lemma\\|corollary\\|proposition\\)}\\(?:\\[\\([^]]+\\)\\]\\)?" 1)
                  ("Definición" "\\\\begin{definition}\\(?:\\[\\([^]]+\\)\\]\\)?" 1)
                  ("Afirmación" "\\\\begin{\\(afirmacion\\|claim\\*?\\)}\\(?:\\[\\([^]]+\\)\\]\\)?" 1)))))

(add-hook 'LaTeX-mode-hook #'my/setup-latex-imenu)

(provide 'my-latex-tree-sitter)
;;; my-latex-tree-sitter.el ends here
