;;; my-latex-expansions.el --- Corfu, Tempel, AAS, LAAS -*- lexical-binding: t; -*-

;; ==================================================================
;; --- 0. DEPENDENCIAS Y CARGA INICIAL ---
;; ==================================================================
(require 'corfu)
(require 'tempel)
(require 'cape)
(require 'my-editor)
(require 'aas)
(require 'laas)
(require 'my-latex-snippets) ;; Carga tus snippets nativos con Tempel + AAS
(require 'tesis-snippets)    ;; Carga snippets condicionales de Geometría Compleja

(declare-function eglot-completion-at-point "eglot" ())
(declare-function corfu-popupinfo-mode "corfu-popupinfo" (&optional arg))
(declare-function corfu-history-mode "corfu-history" (&optional arg))

;; ==================================================================
;; --- 1. GESTORES MAESTROS DE TAB Y SHIFT-TAB (SÚPER SALTO V3) ---
;; ==================================================================

(defconst my/latex-jump-opening-regex
  (concat "\\(?:[_^]\\)?{\\|"                ; _{ o ^{ o { (Entrar a argumentos/índices)
          "\\\\begin{[^}]+}\\|"              ; \begin{...} (Entrar a entornos)
          "\\\\left[][()}|.]\\|"             ; \left( \left[ \left. etc
          "\\\\left\\\\[a-zA-Z]+\\|"         ; \left\langle
          "\\\\\\[\\|"                       ; \[ (Ecuación display)
          "\\\\(\\|"                         ; \( (Ecuación inline)
          "\\\\langle\\|"                    ; \langle
          "\\[\\|"                           ; [ (Argumentos opcionales)
          "&\\|"                             ; & (Siguiente columna)
          "\\\\\\\\"                         ; \\ (Siguiente fila)
          )
  "Expresión regular que define las 'puertas de entrada' estructurales en LaTeX.")

(defconst my/latex-jump-closing-regex
  (concat "\\\\end{[^}]+}\\|"                ; \end{...} (Salir de entornos)
          "\\\\right[][()}|.]\\|"            ; \right) \right] \right.
          "\\\\right\\\\[a-zA-Z]+\\|"        ; \right\rangle
          "\\\\\\]\\|"                       ; \] (Cierre display)
          "\\\\)\\|"                         ; \) (Cierre inline)
          "\\\\rangle\\|"                    ; \rangle
          "}\\|"                             ; } (Salir de argumentos)
          "\\]"                              ; ] (Salir de argumentos opcionales)
          )
  "Expresión regular que define las 'puertas de salida' estructurales en LaTeX.")

(defun my/corfu-popup-visible-p ()
  "Devuelve t de forma segura solo si la ventana de Corfu existe y está abierta."
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
          (when (re-search-backward "\\\\[a-zA-Z]+" (max (point-min) (- (point) 100)) t)
            (looking-at "\\\\\\(label\\|ref\\|cref\\|Cref\\|sref\\|eref\\|cite\\|textcite\\|parencite\\|eqref\\|input\\|import\\|include\\|includegraphics\\)\\b")))))))

(defun my/ide-tab-handler ()
  "Gestor maestro de TAB. Tempel > Súper Salto Estructural Forward."
  (interactive)
  (cond
   ;; 1. TEMPEL NEXT (Prioridad Máxima)
   ((and (bound-and-true-p tempel--active) tempel--active)
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (condition-case nil (tempel-next 1) (error (tempel-done))))

   ;; 2. EXPANSIÓN DE TEMPEL (BLINDADA)
   ;; Si estamos escribiendo dentro de \label{}, \ref{}, etc., BLOQUEAMOS la expansión.
   ((and (not (my/latex-inside-protected-command-p))
         (ignore-errors (tempel-expand t))))

   ;; 3. SÚPER SALTO ESTRUCTURAL (Forward)
   ((let* ((open-re my/latex-jump-opening-regex)
           ;; Al saltar hacia adelante sobre un cierre, nos saltamos la puntuación que le siga
           (close-re (concat "\\(?:" my/latex-jump-closing-regex "\\)[.,;:]?"))
           (target-re (concat "\\(" open-re "\\)\\|\\(" close-re "\\)"))
           (orig-pos (point))
           next-pos)
      (save-excursion
        ;; Buscamos el siguiente límite estructural en el documento
        (while (and (not next-pos)
                    (re-search-forward target-re (point-max) t))
          (let ((target (match-end 0)))
            ;; Si el punto encontrado es exactamente donde ya estamos, seguimos buscando
            (if (= target orig-pos)
                t 
              ;; Si encontramos una nueva frontera, saltamos DESPUÉS de ella
              (goto-char target)
              (skip-chars-forward " \t")
              (setq next-pos (point))))))
              
      (when next-pos
        (when (my/corfu-popup-visible-p) (corfu-quit))
        (goto-char next-pos)
        t)))
        
   ;; 4. FALLBACK (Espaciado literal)
   (t
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (insert "    "))))

(defun my/ide-backtab-handler ()
  "Gestor maestro de Shift+TAB. Tempel Prev > Súper Salto Estructural Backward."
  (interactive)
  (cond
   ;; 1. TEMPEL PREVIOUS
   ((and (bound-and-true-p tempel--active) tempel--active)
    (when (my/corfu-popup-visible-p) (corfu-quit))
    (condition-case nil (tempel-previous 1) (error (tempel-done))))

   ;; 2. SÚPER SALTO ESTRUCTURAL (Backward)
   ((let* ((open-re my/latex-jump-opening-regex)
           (close-re my/latex-jump-closing-regex)
           (target-re (concat "\\(" open-re "\\)\\|\\(" close-re "\\)"))
           (orig-pos (point))
           prev-pos)
      (save-excursion
        ;; Buscamos hacia atrás en todo el documento
        (while (and (not prev-pos)
                    (re-search-backward target-re (point-min) t))
          ;; La simetría perfecta:
          ;; Si encontramos una APERTURA (grupo 1), caemos DESPUÉS de ella (para entrar).
          ;; Si encontramos un CIERRE (grupo 2), caemos ANTES de él (para re-entrar).
          (let ((target (if (match-beginning 1) (match-end 1) (match-beginning 2))))
            (if (= target orig-pos)
                t 
              (goto-char target)
              (setq prev-pos (point))))))
              
      (when prev-pos
        (when (my/corfu-popup-visible-p) (corfu-quit))
        (goto-char prev-pos)
        t)))

   ;; 3. FALLBACK
   (t nil)))

;; ==================================================================
;; --- 2. CORFU Y NERD ICONS ---
;; ==================================================================
(setq corfu-cycle t
      corfu-auto t
      corfu-auto-delay 0.1
      corfu-auto-prefix 1
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
  
  ;; TAB está desactivado en el mapa de Corfu para que no robe los saltos
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "<tab>") nil)
  
  ;; Navegación estilo Emacs/Vim (sin soltar las manos del teclado)
  (define-key corfu-map (kbd "C-j") #'corfu-next)
  (define-key corfu-map (kbd "C-k") #'corfu-previous))

(require 'nerd-icons-corfu)
(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

;; ==================================================================
;; --- 3. TEMPEL (Snippets Manuales) ---
;; ==================================================================
(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "TAB") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "<tab>") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "S-TAB") #'my/ide-backtab-handler)
  (define-key tempel-map [backtab] #'my/ide-backtab-handler))

;; ==================================================================
;; --- 4. INTEGRACIÓN PURA DE CORFU CON EGLOT Y TEMPEL ---
;; ==================================================================
(defun my/latex-path-capf ()
  "Autocompletado estilo IDE robusto y RECURSIVO para rutas en LaTeX.
Compatible con Emacs 30+. Navega infinitamente por carpetas."
  (let* ((line-up-to-point (buffer-substring-no-properties (line-beginning-position) (point)))
         cmd start extensions strip-ext)
    
    ;; 1. Detecta el comando padre
    (when (string-match "\\\\\\([a-zA-Z]+\\)\\(\\[[^]]*\\]\\)?{\\([^}]*\\)$" line-up-to-point)
      (setq cmd (match-string 1 line-up-to-point))
      (setq start (- (point) (length (match-string 3 line-up-to-point)))))
    
    (when cmd
      ;; 2. Reglas según el comando
      (cond
       ((member cmd '("input" "include" "subfile" "import"))
        (setq extensions '(".tex") strip-ext t))
       ((member cmd '("includegraphics"))
        (setq extensions '(".png" ".jpg" ".jpeg" ".pdf" ".svg" ".eps") strip-ext nil))
       ((member cmd '("addbibresource" "bibliography"))
        (setq extensions '(".bib") strip-ext nil)))
      
      (when extensions
        (list start (point)
              ;; 3. EL MOTOR DE BÚSQUEDA
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
              ;; 4. ¡LA MAGIA DE ENTER!
              (lambda (str status)
                (when (eq status 'finished)
                  (if (string-suffix-p "/" str)
                      ;; Si presionaste Enter en una carpeta, reactiva el menú al instante
                      (run-at-time 0.01 nil #'completion-at-point)
                    ;; Si es un archivo, quita la extensión si corresponde
                    (when strip-ext
                      (let ((ext (file-name-extension str)))
                        (when ext
                          (delete-char (- (1+ (length ext)))))))))))))))

(defun my/setup-latex-capf ()
  "Alinea los motores de autocompletado para LaTeX."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    ;; Evita que Corfu colapse al teclear la barra '/' en rutas
    (setq-local corfu-quit-at-boundary nil)
    
    (setq-local completion-at-point-functions
                (list #'my/latex-path-capf
                      #'tempel-complete
                      #'eglot-completion-at-point
                      #'cape-file
                      #'cape-dabbrev))
    ;; Usar cape-super-capf si está disponible (versiones nuevas de cape)
    (when (fboundp 'cape-super-capf)
      (setq-local completion-at-point-functions
                  (list (cape-super-capf
                         #'my/latex-path-capf
                         #'tempel-complete
                         #'eglot-completion-at-point
                         #'cape-file
                         #'cape-dabbrev))))))

(add-hook 'eglot-managed-mode-hook #'my/setup-latex-capf)

;; ==================================================================
;; --- 5. MICRO-SNIPPETS AUTOMÁTICOS (LAAS) ---
;; ==================================================================
(setq laas-enable-auto-space t)

(add-hook 'LaTeX-mode-hook #'laas-mode)

(with-eval-after-load 'laas
  (aas-set-snippets 'laas-mode
    :cond #'laas-mathp
    ;; 1. Operadores y Relaciones Instantáneas
    ":=" "\\coloneq"
    "!=" "\\ne"
    "-->" "\\longrightarrow"
    "->" "\\to"
    "iff" "\\iff"
    "imp" "\\implies"
    "ot"  "\\otimes"

    ;; 2. Exponentes ultra-frecuentes
    "op"  "^{\\mathrm{op}}"
    
    ;; 3. Símbolos Ideales, Anillos y Categorías (Álgebra Conmutativa)
    "sO" "\\symcal{O}"
    "sA" "\\symcal{A}"
    "sM" "\\symfrak{m}"
    "sP" "\\symfrak{p}"
    "sQ" "\\symfrak{q}"
    
    ;; 4. Operadores algebraicos al vuelo (Comandos nativos de tus documentclass)
    "Spec" "\\Spec"
    "Hom"  "\\Hom"
    "Ker"  "\\Ker"
    "Cok"  "\\Coker"
    "Im"   "\\Image"
    "End"  "\\End"
    "Aut"  "\\Aut"
    "Ext"  "\\Ext"
    "Tor"  "\\Tor"
    "Frac" "\\Frac"
    "Proj" "\\Proj"))

;; ==================================================================
;; --- 6. ACTIVACIÓN DEL TAB INTELIGENTE (EVIL MODE) ---
;; ==================================================================
(add-hook 'LaTeX-mode-hook
          (lambda ()
            ;; 1. Asignar en modo Emacs estándar
            (local-set-key (kbd "TAB") #'my/ide-tab-handler)
            (local-set-key (kbd "<tab>") #'my/ide-tab-handler)
            (local-set-key (kbd "<backtab>") #'my/ide-backtab-handler)
            (local-set-key (kbd "S-TAB") #'my/ide-backtab-handler)
            
            ;; 2. Asignar en el modo Inserción de Evil (Crucial)
            (when (bound-and-true-p evil-mode)
              (evil-local-set-key 'insert (kbd "TAB") #'my/ide-tab-handler)
              (evil-local-set-key 'insert (kbd "<tab>") #'my/ide-tab-handler)
              (evil-local-set-key 'insert (kbd "<backtab>") #'my/ide-backtab-handler)
              (evil-local-set-key 'insert (kbd "S-TAB") #'my/ide-backtab-handler))))

(provide 'my-latex-expansions)
;;; my-latex-expansions.el ends here
