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
;; --- 1. GESTOR MAESTRO DE TABULACIÓN ---
;; ==================================================================		
(defun my/ide-tab-handler ()
  "Gestor maestro de TAB. Prioridad: Tempel Jump > Tempel Expand > Corfu > Smart Jump."
  (interactive)
  (cond
   ;; 1. TEMPEL NEXT (¡Prioridad Máxima Absoluta!)
   ;; Si estamos dentro de un snippet, TAB siempre salta (e ignora Corfu).
   ((and (bound-and-true-p tempel--active) tempel--active)
    ;; Si el menú flotante estorba, lo cerramos instantáneamente
    (when (and (bound-and-true-p corfu-mode) 
               (frame-live-p corfu--frame) 
               (frame-visible-p corfu--frame))
      (corfu-quit))
    (condition-case nil
        (tempel-next 1)
      (error (tempel-done))))

   ;; 2. EXPANSIÓN DE TEMPEL
   ((ignore-errors (tempel-expand t)))

   ;; 3. CORFU (Autocompletar SOLO si NO estamos en un snippet de Tempel)
   ((and (bound-and-true-p corfu-mode)
         (frame-live-p corfu--frame)
         (frame-visible-p corfu--frame))
    (corfu-complete))

   ;; 4. SMART JUMP ESTRUCTURAL (Navegación mágica)
   ((let* ((pos (point))
           (next-pos
            (save-excursion
              (cond
               ;; Caso A: A la mitad de un comando (ej. \al|pha) -> salta al final
               ((and (looking-back "\\\\[a-zA-Z]*" (line-beginning-position))
                     (looking-at "[a-zA-Z]+\\*?"))
                (match-end 0))
               
               ;; Caso B: Buscar hacia adelante
               ((re-search-forward
                 (rx (* (any " \t\n\r")) ;; Ignorar espacios
                     (or
                      ;; 1. \begin{ y \end{ -> Deja el cursor ADENTRO: \begin{ |
                      (seq "\\" (or "begin" "end") (* space) "{")
                      
                      ;; 2. Macros con llaves -> Deja el cursor ADENTRO: \textbf{ |
                      (seq "\\" (+ alpha) (? "*") (* space) "{")
                      
                      ;; 3. Comandos de cierre grandes y delimitadores agrupados en 1 solo salto TAB
                      (+ (or (seq "\\" (or "right)" "right]" "right}" "right|"
                                           "right\\vert" "right\\Vert"
                                           "rangle" "rceil" "rfloor"
                                           ")" "]" "}"))
                             "$$"
                             (any "{" "}" "[" "]" "(" ")" "$" "|" ">" "\"" "'")))
                      
                      ;; 4. Macros normales sin llaves (\alpha, \item) -> Salta la palabra
                      (seq "\\" (+ alpha) (? "*"))))
                 (line-end-position 2) t)
                (match-end 0))
               
               (t nil)))))
      (when next-pos
        (goto-char next-pos)
        t)))

   ;; 5. INDENTACIÓN NATIVA
   (t
    (indent-for-tab-command))))
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
  
  ;; TAB gestiona los saltos según nuestra nueva lógica
  (define-key corfu-map (kbd "TAB") #'my/ide-tab-handler)
  (define-key corfu-map (kbd "<tab>") #'my/ide-tab-handler)
  
  ;; Navegación estilo Emacs/Vim (sin soltar las manos del teclado)
  (define-key corfu-map (kbd "C-j") #'corfu-next)
  (define-key corfu-map (kbd "C-k") #'corfu-previous))

;; Opcional: Para ir hacia ATRÁS en los placeholders de Tempel
(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "S-TAB") #'tempel-previous)
  (define-key tempel-map [backtab] #'tempel-previous))

(require 'nerd-icons-corfu)
(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

;; ==================================================================
;; --- 3. TEMPEL (Snippets Manuales) ---
;; ==================================================================
(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "TAB") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "<tab>") #'my/ide-tab-handler)
  (define-key tempel-map (kbd "S-TAB") #'tempel-previous)
  (define-key tempel-map [backtab] #'tempel-previous))

;; ==================================================================
;; --- 4. INTEGRACIÓN PURA DE CORFU CON EGLOT Y TEMPEL ---
;; ==================================================================
(require 'cape)

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
  "Alinea los motores de autocompletado fusionados (Híbrido)."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    ;; NUEVO: Evita que Corfu colapse al teclear la barra '/' en rutas
    (setq-local corfu-quit-at-boundary nil)
    
    (setq-local completion-at-point-functions
                (list
                 ;; Fusión 0: Autocompletado robusto y recursivo de rutas en LaTeX
                 #'my/latex-path-capf
                 ;; Fusión 1: Snippets y Comandos LSP
                 (cape-capf-super #'tempel-complete #'eglot-completion-at-point)
                 ;; Fusión 2: Rutas de archivos (Respaldo)
                 #'cape-file
                 ;; Fusión 3: Palabras previas del documento
                 #'cape-dabbrev))))


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
    "OO" "\\symcal{O}"
    "AA" "\\symcal{A}"
    "MM" "\\symfrak{m}"
    "PP" "\\symfrak{p}"
    "QQ" "\\symfrak{q}"
    
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
            
            ;; 2. Asignar en el modo Inserción de Evil (Crucial)
            (when (bound-and-true-p evil-mode)
              (evil-local-set-key 'insert (kbd "TAB") #'my/ide-tab-handler)
              (evil-local-set-key 'insert (kbd "<tab>") #'my/ide-tab-handler))))

(provide 'my-latex-expansions)
;;; my-latex-expansions.el ends here
