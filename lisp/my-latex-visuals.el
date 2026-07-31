;;; my-latex-visuals.el --- Zen mode y previsualización -*- lexical-binding: t; coding: utf-8; -*-

(declare-function TeX-add-symbols "tex" (&rest entries))
(declare-function TeX-fold-region "tex-fold" (start end &optional type))
(declare-function TeX-fold-clearout-region "tex-fold" (start end))
(declare-function TeX-fold-mode "tex-fold" (&optional arg))
(declare-function TeX-fold-buffer "tex-fold" ())
(declare-function TeX-fold-clearout-buffer "tex-fold" ())
(declare-function TeX-fold-clearout-item "tex-fold" (item))
(declare-function rainbow-delimiters-mode "rainbow-delimiters" (&optional arg))
(declare-function evil-tex-mode "evil-tex" (&optional arg))

;; ==================================================================
;; --- 1. LÓGICA DE COLORES Y EXTRACCIÓN DE TÍTULOS ---
;; ==================================================================

(defconst my/latex-list-face '(:foreground "#98be65" :weight bold))

(defun my/latex-get-env-face (env)
  "Asigna colores pastel semánticos a los pliegues matemáticos y de apuntes-scr."
  (let ((env-name (downcase env)))
    (cond 
     ;; 1. TEOREMAS Y RESULTADOS (Azul/Celeste Pastel - El núcleo de la matemática)
     ((string-match-p "theorem\\|corollary\\|lemma\\|proposition\\|afirmacion\\|claim" env-name) 
      '(:foreground "#82aaff" :weight bold))
     
     ;; 2. DEFINICIONES Y CONCEPTOS (Dorado/Ámbar - Cálido pero no cegador)
     ((string-match-p "definition\\|notation\\|objective\\|objetive\\|notabox\\|controlbox" env-name) 
      '(:foreground "#e5c07b" :weight bold))
     
     ;; 3. ADVERTENCIAS Y ERRORES (Rojo/Salmón Pastel - Llama la atención rápido)
     ((string-match-p "warning\\|attention\\|nota\\|warningbox\\|counterexample" env-name) 
      '(:foreground "#ff5370" :weight bold))

     ;; 4. DEMOSTRACIONES Y SOLUCIONES (Gris Claro Itálico - Texto de soporte)
     ((string-match-p "proof\\|solution\\|remark\\|commentary\\|pruebaafirmacion" env-name) 
      '(:foreground "#a6accd" :slant italic :weight bold))
     
     ;; 5. ECUACIONES Y ESTRUCTURAS (Cyan suave)
     ((string-match-p "matrix\\|equation\\|align\\|conditions\\|caso\\|condicion" env-name) 
      '(:foreground "#89ddff" :slant italic))
     
     ;; 6. LISTAS (Verde Pastel muy suave, para que no distraiga)
     ((string-match-p "enumerate\\|itemize\\|description\\|enuthm" env-name) 
      '(:foreground "#c3e88d" :weight bold))

     ;; 7. BLOQUES DE CÓDIGO Y PYTHON (Esmeralda/Teal vibrante)
     ((string-match-p "pseudocodigo\\|pythonlib\\|pythonexec\\|pythoncode\\|verbatim\\|minted" env-name) 
      '(:foreground "#50c878" :weight bold))
     
     ;; Color por defecto (Gris neutral)
     (t '(:foreground "#676e95" :weight bold)))))

(defun my/merge-face (text new-face)
  (let ((str (copy-sequence (or text ""))))
    (add-face-text-property 0 (length str) new-face t str)
    str))

(require 'subr-x) ; Asegura que string-trim funcione

(defun my/latex-get-env-title (env)
  "Extrae parámetros del entorno para mostrarlos en el Zen Mode."
  (save-excursion
    (condition-case nil
        (when (search-forward "}" (line-end-position) t)
          (skip-chars-forward " \t\n")
          (cond
           ;; CASO 1: Entornos de optidef (mini, maxi, mini*, maxi*, minie)
           ((string-match-p "mini\\|maxi" env)
            ;; 1. Ignorar opciones iniciales como |s| o [2] o <b>
            (while (looking-at "\\(?:|[^|]+|\\|\\[[^]]+\\]\\|<[^>]+>\\)")
              (forward-sexp)
              (skip-chars-forward " \t\n"))
            
            ;; 2. Extraer los 4 bloques obligatorios
            (let (var func result)
              (when (looking-at "{")
                ;; Bloque 1: Variable
                (let ((s (1+ (point)))) (forward-sexp) (setq var (string-trim (buffer-substring-no-properties s (1- (point))))))
                (skip-chars-forward " \t\n")
                
                (when (looking-at "{")
                  ;; Bloque 2: Función
                  (let ((s (1+ (point)))) (forward-sexp) (setq func (string-trim (buffer-substring-no-properties s (1- (point))))))
                  (skip-chars-forward " \t\n")
                  
                  (when (looking-at "{")
                    ;; Bloque 3: Etiqueta (Ignorar)
                    (forward-sexp)
                    (skip-chars-forward " \t\n")
                    
                    (when (looking-at "{")
                      ;; Bloque 4: Result (Donde va la P o D)
                      (let ((s (1+ (point)))) (forward-sexp) (setq result (string-trim (buffer-substring-no-properties s (1- (point))))))))))
              
              ;; 3. Formatear la cadena de salida (Asegurándonos de no devolver nil si faltan datos)
              (let* ((r-str (if (and result (not (string-empty-p result))) (concat result " | ") ""))
                     (v-str (if (and var (not (string-empty-p var))) (concat var " : ") ""))
                     (f-str (if (and func (not (string-empty-p func))) func "f(x)")))
                (format "%s%s%s" r-str v-str f-str))))

           ;; CASO 2: Entornos con argumento obligatorio en llaves {título} (ej. caso, condicion, pseudocodigo)
           ((string-match-p "caso\\|condicion\\|pseudocodigo\\|pythonlib" env)
            (when (looking-at "{")
              (let ((s (1+ (point))))
                (forward-sexp)
                (string-trim (buffer-substring-no-properties s (1- (point)))))))

           ;; CASO 3: Entornos normales con [opciones] o [título] (como enumerate o theorem)
           ((looking-at "\\[")
            (let ((s (1+ (point))))
              (forward-sexp)
              (string-trim (buffer-substring-no-properties s (1- (point))))))))
      ;; Si algo falla al buscar las llaves, devuelve vacío silenciosamente
      (error nil))))

;; ==================================================================
;; --- 2. FORMATEADORES DE PLEGADO (TEX-FOLD) ---
;; ==================================================================

(defun my/fold-todo-format (text &rest _args)
  "Dibuja un bloque naranja/rojo con texto blanco para los TODO."
  (my/merge-face (format " 🛑 TODO: %s " text) '(:background "#ff6c6b" :foreground "#ffffff" :weight bold)))

(defun my/fold-fixme-format (text &rest _args)
  "Dibuja un bloque rojo intenso para FIXME."
  (my/merge-face (format " 🛠️ FIXME: %s " text) '(:background "#ff0000" :foreground "#ffffff" :weight bold)))

(defun my/fold-debug-format (text &rest _args)
  "Dibuja un bloque violeta para DEBUG."
  (my/merge-face (format " 🐞 DEBUG: %s " text) '(:background "#a020f0" :foreground "#ffffff" :weight bold)))

(defun my/fold-note-format (text &rest _args)
  "Dibuja un bloque cyan para NOTE."
  (my/merge-face (format " ℹ️ NOTE: %s " text) '(:background "#0088bb" :foreground "#ffffff" :weight bold)))

(defun my/fold-deftech-format (text &rest _args)
  "Resalta términos técnicos definidos (\\deftech) en rosa pastel."
  (my/merge-face text '(:foreground "#ff80df" :weight bold :underline t)))

(defun my/fold-usual-format (text &rest _args)
  "Resalta énfasis usual (\\usual) en amarillo dorado."
  (my/merge-face text '(:foreground "#ffcb6b" :weight bold)))

(defun my/fold-highlightgreen-format (text &rest _args)
  "Resalta en verde bosque pastel (\\highlightgreen)."
  (my/merge-face text '(:foreground "#98be65" :weight bold)))
  
(defvar my/latex-macros-word nil "Caché de regex para palabras.")
(defvar my/latex-macros-sym nil "Caché de regex para símbolos.")

;; ==================================================================
;; --- TRADUCTOR UNICODE PARA SUB/SUPERÍNDICES EN TEX-FOLD ---
;; ==================================================================
(defconst my/unicode-superscripts
  '(("0" . "⁰") ("1" . "¹") ("2" . "²") ("3" . "³") ("4" . "⁴")
    ("5" . "⁵") ("6" . "⁶") ("7" . "⁷") ("8" . "⁸") ("9" . "⁹")
    ("+" . "⁺") ("-" . "⁻") ("=" . "⁼") ("(" . "⁽") (")" . "⁾")
    ("a" . "ᵃ") ("b" . "ᵇ") ("c" . "ᶜ") ("d" . "ᵈ") ("e" . "ᵉ")
    ("f" . "ᶠ") ("g" . "ᵍ") ("h" . "ʰ") ("i" . "ⁱ") ("j" . "ʲ")
    ("k" . "ᵏ") ("l" . "ˡ") ("m" . "ᵐ") ("n" . "ⁿ") ("o" . "ᵒ")
    ("p" . "ᵖ") ("r" . "ʳ") ("s" . "ˢ") ("t" . "ᵗ") ("u" . "ᵘ")
    ("v" . "ᵛ") ("w" . "ʷ") ("x" . "ˣ") ("y" . "ʸ") ("z" . "ᶻ")
    ("T" . "ᵀ") ("*" . "⃰" )))

(defconst my/unicode-subscripts
  '(("0" . "₀") ("1" . "₁") ("2" . "₂") ("3" . "₃") ("4" . "₄")
    ("5" . "₅") ("6" . "₆") ("7" . "₇") ("8" . "₈") ("9" . "₉")
    ("+" . "₊") ("-" . "₋") ("=" . "₌") ("(" . "₍") (")" . "₎")
    ("a" . "ₐ") ("e" . "ₑ") ("h" . "ₕ") ("i" . "ᵢ") ("j" . "ⱼ")
    ("k" . "ₖ") ("l" . "ₗ") ("m" . "ₘ") ("n" . "ₙ") ("o" . "ₒ")
    ("p" . "ₚ") ("r" . "ᵣ") ("s" . "ₛ") ("t" . "ₜ") ("u" . "ᵤ")
    ("v" . "ᵥ") ("x" . "ₓ")))

(defun my/translate-to-scripts (text type)
  "Convierte TEXTO normal a caracteres Unicode de sub/superíndice.
Usa `mapconcat` (implementado en C) en lugar de `concat` en bucle para evitar
generar basura innecesaria que dispare el Garbage Collector en archivos grandes."
  (save-match-data
    (let ((map (if (eq type 'super) my/unicode-superscripts my/unicode-subscripts)))
      (mapconcat (lambda (c)
                   (let* ((char (char-to-string c))
                          (match (assoc char map)))
                     (if match (cdr match) char)))
                 text ""))))

(defun my/latex-clean-folded-text (text)
  "Traduce macros a símbolos Unicode (Blindado contra crasheos)."
  (if (not (stringp text))
      ""
    (unless my/latex-macros-word
      (let (words syms)
        (dolist (pair my/latex-prettify-symbols-alist)
          (if (string-match-p "[A-Za-z]$" (car pair))
              (push (car pair) words)
            (push (car pair) syms)))
        (setq my/latex-macros-word (concat "\\(" (regexp-opt words) "\\)\\b")
              my/latex-macros-sym  (regexp-opt syms))))
    
    (let ((str (substring-no-properties text)))
      (setq str (replace-regexp-in-string "\\\\[][()]" "" str))
      
      ;; Pasada 1 (Palabras)
      (setq str (replace-regexp-in-string 
                 my/latex-macros-word
                 (lambda (m) 
                   (let ((match (assoc m my/latex-prettify-symbols-alist)))
                     (if match (char-to-string (cdr match)) m))) 
                 str t t))
                 
      ;; Pasada 2 (Símbolos)
      (setq str (replace-regexp-in-string 
                 my/latex-macros-sym
                 (lambda (m) 
                   (let ((match (assoc m my/latex-prettify-symbols-alist)))
                     (if match (char-to-string (cdr match)) m))) 
                 str t t))
                 
      ;; --- MAGIA UNICODE: Superíndices y Subíndices Reales ---
      ;; Procesa superíndices (ej. ^{k} o ^k)
      (while (string-match "\\^\\({\\([^}]+\\)}\\|\\([^{ \t\n]\\)\\)" str)
        (let* ((content (or (match-string 2 str) (match-string 3 str)))
               (translated (my/translate-to-scripts content 'super)))
          (setq str (replace-match translated t t str))))
          
      ;; Procesa subíndices (ej. _{i+1} o _2)
      (while (string-match "_\\({\\([^}]+\\)}\\|\\([^{ \t\n]\\)\\)" str)
        (let* ((content (or (match-string 2 str) (match-string 3 str)))
               (translated (my/translate-to-scripts content 'sub)))
          (setq str (replace-match translated t t str))))
                 
      ;; Limpieza final de espacios y comandos
      (setq str (replace-regexp-in-string "\\\\[ ,;]\\|  +" " " str))
      (string-trim str))))

;; --- Formateadores Base ---
(defun my/latex-fold-begin-format (env &rest _args)
  "Crea la barra visual extrayendo el título y aplicando el color del entorno."
  (let* ((env-str (capitalize (or env "env")))
         (face (my/latex-get-env-face env))
         (title (my/latex-get-env-title env))
         (base-str (my/merge-face (format "--- %s" env-str) face)))
    ;; Solo imprime los corchetes si el título existe y NO está vacío
    (if (and title (not (string-empty-p (string-trim title))))
        (concat base-str (my/merge-face (format " [%s] ---" (my/latex-clean-folded-text title)) face))
      (concat base-str (my/merge-face " ---" face)))))

(defun my/latex-fold-end-format (env &rest _args)
  (my/merge-face (format "--- Fin de %s ---" (capitalize (or env "env")))
                 (my/latex-get-env-face env)))

(defun my/fold-item-format (&rest _args) (my/merge-face "➣" my/latex-list-face))
(defun my/fold-textbf-format (text &rest _args) 
  (my/merge-face text '(:foreground "#ffffff" :weight bold)))
(defun my/fold-textit-format (text &rest _args) (my/merge-face text '(:slant italic)))
(defun my/fold-textcolor-red-format (c text &rest _args)
  (if (string= c "red")
      (my/merge-face text '(:foreground "#ff6c6b" :weight bold))
    (my/merge-face (format "{%s}" text) '(:foreground "#aaaaaa"))))

;; --- Formateadores Matemáticos Zen ---
(defun my/fold-norm-format (text &rest _)
  (my/merge-face (format "‖ %s ‖" (my/latex-clean-folded-text text)) 'font-latex-math-face))

(defun my/fold-abs-format (text &rest _)
  (my/merge-face (format "| %s |" (my/latex-clean-folded-text text)) 'font-latex-math-face))

(defun my/fold-interno-format (t1 t2 &rest _)
  (my/merge-face (format "〈 %s , %s 〉" 
                         (my/latex-clean-folded-text t1) 
                         (my/latex-clean-folded-text t2)) 
                 'font-latex-math-face))

;; Base para los acentos
(defun my/fold-math-accent-format (accent text)
  (my/merge-face (format "%s%s" accent (my/latex-clean-folded-text text)) 'font-latex-math-face))

;; Funciones con nombre para que AUCTeX no se confunda
(defun my/fold-overline-format (t1 &rest _) (my/fold-math-accent-format "‾‾" t1))
(defun my/fold-hat-format (t1 &rest _)      (my/fold-math-accent-format "ˆ" t1))
(defun my/fold-tilde-format (t1 &rest _)    (my/fold-math-accent-format "˜" t1))
(defun my/fold-bar-format (t1 &rest _)      (my/fold-math-accent-format "‾" t1))
(defun my/fold-check-format (t1 &rest _)    (my/fold-math-accent-format "ˇ" t1))

;; Formateadores para \operatorname e \index
(defun my/fold-operatorname-format (text &rest _)
  "Formatea operadores (\\operatorname) como nombres en Modo Zen."
  (my/merge-face (my/latex-clean-folded-text text) '(:foreground "#89ddff" :weight normal :slant normal)))

(defun my/fold-index-format (text &rest _)
  "Formatea marcas de índice (\\index) en un indicador discreto."
  (let ((clean (my/latex-clean-folded-text text)))
    ;; Limpia delimitadores inline matemáticos (\( y \)) para máxima claridad visual
    (setq clean (replace-regexp-in-string "\\\\([ \t]*\\|[ \t]*\\\\)" "" clean))
    (my/merge-face (format "[📑 %s]" clean) '(:foreground "#c792ea" :slant italic :weight light))))

;; --- CARAS (FACES) NOMBRADAS PARA TÍTULOS PLEGADOS (Forzan el tamaño en Emacs) ---
(defface my-fold-part-face
  '((t :foreground "#d3869b" :weight bold :height 1.6))
  "Cara para partes plegadas (Muy grande).")

(defface my-fold-chapter-face
  '((t :foreground "#d3869b" :weight bold :height 1.5))
  "Cara para capítulos plegados (Grande).")

(defface my-fold-section-face
  '((t :foreground "#82aaff" :weight bold :height 1.3))
  "Cara para secciones plegadas (Mediano).")

(defface my-fold-subsection-face
  '((t :foreground "#82aaff" :weight bold :slant italic :height 1.15))
  "Cara para subsecciones plegadas (Ligeramente más grande).")

;; --- Formateadores de Secciones ACTUALIZADOS ---
(defun my/fold-part-format (text &rest _args) 
  (my/merge-face (format "❖ %s" (my/latex-clean-folded-text text)) 'my-fold-part-face))
  
(defun my/fold-chapter-format (text &rest _args) 
  (my/merge-face (format "¶ %s" (my/latex-clean-folded-text text)) 'my-fold-chapter-face))
  
(defun my/fold-section-format (text &rest _args) 
  (my/merge-face (format "§ %s" (my/latex-clean-folded-text text)) 'my-fold-section-face))
  
(defun my/fold-subsection-format (text &rest _args) 
  (my/merge-face (format "§§ %s" (my/latex-clean-folded-text text)) 'my-fold-subsection-face))
  
(defun my/fold-subsubsection-format (text &rest _args) 
  (my/merge-face (format "§§§ %s" (my/latex-clean-folded-text text)) '(:foreground "#82aaff")))

(defun my/fold-map-format (&rest _args)
  "Crea un pliegue para \\map (Versión 6 parámetros).
  Centra dominio/variable y codominio/expresión en sus respectivas columnas."
  (save-excursion
    (unless (looking-at "\\\\map\\b")
      (re-search-backward "\\\\map\\b" (max (point-min) (- (point) 50)) t))
    
    (if (looking-at "\\\\map\\b")
        (progn
          (goto-char (match-end 0)) 
          
          (let ((extracted-args nil))
            (condition-case nil
                (dotimes (_ 6)
                  (skip-chars-forward " \t\n")
                  (while (looking-at "\\[")
                    (forward-sexp)
                    (skip-chars-forward " \t\n"))
                  (when (looking-at "{")
                    (let ((start (point)))
                      (forward-sexp)
                      (push (buffer-substring-no-properties (1+ start) (1- (point))) extracted-args))))
              (error nil))
            
            (setq extracted-args (nreverse extracted-args))
            
            (let* ((n (my/latex-clean-folded-text (or (nth 0 extracted-args) "")))
                   (d (my/latex-clean-folded-text (or (nth 1 extracted-args) "")))
                   (c (my/latex-clean-folded-text (or (nth 2 extracted-args) "")))
                   (v (my/latex-clean-folded-text (or (nth 3 extracted-args) "")))
                   (e (my/latex-clean-folded-text (or (nth 4 extracted-args) "")))
                   (x (my/latex-clean-folded-text (or (nth 5 extracted-args) "")))

                   (e-full (string-trim (concat e " " x))))

              (if (string-empty-p v)
                  ;; Solo 1 línea
                  (my/merge-face (format "%s: %s → %s" n d c) 'font-latex-math-face)
                
                ;; 2 líneas con CENTRADO EXACTO
                (let* ((w-n (string-width n))
                       (w-d (string-width d))
                       (w-c (string-width c))
                       (w-v (string-width v))
                       (w-e (string-width e-full))

                       (source-col (save-excursion 
                                     (re-search-backward "\\\\map\\b") 
                                     (current-column)))
                       
                       (indent-size (max 0 (+ source-col w-n 2)))
                       (indent-spaces (make-string indent-size ?\s))

                       ;; --- COLUMNA 1: Dominio vs Variable ---
                       (max-w1 (max w-d w-v))
                       (diff-d (max 0 (- max-w1 w-d)))
                       (pad-l-d (make-string (/ diff-d 2) ?\s))            ; Espacios Izquierda
                       (pad-r-d (make-string (- diff-d (/ diff-d 2)) ?\s)) ; Espacios Derecha

                       (diff-v (max 0 (- max-w1 w-v)))
                       (pad-l-v (make-string (/ diff-v 2) ?\s))
                       (pad-r-v (make-string (- diff-v (/ diff-v 2)) ?\s))

                       ;; --- COLUMNA 2: Codominio vs Expresión ---
                       (max-w2 (max w-c w-e))
                       (diff-c (max 0 (- max-w2 w-c)))
                       (pad-l-c (make-string (/ diff-c 2) ?\s)) ; Solo Izquierda (Derecha no importa al final de la línea)

                       (diff-e (max 0 (- max-w2 w-e)))
                       (pad-l-e (make-string (/ diff-e 2) ?\s)))

                  (my/merge-face
                   ;; Formato con los espacios centradores añadidos
                   (format "%s: %s%s%s → %s%s\n%s%s%s%s ↦ %s%s"
                           n pad-l-d d pad-r-d pad-l-c c
                           indent-spaces pad-l-v v pad-r-v pad-l-e e-full)
                   'font-latex-math-face))))))
      
      "[Error: No se pudo analizar \\map]")))

;; ==================================================================
;; --- 3. CONFIGURACIÓN DE COLORES DE SECCIONES ---
;; ==================================================================

(with-eval-after-load 'font-latex
  ;; Definimos el color UNIFICADO para toda la estructura
  (let ((unified-color "#d3869b") 
        (unified-height 1.1)
        (unified-weight 'bold))
    (dolist (face '(font-latex-sectioning-1-face 
                    font-latex-sectioning-2-face 
                    font-latex-sectioning-3-face 
                    font-latex-sectioning-4-face 
                    font-latex-sectioning-5-face)) 
      (set-face-attribute face nil 
                          :foreground unified-color 
                          :weight unified-weight 
                          :height unified-height)))

  ;; --- FUENTE EXCLUSIVA PARA MATEMÁTICAS ---
   (set-face-attribute 'font-latex-math-face nil 
                      :family "STIX Two Math"
                      :weight 'normal)
                      
  (set-face-attribute 'font-latex-script-char-face nil 
                      :family "STIX Two Math"
                      :weight 'normal))

;; Quitar el morado de los símbolos y letras griegas (\varphi, \alpha, etc.)
(with-eval-after-load 'tex-fold
  ;; Quitar el morado del texto por defecto de los pliegues
  (set-face-attribute 'TeX-fold-folded-face nil 
                      :foreground "#a6accd" 
                      :weight 'normal))

;; ==================================================================
;; --- 4. LISTA MAESTRA DE SÍMBOLOS (COMPLETA) ---
;; ==================================================================

(defconst my/latex-prettify-symbols-alist
  '(
;; Añadir a tu bloque de "Relaciones y Flechas" o "Puntuación":
    ("\\left." . ?\s)       ;; Oculta el \left. convirtiéndolo en un espacio invisible
    ("\\right|" . ?|)       ;; Convierte el molesto \right| en una simple barra vertical
    ("\\qquad" . ?\u2003)   ;; Convierte \qquad en un "Em Space" (Un espacio visual ancho real)
    ;; Estructura y Listas
    ("\\item" . ?•) ("\\qed" . ?∎) ("\\blacksquare" . ?∎)
    ("\\square" . ?□) ("\\S" . ?§) ("\\P" . ?¶)

    ;; Puntuación y Básicos
    ("\\ldots" . ?…) ("\\dots" . ?…) ("\\cdots" . ?⋯)
    ("\\," . ?_ ) ("\\quad" . ?⎵) ("\\prime" . ?′)

    ;; Lógica y Conjuntos
    ("\\not=" . ?≠) ("\\neq" . ?≠) ("\\in" . ?∈) ("\\notin" . ?∉)
    ("\\ni" . ?∋) ("\\subset" . ?⊂) ("\\subseteq" . ?⊆)
    ("\\sqsubseteq" . ?⊑) ("\\sqsupseteq" . ?⊒) ("\\cup" . ?∪)
    ("\\cap" . ?∩) ("\\forall" . ?∀) ("\\exists" . ?∃)
    ("\\nexists" . ?∄) ("\\land" . ?∧) ("\\wedge" . ?∧)
    ("\\lor" . ?∨) ("\\vee" . ?∨) ("\\neg" . ?¬)
    ("\\emptyset" . ?∅) ("\\setminus" . ?∖) ("\\uplus" . ?⊎)
    ("\\subsetneq" . ?⊊) ("\\supsetneq" . ?⊋) ("\\nsubseteq" . ?⊈)
    ("\\nsupseteq" . ?⊉) ("\\vdash" . ?⊢) ("\\dashv" . ?⊣)
    ("\\models" . ?⊨) ("\\Vdash" . ?⊩) ("\\nvdash" . ?⊬) ("\\nvDash" . ?⊭)

    ;; Operadores Grandes
    ("\\bigwedge" . ?⋀) ("\\bigvee" . ?⋁) ("\\bigcap" . ?⋂)
    ("\\bigcup" . ?⋃) ("\\sum" . ?∑) ("\\prod" . ?∏)
    ("\\coprod" . ?∐) ("\\amalg" . ?∐)

    ;; Operaciones Binarias
    ("\\circ" . ?∘) ("\\bullet" . ?∙) ("\\bigbullet" . ?●)
    ("\\otimes" . ?⊗) ("\\oplus" . ?⊕) ("\\boxplus" . ?⊞)
    ("\\boxminus" . ?⊟) ("\\boxtimes" . ?⊠) ("\\boxdot" . ?⊡)
    ("\\times" . ?×) ("\\cdot" . ?⋅) ("\\star" . ?⋆)
    ("\\ast" . ?∗) ("\\pm" . ?±) ("\\mp" . ?∓) ("\\Join" . ?⋈)

    ;; Relaciones y Flechas
    ("\\leq" . ?≤) ("\\le" . ?≤) ("\\geq" . ?≥) ("\\ge" . ?≥)
    ("\\equiv" . ?≡) ("\\sim" . ?∼) ("\\approx" . ?≈) ("\\cong" . ?≅)
    ("\\simeq" . ?≃) ("\\propto" . ?∝) ("\\Rightarrow" . ?⇒)
    ("\\Longrightarrow" . ?⟹) ("\\Longleftarrow" . ?⟸)
    ("\\Longleftrightarrow" . ?⟺) ("\\longrightarrow" . ?⟶)
    ("\\rightarrow" . ?→) ("\\to" . ?→) ("\\leftarrow" . ?←)
    ("\\gets" . ?←) ("\\mapsto" . ?↦) ("\\implies" . ?⟹)
    ("\\iff" . ?⟺) ("\\hookrightarrow" . ?↪) ("\\twoheadrightarrow" . ?↠)
    ("\\rightrightarrows" . ?⇉) ("\\leftleftarrows" . ?⇇)
    ("\\rightleftarrows" . ?⇄) ("\\leftrightarrows" . ?⇆)
    ("\\leftrightarrow" . ?↔) ("\\longleftrightarrow" . ?⟷)
    ("\\rightarrowtail" . ?↣) ("\\longmapsto" . ?⟼)
    ("\\leadsto" . ?⇝) ("\\nrightarrow" . ?↛) ("\\nRightarrow" . ?⇏)
    ("\\uparrow" . ?↑) ("\\downarrow" . ?↓) ("\\updownarrow" . ?↕)

    ;; Cálculo y Análisis
    ("\\infty" . ?∞) ("\\partial" . ?∂) ("\\nabla" . ?∇)
    ("\\int" . ?∫) ("\\oint" . ?∮) ("\\sqrt" . ?√)

    ;; Geometría y Álgebra Lineal
    ("\\perp" . ?⟂) ("\\parallel" . ?∥) ("\\angle" . ?∠)
    ("\\measuredangle" . ?∡) ("\\triangle" . ?△) ("\\Box" . ?□)
    ("\\diamond" . ?◇) ("\\dagger" . ?†) ("\\top" . ?⊤) ("\\bot" . ?⊥)

    ;; Letras Especiales
    ("\\Id" . ?𝟙) ("\\Re" . ?ℜ) ("\\Im" . ?ℑ)
    ("\\hbar" . ?ℏ) ("\\ell" . ?ℓ) ("\\wp" . ?℘)
    ("\\aleph" . ?ℵ) ("\\beth" . ?ℶ) ("\\gimel" . ?ℷ)
    
    ;; Doble Trazo (Escapado con notación hexadecimal segura ?\Uxxxxxxxx)
    ("\\I" . ?\U0001D540) ("\\A" . ?\U0001D49C) ("\\Cls" . ?\U0001D49E)
    ("\\R" . ?\U0000211D) ("\\C" . ?\U00002102) ("\\Z" . ?\U00002124) ("\\N" . ?\U00002115) ("\\Q" . ?\U0000211A)
    ("\\symbb{A}" . ?\U0001D538)
    ("\\symbb{C}" . ?\U00002102)
    ("\\symbb{D}" . ?\U0001D53B)
    ("\\symbb{E}" . ?\U0001D53C) ;; Esperanza Matemática
    ("\\symbb{F}" . ?\U0001D53D) ;; Campo (Field)
    ("\\symbb{G}" . ?\U0001D53E)
    ("\\symbb{H}" . ?\U0000210D)
    ("\\symbb{I}" . ?\U0001D540)
    ("\\symbb{K}" . ?\U0001D542) ;; Cuerpo / Campo K
    ("\\symbb{N}" . ?\U00002115)
    ("\\symbb{P}" . ?\U00002119) ;; Probabilidad
    ("\\symbb{Q}" . ?\U0000211A)
    ("\\symbb{R}" . ?\U0000211D)
    ("\\symbb{S}" . ?\U0001D54A)
    ("\\symbb{T}" . ?\U0001D54B)
    ("\\symbb{V}" . ?\U0001D550) ;; Varianza
    ("\\symbb{Z}" . ?\U00002124)

  ;; Caligráficas (Corregidas 100% al estándar Unicode)
    ("\\symcal{A}" . ?\U0001D49C) ("\\symcal{B}" . ?\U0000212C) ("\\symcal{C}" . ?\U0001D49E)
    ("\\symcal{D}" . ?\U0001D49F) ("\\symcal{E}" . ?\U00002130) ("\\symcal{F}" . ?\U00002131)
    ("\\symcal{G}" . ?\U0001D4A2) ("\\symcal{H}" . ?\U0000210B) ("\\symcal{I}" . ?\U00002110)
    ("\\symcal{J}" . ?\U0001D4A5) ("\\symcal{K}" . ?\U0001D4A6) ("\\symcal{L}" . ?\U00002112)
    ("\\symcal{M}" . ?\U00002133) ("\\symcal{N}" . ?\U0001D4A9) ("\\symcal{O}" . ?\U0001D4AA)
    ("\\symcal{P}" . ?\U0001D4AB) ("\\symcal{Q}" . ?\U0001D4AC) ("\\symcal{R}" . ?\U0000211B)
    ("\\symcal{S}" . ?\U0001D4AE) ("\\symcal{T}" . ?\U0001D4AF) ("\\symcal{U}" . ?\U0001D4B0)
    ("\\symcal{V}" . ?\U0001D4B1) ("\\symcal{W}" . ?\U0001D4B2) ("\\symcal{X}" . ?\U0001D4B3)
    ("\\symcal{Y}" . ?\U0001D4B4) ("\\symcal{Z}" . ?\U0001D4B5)
   
    ;; Griegas
    ("\\alpha" . ?α) ("\\beta" . ?β) ("\\gamma" . ?γ) ("\\delta" . ?δ)
    ("\\epsilon" . ?ϵ) ("\\varepsilon" . ?ε) ("\\zeta" . ?ζ) ("\\eta" . ?η)
    ("\\theta" . ?θ) ("\\vartheta" . ?ϑ) ("\\iota" . ?ι) ("\\kappa" . ?κ)
    ("\\lambda" . ?λ) ("\\mu" . ?μ) ("\\nu" . ?ν) ("\\xi" . ?ξ)
    ("\\pi" . ?π) ("\\rho" . ?ρ) ("\\sigma" . ?σ) ("\\tau" . ?τ)
    ("\\upsilon" . ?υ) ("\\phi" . ?φ) ("\\varphi" . ?φ) ("\\chi" . ?χ)
    ("\\psi" . ?ψ) ("\\omega" . ?ω)
    ("\\Gamma" . ?Γ) ("\\Delta" . ?Δ) ("\\Theta" . ?Θ) ("\\Lambda" . ?Λ)
    ("\\Xi" . ?Ξ) ("\\Pi" . ?Π) ("\\Sigma" . ?Σ) ("\\Phi" . ?Φ)
    ("\\Psi" . ?Ψ) ("\\Omega" . ?Ω)

    ;; Alfabeto Fraktur (Gothic)
    ("\\symfrak{A}" . ?𝔄) ("\\symfrak{B}" . ?𝔅) ("\\symfrak{C}" . ?ℭ)
    ("\\symfrak{D}" . ?𝔇) ("\\symfrak{E}" . ?𝔈) ("\\symfrak{F}" . ?𝔉)
    ("\\symfrak{G}" . ?𝔊) ("\\symfrak{H}" . ?ℌ) ("\\symfrak{I}" . ?ℑ)
    ("\\symfrak{J}" . ?𝔍) ("\\symfrak{K}" . ?𝔎) ("\\symfrak{L}" . ?𝔏)
    ("\\symfrak{M}" . ?𝔐) ("\\symfrak{N}" . ?𝔑) ("\\symfrak{O}" . ?𝔒)
    ("\\symfrak{P}" . ?𝔓) ("\\symfrak{Q}" . ?𝔔) ("\\symfrak{R}" . ?ℜ)
    ("\\symfrak{S}" . ?𝔖) ("\\symfrak{T}" . ?𝔗) ("\\symfrak{U}" . ?𝔘)
    ("\\symfrak{V}" . ?𝔙) ("\\symfrak{W}" . ?𝔚) ("\\symfrak{X}" . ?𝔛)
    ("\\symfrak{Y}" . ?𝔜) ("\\symfrak{Z}" . ?ℨ)
    ("\\symfrak{a}" . ?𝔞) ("\\symfrak{b}" . ?𝔟) ("\\symfrak{c}" . ?𝔠)
    ("\\symfrak{d}" . ?𝔡) ("\\symfrak{e}" . ?𝔢) ("\\symfrak{f}" . ?𝔣)
    ("\\symfrak{g}" . ?𝔤) ("\\symfrak{h}" . ?𝔥) ("\\symfrak{i}" . ?𝔦)
    ("\\symfrak{j}" . ?𝔧) ("\\symfrak{k}" . ?𝔨) ("\\symfrak{l}" . ?𝔩)
    ("\\symfrak{m}" . ?𝔪) ("\\symfrak{n}" . ?𝔫) ("\\symfrak{o}" . ?𝔬)
    ("\\symfrak{p}" . ?𝔭) ("\\symfrak{q}" . ?𝔮) ("\\symfrak{r}" . ?𝔯)
    ("\\symfrak{s}" . ?𝔰) ("\\symfrak{t}" . ?𝔱) ("\\symfrak{u}" . ?𝔲)
    ("\\symfrak{v}" . ?𝔳) ("\\symfrak{w}" . ?𝔴) ("\\symfrak{x}" . ?𝔵)
    ("\\symfrak{y}" . ?𝔶) ("\\symfrak{z}" . ?𝔷)

    ;; Delimitadores Dinámicos
    ("\\langle" . ?⟨ ) ("\\rangle" . ?⟩ )
    ("\\left\\langle" . ?⟪) ("\\right\\rangle" . ?⟫)
    ("\\lVert" . ?‖ ) ("\\rVert" . ?‖ )
    ("\\left|" . ?│) ("\\right|" . ?│) ("\\big|" . ?│)
    ("\\{" . ?{ ) ("\\}" . ?} )
    ("\\left\\{" . ?❴) ("\\right\\}" . ?❵ )
    ("\\left[" . ?［ ) ("\\right]" . ?］)
    ("\\left(" . ?⦅) ("\\right)" . ?⦆)
	;; Delimitadores de Bloques Matemáticos
    ("\\[" . ?┏)
    ("\\]" . ?┗)

    ;; Definiciones y Exponentes
    ("\\coloneq" . ?\u2254 )
    ("\\colon" . ?: )	
    ("\\therefore" . ?∴ )
    ("\\because" . ?∵ )
    ("^2" . ?² )
    ("^3" . ?³ )
    
    ;; Símbolos y operadores de apuntes-scr.cls
    ("\\diff" . ?\u2146)       ;; ⅆ diferencial
    ("\\E" . ?\u2147)          ;; ℇ exponencial
    ("\\Imath" . ?\u2148)      ;; ⅈ imaginario i
    ("\\syss" . ?\u27FA)       ;; ⟺ si y solo si
    ("\\ent" . ?\u21D2)        ;; ⇒ entonces / implica
    ("\\episum" . ?#)          ;; # suma episum
    ("\\epimult" . ?⋆)         ;; ⋆ mult
    )
"Mapa de símbolos extendido robusto.")

;; ==================================================================
;; --- 5. VISUAL ZEN MODE (INTERRUPTOR) ---
;; ==================================================================

(defvar-local my/latex-fold-timer nil
"Temporizador local para plegar LaTeX en pausas.")

(defun my/latex-fold-visible-region ()
  "Fuerza el coloreado y pliega la porción visible, protegiendo el cursor."
  (when (and (buffer-live-p (current-buffer))
             (derived-mode-p 'LaTeX-mode)
             (bound-and-true-p TeX-fold-mode)
             ;; NO plegar si estamos escribiendo activamente (Evil Insert State)
             (not (bound-and-true-p evil-insert-state-minor-mode)))
    (with-silent-modifications
      (let ((start (max (point-min) (- (window-start) 500)))
            (end   (min (point-max) (+ (window-end) 500)))
            (curr-line-start (line-beginning-position))
            (curr-line-end (line-end-position)))
        (font-lock-ensure start end)
        ;; Plegar todo
        (TeX-fold-region start end)
        ;; Desplegar INMEDIATAMENTE la línea actual para no molestar visualmente
        (TeX-fold-clearout-region curr-line-start curr-line-end)))))

(defun my/latex-trigger-idle-fold (&rest _)
  "Reinicia el temporizador de plegado al escribir."
  (when my/latex-visual-mode
    ;; Solo reprograma el timer si no existe o ya expiró
    (unless (and my/latex-fold-timer (timerp my/latex-fold-timer))
      (setq my/latex-fold-timer
            (run-with-idle-timer 2.0 nil #'my/latex-fold-visible-region)))))

(defun my/latex-visual-setup ()
  "Configuración Zen: Activa plegado y símbolos."
  ;; 1. Le enseñamos a AUCTeX cuántos argumentos tienen tus comandos personalizados
  (TeX-add-symbols 
   '("map" t t t t t t)  ;; \map tiene exactamente 6 argumentos {}{}{}{}{}{}
   '("inmap" t t t)      ;; \inmap tiene exactamente 3 argumentos {}{}{}
   '("mapchain" t t t t t t t) ;; \mapchain con 7 argumentos
   '("chart" t t)
   '("chartcoords" t t)
   '("rest" t t)
   '("transmap" t t)
   '("morf" t t t)
   '("TODO" t) '("FIXME" t) '("DEBUG" t) '("NOTE" t)
   '("deftech" t) '("usual" t) '("highlightgreen" t)
   '("dependencias" t) '("blueprint" t) '("casobase" t))

  ;; 2. Tu lista de reglas de siempre...
  (setq-local TeX-fold-macro-spec-list
				'(
				  (my/fold-part-format ("part"))
        		  (my/fold-chapter-format ("chapter"))
                  (my/fold-section-format ("section"))
                  (my/fold-subsection-format ("subsection" "addsubsec"))
                  (my/fold-subsubsection-format ("subsubsection" "addsubsubsec"))
                  
                  (my/fold-item-format ("item"))
                  (my/fold-todo-format ("TODO"))
                  (my/fold-fixme-format ("FIXME"))
                  (my/fold-debug-format ("DEBUG"))
                  (my/fold-note-format ("NOTE"))
                  
                  (my/fold-deftech-format ("deftech"))
                  (my/fold-usual-format ("usual"))
                  (my/fold-highlightgreen-format ("highlightgreen"))
				  
				  ("{1}" ("text" "textnormal" "mathrm" "mathbf" "symbf"))
                  ("{1} / {2}" ("frac"))
                  ("[🏷️ {1}]" ("label"))
                  ("[🔗 {1}]" ("cref" "ref" "Cref" "eqref"))
                  ("[📚 {1}]" ("cite" "parencite" "textcite" "addbibresource" "fullcite"))
                  
                  ("[ 🔗 Dependencias: {1} ]" ("dependencias"))
                  ("[ 💡 Blueprint: {1} ]" ("blueprint"))
                  ("[ 🌱 Caso Base: ({1}) ]" ("casobase"))
                  (" [ 🌿 Paso Inductivo ] " ("pasoinductivo"))
                  (" [ 🔑 H.I. ] " ("hipotesisind"))
                  (" (Ω, ℱ, ℙ) " ("probabilitySpace"))
                  (" {Xₙ}ₙ≥₁ " ("randomVariableSequence"))
                  (" v.a.r. " ("vareal"))
				  
				  ;; --- NUEVO: PLEGADO GRANULAR PARA FIGURAS ---
				  ("📝 {1}" ("caption"))                        ; Muestra el texto del caption limpio
				  ("[ 🖼️ {1} ]" ("includegraphics"))            ; Muestra el nombre del archivo de imagen
				  ("[ 🖼️ {2} ]" ("import"))                     ; Muestra el archivo importado (el argumento 2)
				  (" ↔️ Centrado " ("centering"))                ; Oculta el comando centering
				  
                  ("Supp" ("Supp"))
                  ("dim" ("dim"))
				  ("det" ("det"))
				  ("ker" ("Ker"))
				  ("im" ("Im"))
				  ("Frac" ("Frac"))
				  
				  ;; --- NUEVOS PLIEGUES PARA FUNCIONES ---
                  ;; Extrae los 3 argumentos de \inmap y los formatea con una flecha
                  ("{1}: {2} → {3}" ("inmap"))
                  ("{1} -({5})-> {2} -({6})-> {3} -({7})-> {4}" ("mapchain"))
                  ("({1}, {2})" ("chart"))
                  ("({1}, ({2}¹, …, {2}ⁿ))" ("chartcoords"))
                  ("{1}|_{2}" ("rest"))
                  ("{2} ∘ {1}⁻¹" ("transmap"))
                  ("𝓒({2}, {3})" ("morf"))
                  ("ℜ({1})" ("re"))
                  ("ℑ({1})" ("im"))
                  ("𝔼[{1}]" ("expectation"))
                  ("Var({1})" ("variance"))
                  ("({1}ₙ)ₙ₌₀^∞" ("serie"))
                  ("ℝⁿ" ("Rn"))
				  
				  ;; Extrae los 6 argumentos de \map y llama al alineador inteligente multilínea
                  (my/fold-map-format ("map"))

				  ;; Modificadores Matemáticos Reales (Renderizado Inteligente)
                  (my/fold-norm-format ("norm"))
                  (my/fold-interno-format ("interno"))
                  (my/fold-abs-format ("abs" "absolute"))
                  (my/fold-overline-format ("overline"))
                  (my/fold-hat-format ("hat"))
                  (my/fold-tilde-format ("tilde"))
                  (my/fold-bar-format ("bar"))
                  (my/fold-check-format ("check"))
                  (my/fold-operatorname-format ("operatorname" "operatorname*"))
                  (my/fold-index-format ("index" "idx"))

                  (my/fold-textbf-format ("textbf" "symbf" "mathbf"))
                  (my/fold-textit-format ("textit" "symit" "mathit"))
                  (my/fold-textcolor-red-format ("textcolor"))
                  (my/latex-fold-begin-format ("begin"))
                  (my/latex-fold-end-format ("end")))) ;; <-- ESTOS DOS PARÉNTESIS SON VITALES
  
  (setq-local TeX-fold-auto-reveal t)
  (setq-local TeX-fold-auto t)
  (TeX-fold-mode 1)

(add-hook 'after-change-functions #'my/latex-trigger-idle-fold nil t)
  
;; Cara personalizada para atenuar solo los delimitadores
(defface my-latex-math-bracket-face
  '((t :foreground "#555555"))
  "Cara discreta para los delimitadores matemáticos.")

;; Inyectar esta regla exclusivamente para los delimitadores
;; Resalta \(, \), \[, \] con la cara atenuada
(font-lock-add-keywords 'LaTeX-mode
  '(("\\\\(\\|\\\\)\\|\\\\\\[\\|\\\\\\]" 0 'my-latex-math-bracket-face prepend)))
  
  (setq prettify-symbols-compose-predicate #'prettify-symbols-default-compose-p)
  (setq-local prettify-symbols-alist my/latex-prettify-symbols-alist)
  (setq-local prettify-symbols-unprettify-at-point t)
  (prettify-symbols-mode 1)
  (rainbow-delimiters-mode 1)
  
  ;; 1. Refrescar colores base
  (font-lock-flush)
  (font-lock-ensure)
  
  ;; 2. Plegar el buffer entero automáticamente con un ligero retraso
  ;;    para asegurar que font-lock terminó de analizar el texto.
  (run-with-timer 0.1 nil (lambda () 
                            (when (and (buffer-live-p (current-buffer))
                                       (derived-mode-p 'LaTeX-mode))
                              (TeX-fold-buffer))))
                              
  (message "✅ Visual Zen Activado: Teoremas y Definiciones en modo orgánico."))

(defun my/latex-visual-teardown ()
  "Revierte la configuración Zen devolviendo el buffer a código crudo."
  (when (bound-and-true-p TeX-fold-mode)
    (TeX-fold-clearout-buffer)
    (TeX-fold-mode -1))
  (remove-hook 'after-change-functions #'my/latex-trigger-idle-fold t)
  (when my/latex-fold-timer (cancel-timer my/latex-fold-timer))
  (prettify-symbols-mode -1)
  (rainbow-delimiters-mode -1)
  (font-lock-flush)
  (font-lock-ensure)
  (message "⛔ Visual Zen Desactivado: Código en crudo."))

(define-minor-mode my/latex-visual-mode
  "Modo menor para alternar la visualización Zen en LaTeX."
  :init-value nil
  :lighter " Zen"
  (if my/latex-visual-mode
      (my/latex-visual-setup)
    (my/latex-visual-teardown)))

;; ==================================================================
;; --- 6. PREVIEW-LATEX (RESOLUCIÓN DE FÓRMULAS IN-BUFFER) ---
;; ==================================================================

(defun my/setup-preview-settings ()
  (setq preview-scale-function 1.02)
  (setq preview-resolution 300)
  (setq preview-image-type 'pnm))
(add-hook 'LaTeX-mode-hook #'my/setup-preview-settings)

;; ==================================================================
;; --- 7. EVIL-TEX Y PLEGADO INICIAL ---
;; ==================================================================

;; FIX: Requerir explícitamente las macros de Evil para que no falle la carga
(require 'evil)

(with-eval-after-load 'evil-tex
  (define-key evil-tex-mode-map (kbd "M") nil)
  (evil-define-key 'normal evil-tex-mode-map
    (kbd "ts") evil-tex-toggle-map
    (kbd "[[") 'evil-tex-goto-section-boundary-back
    (kbd "]]") 'evil-tex-goto-section-boundary-forward)
  (define-key evil-tex-mode-map (kbd "s") nil))
(add-hook 'LaTeX-mode-hook #'evil-tex-mode)

;; Activar el modo visual automáticamente al abrir un archivo LaTeX
(add-hook 'LaTeX-mode-hook #'my/latex-visual-mode)

(defun my/latex-fold-after-snippet ()
  "Actualiza el Zen Mode tras un snippet, sin colapsar el entorno actual."
  (when (derived-mode-p 'LaTeX-mode)
    (my/latex-fold-visible-region)
    (TeX-fold-clearout-item)))

;; Enganchar la función al momento en que Tempel termina de expandirse
(add-hook 'tempel-done-hook #'my/latex-fold-after-snippet)

(provide 'my-latex-visuals)
;;; my-latex-visuals.el ends here
