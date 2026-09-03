;;; my-latex-expansions.el --- Corfu, Tempel, Citar y Súper Salto V4 -*- lexical-binding: t; -*-

;; ==================================================================
;; --- 0. DEPENDENCIAS Y CARGA INICIAL ---
;; ==================================================================
(require 'corfu)
(require 'tempel)
(require 'cape)
(require 'citar nil t)
(require 'my-editor)
(require 'aas)
(require 'laas)
(require 'my-latex-snippets)
(require 'tesis-snippets nil t)

(declare-function eglot-completion-at-point "eglot" ())
(declare-function corfu-popupinfo-mode "corfu-popupinfo" (&optional arg))
(declare-function corfu-history-mode "corfu-history" (&optional arg))
(declare-function citar-capf "citar" ())

;; ==================================================================
;; --- 1. GESTORES MAESTROS DE TAB Y SHIFT-TAB (SÚPER SALTO V4) ---
;; ==================================================================

(defconst my/latex-jump-opening-regex
  (concat "\\(?:[_^]\\)?{\\|"                ; _{ o ^{ o { (argumentos / índices)
          "\\\\begin{[^}]+}\\|"              ; \begin{...} (entornos)
          "\\\\left[][()}|.]\\|"             ; \left( \left[ \left. etc.
          "\\\\left\\\\[a-zA-Z]+\\|"         ; \left\langle
          "\\\\\\[\\|"                       ; \[ (display math)
          "\\\\(\\|"                         ; \( (inline math)
          "\\\\langle\\|"                    ; \langle
          "\\[\\|"                           ; [ (opcionales)
          "&\\|"                             ; & (columna)
          "\\\\\\\\\\|"                      ; \\ (fila)
          "«\\|"                             ; « (comilla Bourbaki)
          "\\$"                              ; $ (inline math)
          )
  "Expresión regular de fronteras de entrada estructurales en LaTeX.")

(defconst my/latex-jump-closing-regex
  (concat "\\\\end{[^}]+}\\|"                ; \end{...}
          "\\\\right[][()}|.]\\|"            ; \right) etc.
          "\\\\right\\\\[a-zA-Z]+\\|"        ; \right\rangle
          "\\\\\\]\\|"                       ; \] (cierre display)
          "\\\\)\\|"                         ; \) (cierre inline)
          "\\\\rangle\\|"                    ; \rangle
          "}\\|"                             ; } (cierre argumento)
          "\\]\\|"                           ; ] (cierre opcional)
          "»\\|"                             ; » (cierre comilla)
          "\\$"                              ; $ (cierre inline math)
          )
  "Expresión regular de fronteras de salida estructurales en LaTeX.")

(defun my/corfu-popup-visible-p ()
  "Devuelve t si el menú flotante de Corfu está visible."
  (and (bound-and-true-p corfu-mode)
       (boundp 'corfu--frame)
       corfu--frame
       (frame-live-p corfu--frame)
       (frame-visible-p corfu--frame)))

(defun my/latex-inside-protected-command-p ()
  "Evita expandir snippets dentro de argumentos de citas y referencias."
  (let ((ppss (syntax-ppss)))
    (when (nth 1 ppss)
      (save-excursion
        (goto-char (nth 1 ppss))
        (when (eq (char-after) ?{)
          (when (re-search-backward "\\\\[a-zA-Z*]+" (max (point-min) (- (point) 120)) t)
            (looking-at "\\\\\\(label\\|ref\\|cref\\|Cref\\|sref\\|eref\\|cite\\|textcite\\|parencite\\|eqref\\|input\\|import\\|include\\|includegraphics\\|bibliography\\|addbibresource\\)\\b")))))))

(defun my/ide-tab-handler ()
  "Gestor maestro de TAB.
Prioridades: Tempel Next > Expansión Snippet > Indentación en Blanco > Súper Salto V4 > Fallback."
  (interactive)
  (cond
   ;; 1. NAVEGACIÓN TEMPEL (Prioridad Máxima en Snippets Activos)
   ((and (bound-and-true-p tempel--active) tempel--active)
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (condition-case nil (tempel-next 1) (error (tempel-done))))

   ;; 2. EXPANSIÓN DE SNIPPET TEMPEL (A demanda bajo el cursor)
   ((and (not (my/latex-inside-protected-command-p))
         (ignore-errors (tempel-expand t))))

   ;; 3. INDENTACIÓN SEGURA (Si estamos en una línea vacía o antes de la primera palabra)
   ((and (looking-back "^[ \t]*" (line-beginning-position))
         (looking-at-p "[ \t]*$"))
    (indent-according-to-mode))

   ;; 4. SÚPER SALTO ESTRUCTURAL ADELANTE (V4)
   ((let* ((open-re my/latex-jump-opening-regex)
           (close-re (concat "\\(?:" my/latex-jump-closing-regex "\\)[.,;:]?"))
           (target-re (concat "\\(" open-re "\\)\\|\\(" close-re "\\)"))
           (orig-pos (point))
           next-pos)
      (save-excursion
        (while (and (not next-pos)
                    (re-search-forward target-re (point-max) t))
          (let ((match-beg (match-beginning 0))
                (target (match-end 0)))
            ;; Filtrar matches inválidos:
            ;; a) No saltar si es la posición actual
            ;; b) Ignorar delimitadores dentro de comentarios (% ...)
            ;; c) Ignorar dólares escapados (\$)
            (unless (or (= target orig-pos)
                        (nth 4 (syntax-ppss target))
                        (and (string-suffix-p "$" (match-string 0))
                             (eq (char-before match-beg) ?\\)))
              (goto-char target)
              ;; Si saltamos sobre \\ o fin de línea, saltar a la siguiente fila indentada
              (if (looking-at "[ \t]*\n[ \t]*")
                  (goto-char (match-end 0))
                (skip-chars-forward " \t"))
              (setq next-pos (point))))))
      (when next-pos
        (when (my/corfu-popup-visible-p) (corfu-quit))
        (goto-char next-pos)
        t)))

   ;; 5. FALLBACK (Espacios de sangría)
   (t
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (indent-according-to-mode))))

(defun my/ide-backtab-handler ()
  "Gestor maestro de Shift+TAB. Tempel Previous > Súper Salto Estructural Atrás (V4)."
  (interactive)
  (cond
   ;; 1. TEMPEL PREVIO
   ((and (bound-and-true-p tempel--active) tempel--active)
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (condition-case nil (tempel-previous 1) (error (tempel-done))))

   ;; 2. SÚPER SALTO ESTRUCTURAL ATRÁS
   ((let* ((open-re my/latex-jump-opening-regex)
           (close-re my/latex-jump-closing-regex)
           (target-re (concat "\\(" open-re "\\)\\|\\(" close-re "\\)"))
           (orig-pos (point))
           prev-pos)
      (save-excursion
        (while (and (not prev-pos)
                    (re-search-backward target-re (point-min) t))
          (let* ((match-beg (match-beginning 0))
                 (target (if (match-beginning 1) (match-end 1) (match-beginning 2))))
            (unless (or (= target orig-pos)
                        (nth 4 (syntax-ppss match-beg))
                        (and (string-suffix-p "$" (match-string 0))
                             (eq (char-before match-beg) ?\\)))
              (goto-char target)
              (setq prev-pos (point))))))
      (when prev-pos
        (when (my/corfu-popup-visible-p) (corfu-quit))
        (goto-char prev-pos)
        t)))

   ;; 3. FALLBACK
   (t nil)))

;; ==================================================================
;; --- 2. CORFU (CONFIGURACIÓN OPTIMIZADA DE RENDIMIENTO) ---
;; ==================================================================
(setq corfu-cycle t
      corfu-auto t
      corfu-auto-delay 0.15          ;; Pausa de 150ms: cero sobrecarga de CPU al tipear
      corfu-auto-prefix 2            ;; Se activa a partir de 2 letras (evita disparos accidentales)
      corfu-preselect 'first
      corfu-preview-current t
      corfu-quit-no-match t
      corfu-quit-at-boundary 'separator
      global-corfu-minibuffer nil)

(global-corfu-mode 1)
(corfu-history-mode 1)
(corfu-popupinfo-mode 1)

(with-eval-after-load 'corfu
  ;; Enter acepta la sugerencia
  (define-key corfu-map (kbd "RET") #'corfu-insert)
  
  ;; Desactivar TAB en Corfu para que no interfiera con Súper Salto
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "<tab>") nil)
  
  ;; Navegación en el menú con C-j y C-k sin levantar las manos
  (define-key corfu-map (kbd "C-j") #'corfu-next)
  (define-key corfu-map (kbd "C-k") #'corfu-previous))

(require 'nerd-icons-corfu)
(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

;; ==================================================================
;; --- 3. TEMPEL (MAPEO DE NAVEGACIÓN) ---
;; ==================================================================
(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "TAB") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "<tab>") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "S-TAB") #'my/ide-backtab-handler)
  (define-key tempel-map [backtab] #'my/ide-backtab-handler))

;; ==================================================================
;; --- 4. COMPLETADO CONTEXTUAL (CAPF: RUTAS, CITAS, TEMPEL, LSP) ---
;; ==================================================================

(defun my/latex-path-capf ()
  "Autocompletado recursivo para rutas en \\input, \\import, \\includegraphics, etc."
  (let* ((line-up-to-point (buffer-substring-no-properties (line-beginning-position) (point)))
         cmd start extensions strip-ext)
    
    ;; 1. Detectar comando padre (soporta 1 o 2 pares de llaves como en \import{dir/}{archivo})
    (when (string-match "\\\\\\([a-zA-Z]+\\)\\(\\[[^]]*\\]\\)?\\(?:{[^}]*}\\)?{\\([^}]*\\)$" line-up-to-point)
      (setq cmd (match-string 1 line-up-to-point))
      (setq start (- (point) (length (match-string 3 line-up-to-point)))))
    
    (when cmd
      ;; 2. Filtros según la macro
      (cond
       ((member cmd '("input" "include" "subfile" "import" "subimport"))
        (setq extensions '(".tex") strip-ext t))
       ((member cmd '("includegraphics"))
        (setq extensions '(".png" ".jpg" ".jpeg" ".pdf" ".svg" ".eps") strip-ext nil))
       ((member cmd '("addbibresource" "bibliography"))
        (setq extensions '(".bib") strip-ext nil)))
      
      (when extensions
        (list start (point)
              ;; 3. Exploración del sistema de archivos
              (lambda (string pred action)
                (if (eq action 'metadata)
                    '(metadata (category . file))
                  (let ((my-pred (lambda (name)
                                   (or (string-suffix-p "/" name)
                                       (cl-some (lambda (ext) (string-suffix-p ext name t)) extensions)))))
                    (read-file-name-internal string
                                             (if pred
                                                 (lambda (x) (and (funcall pred x) (funcall my-pred x)))
                                               my-pred)
                                             action))))
              :exclusive 'yes
              :exit-function
              ;; 4. Acciones tras pulsar Enter
              (lambda (str status)
                (when (eq status 'finished)
                  (if (string-suffix-p "/" str)
                      (run-at-time 0.01 nil #'completion-at-point)
                    (when strip-ext
                      (let ((ext (file-name-extension str)))
                        (when ext
                          (delete-char (- (1+ (length ext)))))))))))))))

(defun my/setup-latex-capf ()
  "Configura fuentes de completado ordenadas contextualmente para LaTeX."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    (setq-local corfu-quit-at-boundary nil)
    
    (setq-local completion-at-point-functions
                (delq nil
                      (list
                       ;; 1. Rutas de archivos (exclusivo para \input, \includegraphics)
                       #'my/latex-path-capf
                       
                       ;; 2. Citas de Zotero con Citar (dentro de \cite, \parencite, etc.)
                       (when (fboundp 'citar-capf) #'citar-capf)
                       
                       ;; 3. Snippets de Tempel
                       #'tempel-complete
                       
                       ;; 4. TexLab (LSP) + Palabras locales del buffer
                       (if (fboundp 'cape-super-capf)
                           (cape-super-capf
                            #'eglot-completion-at-point
                            #'cape-dabbrev)
                         #'eglot-completion-at-point))))))

;; Activar CAPF al entrar en LaTeX
(add-hook 'LaTeX-mode-hook #'my/setup-latex-capf)

;; ==================================================================
;; --- 5. MICRO-SNIPPETS AUTOMÁTICOS (LAAS) ---
;; ==================================================================
(setq laas-enable-auto-space t)

;; Activar laas-mode y aas-mode de forma limpia
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (unless (bound-and-true-p laas-mode)
              (laas-mode 1))
            (when (and (bound-and-true-p laas-mode)
                       (not (bound-and-true-p aas-mode)))
              (aas-mode 1))))

;; ==================================================================
;; --- 6. ACTIVACIÓN DEL TAB INTELIGENTE (EVIL MODE) ---
;; ==================================================================
(add-hook 'LaTeX-mode-hook
          (lambda ()
            ;; 1. Modo Emacs estándar
            (local-set-key (kbd "TAB") #'my/ide-tab-handler)
            (local-set-key (kbd "<tab>") #'my/ide-tab-handler)
            (local-set-key (kbd "<backtab>") #'my/ide-backtab-handler)
            (local-set-key (kbd "S-TAB") #'my/ide-backtab-handler)

            ;; 2. Modo Inserción de Evil
            (when (bound-and-true-p evil-mode)
              (evil-local-set-key 'insert (kbd "TAB") #'my/ide-tab-handler)
              (evil-local-set-key 'insert (kbd "<tab>") #'my/ide-tab-handler)
              (evil-local-set-key 'insert (kbd "<backtab>") #'my/ide-backtab-handler)
              (evil-local-set-key 'insert (kbd "S-TAB") #'my/ide-backtab-handler))))

(provide 'my-latex-expansions)
;;; my-latex-expansions.el ends here