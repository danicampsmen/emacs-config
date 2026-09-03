;;; laas.el --- Motor Maestro de Micro-Escritura Matemática mid-typing -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020-2021 Yoav Marco, TEC
;; Modificado y Verificado para: apuntes-scr.cls & Tempel (Zero Keymap Conflicts)
;;

(require 'aas)
(require 'texmathp)
(require 'tempel)
(require 'my-editor)

(defgroup laas nil
  "LaTeX snippets that expand mid-typing."
  :prefix "laas-"
  :group 'aas)

;; ==================================================================
;; --- 1. PROTECCIONES Y CONDICIONES GLOBALES DE SEGURIDAD ---
;; ==================================================================

(defun laas--inside-protected-command-p ()
  "Devuelve t si el cursor está dentro del argumento de \\cite, \\ref, \\label, etc."
  (let ((ppss (syntax-ppss)))
    (when (nth 1 ppss)
      (save-excursion
        (goto-char (nth 1 ppss))
        (when (eq (char-after) ?{)
          (when (re-search-backward "\\\\[a-zA-Z*]+" (max (point-min) (- (point) 120)) t)
            (looking-at "\\\\\\(label\\|ref\\|cref\\|Cref\\|sref\\|eref\\|cite\\|textcite\\|parencite\\|eqref\\|input\\|import\\|include\\|includegraphics\\|bibliography\\|addbibresource\\)\\b")))))))

(defun laas--not-in-protected-command-p ()
  "Condición global para evitar disparos accidentales en argumentos protegidos."
  (not (laas--inside-protected-command-p)))

(defun laas--no-backslash-before-point? ()
  "Evita disparar snippets si el carácter anterior al trigger es un backslash."
  (not (eq (char-before) ?\\)))

(defun laas-current-snippet-insert-post-space-if-wanted ()
  "Inserta un espacio tras el snippet si la macro lo requiere."
  (when (and (stringp aas-transient-snippet-expansion)
             (= ?\\ (aref aas-transient-snippet-expansion 0))
             (not (memq (char-after) '(?\) ?\] ?\} ?, ?. ?\; ?: ?\s ?\n))))
    (insert " ")))

(defun laas-mathp ()
  "Determina si el punto está dentro de un entorno matemático."
  (cond
   ((derived-mode-p 'latex-mode 'LaTeX-mode) (texmathp))
   ((derived-mode-p 'org-mode) (laas-org-mathp))
   (t nil)))

(declare-function org-inside-LaTeX-fragment-p "org")
(declare-function org-element-at-point "org-element")
(declare-function org-element-type "org-element")

(defun laas-org-mathp ()
  (or (org-inside-LaTeX-fragment-p)
      (eq (org-element-type (org-element-at-point)) 'latex-environment)))

;; ==================================================================
;; --- 2. SUBÍNDICES Y SUPERÍNDICES INTELIGENTES ---
;; ==================================================================

(defun laas-insert-script (s)
  "Agrega un subíndice con texto S respetando agrupación."
  (interactive (list (this-command-keys)))
  (pcase aas-transient-snippet-condition-result
    ('one-sub
     (insert "_" s))
    ('extended-sub
     (backward-char)
     (insert "{")
     (forward-char)
     (insert s "}"))))

(defun laas-auto-script-condition ()
  "Detecta cuándo una letra/número debe transformarse en subíndice."
  (cond ((or (bobp) (= (1- (point)) (point-min))) nil)
        ((and (or (= (char-before (1- (point))) ?_)
                  (= (char-before (1- (point))) ?^))
              (/= (char-before) ?{))
         (laas-mathp)
         'extended-sub)
        ((and (or (<= ?a (char-before) ?z) (<= ?A (char-before) ?Z))
              (not (or (<= ?a (char-before (1- (point))) ?z)
                       (<= ?A (char-before (1- (point))) ?Z)))
              (laas-mathp))
         'one-sub)))

(defun laas-identify-adjacent-tex-object (&optional point)
  "Retorna la posición de inicio del objeto TeX anterior al cursor."
  (save-excursion
    (goto-char (or point (point)))
    (cond
     ((memq (char-before) '(?\) ?\]))
      (backward-sexp) (point))
     ((= (char-before) ?})
      (cl-loop do (backward-sexp) while (= (char-before) ?}))
      (when (looking-back "\\\\[A-Za-z@*]+" (line-beginning-position))
        (goto-char (match-beginning 0)))
      (when (memq (char-before) '(?_ ?^ ?.))
        (backward-char)
        (goto-char (laas-identify-adjacent-tex-object)))
      (point))
     ((or (<= ?a (char-before) ?z) (<= ?A (char-before) ?Z) (<= ?0 (char-before) ?9))
      (backward-word)
      (when (eq (char-before) ?\\) (backward-char))
      (when (memq (char-before) '(?_ ?^ ?.))
        (backward-char)
        (goto-char (laas-identify-adjacent-tex-object)))
      (point)))))

(defun laas-wrap-previous-object (tex-cmd)
  "Envuelve el objeto anterior en la macro TEX-CMD."
  (interactive)
  (let ((start (laas-identify-adjacent-tex-object))
        left right)
    (when (functionp tex-cmd) (setq tex-cmd (funcall tex-cmd)))
    (cond
     ((stringp tex-cmd)
      (setq left (concat "\\" tex-cmd "{") right "}"))
     ((consp tex-cmd)
      (setq left (car tex-cmd) right (cdr tex-cmd))))
    (when (and left start)
      (insert right)
      (save-excursion
        (goto-char start)
        (insert left)))))

(defun laas-object-on-left-condition ()
  (and (or (<= ?a (char-before) ?z)
           (<= ?A (char-before) ?Z)
           (<= ?0 (char-before) ?9)
           (memq (char-before) '(?\) ?\] ?\})))
       (laas-mathp)))

;; ==================================================================
;; --- 3. FRACCIONES DINÁMICAS (ESTILO GILLES CASTEL) ---
;; ==================================================================

(defun laas-frac-cond ()
  (cond ((and (= (char-before) ?/) (laas-mathp)) 'standalone-frac)
        ((laas-object-on-left-condition) 'wrapping-frac)))

(defun laas-smart-fraction ()
  "Expansión inteligente de fracciones usando Tempel."
  (interactive)
  (pcase aas-transient-snippet-condition-result
    ('standalone-frac
     (delete-char -1)
     (tempel-insert (list "\\frac{" 'p "}{" 'p "}")))
    ('wrapping-frac
     (let* ((tex-obj (laas-identify-adjacent-tex-object))
            (start (save-excursion
                     (if (memq (char-before) '(?\) ?\]))
                         (progn (backward-delete-char 1) (goto-char tex-obj) (delete-char 1))
                       (goto-char tex-obj))
                     (point)))
            (end (point))
            (content (buffer-substring-no-properties start end)))
       (delete-region start end)
       (tempel-insert (list "\\frac{" content "}{" 'p "}"))))))

(defun my/laas-smart-eval ()
  "Envuelve el objeto matemático anterior en \\eval{}{}."
  (interactive)
  (let* ((tex-obj (laas-identify-adjacent-tex-object))
         (start (point))
         (content (buffer-substring-no-properties tex-obj start)))
    (when tex-obj
      (delete-region tex-obj start)
      (tempel-insert (list "\\eval{" content "}{" 'p "}")))))

;; ==================================================================
;; --- 4. POLIMORFISMO Y DIFERENCIALES ---
;; ==================================================================

(defun my/aas-normal-mode-p ()
  "Verifica modo texto precedido de espacio, inicio de línea o puntuación (incluyendo español)."
  (and (not (laas-mathp))
       (or (bobp) 
           (memq (char-before) '(?\s ?\n ?\t ?\{ ?\[ ?\( ?~ ?¿ ?¡ ?« ?» ?\" ?\')))))

(defun laas-differential-cond ()
  "Expande diferenciales solo en matemática y precedido de espacio, operador o delimitador."
  (and (laas-mathp)
       (or (bobp)
           (memq (char-before) '(?\s ?\t ?\n ?\( ?\[ ?\{ ?+ ?- ?* ?/ ?= ?~ ?^ ?_ ?\, ?\;)))))

(defun my/aas-proof-context ()
  "Determina el contexto de demostración en apuntes-scr.cls."
  (let ((current-env (if (fboundp 'LaTeX-current-environment) (LaTeX-current-environment) "document")))
    (cond
     ((member current-env '("proof" "claim" "claim*" "pruebaafirmacion")) 'afirmacion)
     ((member current-env '("exercise" "problem" "question" "exc" "exercices")) 'solucion)
     (t 'demostracion))))

(defun my/aas-expand-proof-polymorphic ()
  "Expande el entorno de prueba correcto según el anidamiento en apuntes-scr.cls."
  (interactive)
  (pcase (my/aas-proof-context)
    ('afirmacion   (tempel-insert '("\\begin{claimproof}" n> p n> "\\end{claimproof}" q)))
    ('solucion     (tempel-insert '("\\begin{solution}" n> p n> "\\end{solution}" q)))
    ('demostracion (tempel-insert '("\\begin{proof}" n> p n> "\\end{proof}" q)))))

(defun my/aas-polymorphic-cond ()
  (cond ((laas-mathp) 'math)
        ((my/aas-normal-mode-p) 'text)
        (t nil)))

(defun my/aas-make-polymorphic (math-template text-template)
  (lambda ()
    (interactive)
    (pcase aas-transient-snippet-condition-result
      ('math (tempel-insert math-template))
      ('text (tempel-insert text-template)))))

(defun laas-latex-accent-cond ()
  (or (derived-mode-p 'latex-mode 'LaTeX-mode)
      (laas-mathp)))

;; ==================================================================
;; --- 5. DICCIONARIOS DE SNIPPETS MAESTROS (VERIFICADOS) ---
;; ==================================================================

(defvar laas-basic-snippets
  '(:cond laas-mathp
    ;; Operadores y Relaciones Instantáneas
    ":=" "\\coloneq"  "!=" "\\ne"      "**" "\\cdot"    "+-" "\\pm"   "-+" "\\mp"
    "->" "\\to"       "-->" "\\longrightarrow"
    "..." "\\dots"    "<<" "\\ll"      "<=" "\\leq"     ">=" "\\geq"  ">>" "\\gg"
    "<>" "\\diamond"  "=<" "\\impliedby" "==" "&="      "=>" "\\implies"
    "AA" "\\forall"   "EE" "\\exists"  "cb" "^3"        "sr" "^2"
    "iff" "\\iff"     "imp" "\\implies"
    "inn" "\\in"      "nin" "\\not\\in" "xx" "\\times"
    "|->" "\\mapsto"  "|=" "\\models"   "||" "\\mid"    "~=" "\\approx" "~~" "\\sim"
    "part" (tempel "\\frac{\\partial " p "}{\\partial " p "}" q)

    ;; Funciones Trigonométricas y Análisis
    "arccos" "\\arccos" "arccot" "\\arccot" "arccsc" "\\arccsc" "arcsec" "\\arcsec"
    "arcsin" "\\arcsin" "arctan" "\\arctan" "cos" "\\cos"       "cot" "\\cot"
    "csc" "\\csc"       "exp" "\\exp"       "ln" "\\ln"         "log" "\\log"
    "sin" "\\sin"       "tan" "\\tan"       "star" "\\star"     "gcd" "\\gcd"
    "min" "\\min"       "max" "\\max"       "eqv" "\\equiv"     "perp" "\\perp"
    "sgn" "\\sgn"       "qd" "\\quad"       "qqd" "\\qquad"

    ;; Conjuntos Numéricos y Espacios
    "CC" "\\C" "FF" "\\F" "HH" "\\H" "NN" "\\N" "PP" "\\P" "QQ" "\\Q" "RR" "\\R" "ZZ" "\\Z"
    "rrn" "\\R^n"
    "ccn" "\\C^n"
    "cinf" (tempel "\\symcal{C}^{\\infty}(" (p "M") ")" q)
    "hom"  (tempel "\\symcal{L}(" (p "V") " ; " (p "W") ")" q)
    "dfp"  (tempel "d F_{" (p "p") "}" q)
    "tpm"  (tempel "T_{" (p "p") "}" (p "M") q)
    "ctp"  (tempel "T^{*}_{" (p "p") "}" (p "M") q)

    ;; Álgebra Abstracta y Flechas
    "ox" "\\otimes"   "ot" "\\otimes"
    "op" "\\oplus"
    "inj" "\\hookrightarrow"
    "surj" "\\twoheadrightarrow"

    ;; Haces, Ideales y Categorías (Bourbaki / EGA)
    "sO" "\\symcal{O}"  "sA" "\\symcal{A}"  "sM" "\\symfrak{m}"
    "sP" "\\symfrak{p}"  "sQ" "\\symfrak{q}"
    "Spec" "\\Spec"     "Hom" "\\Hom"       "Ker" "\\Ker"       "Cok" "\\Coker"
    "Im" "\\Image"      "End" "\\End"       "Aut" "\\Aut"       "Ext" "\\Ext"
    "Tor" "\\Tor"       "Frac" "\\Frac"     "Proj" "\\Proj"

    ;; Probabilidad y Procesos Estocásticos (Sin colisiones)
    "sF"   "\\symcal{F}"
    "sB"   "\\symcal{B}"
    "sE"   "\\symcal{E}"
    "cas"  "\\text{c.s.}"  ;; Casi seguro
    "toc"  "\\xrightarrow{\\text{c.s.}}"
    "top"  "\\xrightarrow{\\mathbb{P}}"
    "tod"  "\\xrightarrow{d}"
    "toL"  "\\xrightarrow{L^p}"
    "Xt"   "(X_t)_{t \\ge 0}"
    "Xn"   "(X_n)_{n \\ge 1}"
    "Ft"   "(\\symcal{F}_t)_{t \\ge 0}"
    "Exp"  (tempel "\\symbb{E}\\left[ " p " \\right]" q)
    "Prob" (tempel "\\symbb{P}\\left( " p " \\right)" q)
    "Var"  (tempel "\\operatorname{Var}\\left( " p " \\right)" q)
    "Cov"  (tempel "\\operatorname{Cov}\\left( " p " \\right)" q)

    ;; Letras Griegas y Símbolos (;tecla)
    ";a" "\\alpha" ";A" "\\forall" ";;A" "\\aleph" ";b" "\\beta"
    ";c" "\\subset" ";;c" "\\subseteq" ";d" "\\delta" ";;d" "\\partial"
    ";D" "\\Delta" ";;D" "\\nabla" ";e" "\\epsilon" ";;e" "\\varepsilon"
    ";E" "\\exists" ";;;E" "\\ln" ";f" "\\phi" ";;f" "\\varphi" ";F" "\\Phi"
    ";g" "\\gamma" ";G" "\\Gamma" ";h" "\\eta" ";;h" "\\hbar"
    ";i" "\\iota" ";I" "\\imath" ";;I" "\\Im" ";;j" "\\jmath"
    ";k" "\\kappa" ";l" "\\lambda" ";;l" "\\ell" ";L" "\\Lambda" ";m" "\\mu"
    ";n" "\\nu" ";N" "\\nabla" ";o" "\\omega" ";O" "\\Omega" ";;O" "\\mho"
    ";p" "\\pi" ";;p" "\\varpi" ";P" "\\Pi" ";q" "\\theta" ";;q" "\\vartheta"
    ";Q" "\\Theta" ";r" "\\rho" ";;r" "\\varrho" ";s" "\\sigma" ";;s" "\\varsigma"
    ";S" "\\Sigma" ";t" "\\tau" ";u" "\\upsilon" ";U" "\\Upsilon" ";v" "\\vee"
    ";V" "\\Phi" ";w" "\\xi" ";W" "\\Xi" ";x" "\\chi" ";y" "\\psi" ";Y" "\\Psi"
    ";z" "\\zeta" ";0" "\\emptyset" ";8" "\\infty" ";!" "\\neg" ";^" "\\uparrow"
    ",v" "\\wedge" ",,v" "\\bigwedge" ";~" "\\approx" ";;~" "\\simeq" ";_" "\\downarrow"
    ";+" "\\cup" ";-" "\\leftrightarrow" ";;-" "\\longleftrightarrow"
    ";*" "\\times" ";/" "\\not" ";|" "\\mapsto" ";;|" "\\longmapsto"
    ";\\" "\\setminus" ";=" "\\Leftrightarrow" ";;=" "\\Longleftrightarrow"
    ";(" "\\langle" ";)" "\\rangle" ";[" "\\Leftarrow" ";;[" "\\Longleftarrow"
    ";]" "\\Rightarrow" ";;]" "\\Longrightarrow" ";{" "\\subset" ";;{" "\\subseteq"
    ";}" "\\supset" ";<" "\\leftarrow" ";;<" "\\longleftarrow" ";>" "\\rightarrow"
    ";;>" "\\longrightarrow" ";." "\\cdot"

    ;; Sucesiones en espacios métricos (Sin colisión de prefijos)
    "xsek"  "\\{x^k\\}_{k \\in \\N}"
    "xsed"  "\\{x^k\\}_{k \\in \\N} \\subseteq D"
    "xsen"  "(x_n)_{n \\ge 1}"

    ;; Bolas métricas y entornos
    "bball" (tempel "\\bar{B}(" (p "x_0") ", " (p "\\lambda") ")" q)
    "oball" (tempel "B(" (p "x_0") ", " (p "r") ")" q)

    ;; Conjuntos por comprensión: { x \in D | f(x) <= lambda }
    "cset"  (tempel "\\{ " (p "x \\in D") " \\mid " (p "f(x) \\le \\lambda") " \\}" q)

    ;; Sumatorias y límites indexados al vuelo
    "sumn"  "\\sum_{i=1}^{n}"
    "sumk"  "\\sum_{k=1}^{\\infty}"
    "sumj"  "\\sum_{j=1}^{m}"
    "limk"  "\\lim_{k \\to \\infty}"
    "limn"  "\\lim_{n \\to \\infty}"
    "limx"  (tempel "\\lim_{x \\to " (p "x_0") "}" q)
    "linf"  "\\liminf_{k \\to \\infty}"
    "lsup"  "\\limsup_{k \\to \\infty}"

    ;; Auto-corrección de dedos rápidos
    "tehta"  "\\theta"
    "lamda"  "\\lambda"
    "alfa"   "\\alpha"
    "omeag"  "\\omega"
    "inft"   "\\infty"
    "sigam"  "\\sigma"
    "epslon" "\\epsilon"
    "vpes"   "\\varepsilon"
    "nabal"  "\\nabla"

    :cond laas-object-on-left-condition
    "|e" my/laas-smart-eval)
  "Snippets matemáticos atómicos.")

(defvar laas-subscript-snippets
  `(:cond ,#'laas-auto-script-condition
    ,@(cl-loop for key in '("ii" "jj" "nn" "kk" "pp" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
               collect key collect #'laas-insert-script)
    "ip1" "_{i+1}" "im1" "_{i-1}" "jp1" "_{j+1}" "jm1" "_{j-1}"
    "np1" "_{n+1}" "nm1" "_{n-1}" "kp1" "_{k+1}" "km1" "_{k-1}")
  "Subíndices automáticos al vuelo.")
  
(defvar laas-superscript-snippets
  `(:cond ,#'laas-mathp
    ;; 1. Números (0-9): x`2 -> x^2
    ,@(cl-loop for key across "0123456789"
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 2. Letras minúsculas (sin i, j, k, n, m, o)
    ,@(cl-loop for key across "abcdefghlpqrstuvwxyz"
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 3. Mayúsculas (sin I, T, O)
    ,@(cl-loop for key across "ABCDEFGHJKLMNPQRSUVWXYZ" 
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 4. Índices base con DOBLE TOQUE (Sin espacios parásitos)
    "`ii" "^i"
    "`jj" "^j"
    "`kk" "^k"
    "`nn" "^n"
    "`mm" "^m"
    
    ;; 5. Aritmética de Índices (mn1 evita colisión con mm)
    "`ip1" "^{i+1}"   "`im1" "^{i-1}"
    "`jp1" "^{j+1}"   "`jm1" "^{j-1}"
    "`kp1" "^{k+1}"   "`km1" "^{k-1}"
    "`np1" "^{n+1}"   "`nm1" "^{n-1}"
    "`mp1" "^{m+1}"   "`mn1" "^{m-1}"
               
    ;; 6. Operadores frecuentes y exponentes algebraicos
    "`-"  "^{-}"
    "`+"  "^{+}"
    "`*"  "^{*}"
    "`T"  "^{\\top}"
    "``"  "^{-1}"
    "`O"  "^{\\perp}"
    "`op" "^{\\mathrm{op}}")
  "Superíndices rápidos con comilla invertida.")

(defvar laas-differential-snippets
  `(:cond ,#'laas-differential-cond
    "dt"  "\\diff t"
    "ds"  "\\diff s"
    "dx"  "\\diff x"
    "dy"  "\\diff y"
    "dz"  "\\diff z"
    "dbz" "\\diff \\overline{z}"
    "dP"  "\\diff \\symbb{P}"
    "dmu" "\\diff \\mu"
    "dnu" "\\diff \\nu")
  "Diferenciales rectos inteligentes (apuntes-scr.cls).")

(defvar laas-frac-snippet
  `(:cond ,#'laas-frac-cond "/" ,#'laas-smart-fraction))

(defvar laas-accent-snippets
  `(;; Modificadores de texto y matemática
    :cond ,#'laas-latex-accent-cond
    "'r" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symrm" "textrm")))
    "'i" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symit" "textit")))
    "'b" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symbf" "textbf")))
    "'e" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symem" "emph")))
    "'y" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symtt" "texttt")))
    "'f" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symsf" "textsf")))
    "'k" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symfrak" "textfrak")))

    ;; Solo texto normal
    :cond ,(lambda () (and (derived-mode-p 'latex-mode 'LaTeX-mode) (not (laas-mathp))))
    "'l" ,(lambda () (interactive) (laas-wrap-previous-object "textsl"))

    ;; Solo matemática
    :cond ,#'laas-object-on-left-condition
    "'B" ,(lambda () (interactive) (laas-wrap-previous-object "symbb"))
    "'F" ,(lambda () (interactive) (laas-wrap-previous-object "symfrak"))
    "'n" ,(lambda () (interactive) (laas-wrap-previous-object "norm"))
    "'a" ,(lambda () (interactive) (laas-wrap-previous-object "absolute"))
    ,@(cl-loop for (key . exp) in '(("'." . "dot") ("':" . "ddot") ("'~" . "tilde")
                                    ("'N" . "widetilde") ("'^" . "hat") ("'H" . "widehat")
                                    ("'-" . "bar") ("'T" . "overline") ("'_" . "underline")
                                    ("'{" . "overbrace") ("'}" . "underbrace") ("'>" . "vec")
                                    ("'/" . "grave") ("'\"". "acute") ("'v" . "check")
                                    ("'u" . "breve") ("'m" . "mbox") ("'c" . "symcal")
                                    ("'0" . ("{\\textstyle " . "}")) ("'1" . ("{\\displaystyle " . "}"))
                                    ("'2" . ("{\\scriptstyle " . "}")) ("'3" . ("{\\scriptscriptstyle " . "}"))
                                    ("'q" . "sqrt") (".. " . ("\\dot{" . "} "))
                                    (",." . "vec") (".," . "vec") ("~ " . ("\\tilde{" . "} "))
                                    ("hat" . "hat") ("bar" . "overline"))
               collect key collect (let ((expp exp)) (lambda () (interactive) (laas-wrap-previous-object expp)))))
  "Acentos y envolturas posfijas.")

(defvar laas-comma-snippets
  `(;; Editorial y Notas
    ",td"  (tempel "\\TODO{" p "}" q)
    ",fx"  (tempel "\\FIXME{" p "}" q)
    ",db"  (tempel "\\DEBUG{" p "}" q)
    ",nte" (tempel "\\NOTE{" p "}" q)
    
    ;; Polimórficos (Texto vs Matemática)
    :cond ,#'my/aas-polymorphic-cond
    ",bf" ,(my/aas-make-polymorphic '("\\symbf{" p "}" p) '("\\textbf{" p "}" p))
    ",bb" ,(my/aas-make-polymorphic '("\\symbb{" p "}" p) '("\\textbf{" p "}" p))
    ",cl" ,(my/aas-make-polymorphic '("\\symcal{" p "}" p) '("\\textit{" p "}" p))
    ",it" ,(my/aas-make-polymorphic '("\\symit{" p "}" p) '("\\textit{" p "}" p))
    ",sl" ,(my/aas-make-polymorphic '("\\symsl{" p "}" p) '("\\textsl{" p "}" p))
    ",sf" ,(my/aas-make-polymorphic '("\\symsf{" p "}" p) '("\\textsf{" p "}" p))
    ",tt" ,(my/aas-make-polymorphic '("\\symtt{" p "}" p) '("\\texttt{" p "}" p))
    ",rm" ,(my/aas-make-polymorphic '("\\symrm{" p "}" p) '("\\textrm{" p "}" p))
    ",em" ,(my/aas-make-polymorphic '("\\symit{" p "}" p) '("\\emph{" p "}" p))
    ",fk" ,(my/aas-make-polymorphic '("\\symfrak{" p "}" p) '("\\textfrak{" p "}" p))
    ",,p"  (tempel "( " p " )" q)
    ",,c"  (tempel "[ " p " ]" q)
    ",,l"  (tempel "\\{ " p " \\}" q)
    ",,b"  (tempel "| " p " |" q)
    ",,a" ,(my/aas-make-polymorphic '("\\langle " p " \\rangle" p) '("< " p " >" q))
    ",,P" ,(my/aas-make-polymorphic '("\\left( " p " \\right)" q) '("( " p " )" q))
    ",,C" ,(my/aas-make-polymorphic '("\\left[ " p " \\right]" q) '("[ " p " ]" q))
    ",,L" ,(my/aas-make-polymorphic '("\\left\\{ " p " \\right\\}" p) '("\\{ " p " \\}" q))
    ",,B" ,(my/aas-make-polymorphic '("\\left| " p " \\right|" q) '("| " p " |" q))
    ",,A" ,(my/aas-make-polymorphic '("\\left\\langle " p " \\right\\rangle" q) '("< " p " >" q))

    ;; Solo texto normal
    :cond ,#'my/aas-normal-mode-p
    ",im"  (tempel "\\( " p " \\)" p)
    ",dm"  (tempel "\\[" n> p n> "\\]" q)
    ",eq"  (tempel "\\begin{equation}[" p "]" n> p n> "\\end{equation}" q)
    ",ali" (tempel "\\begin{align*}" n> p n> "\\end{align*}" q)
    ",sc"  (tempel "\\textsc{" p "}" q)
    ",up"  (tempel "\\textup{" p "}" q)
    ",md"  (tempel "\\textmd{" p "}" q)
    ",no"  (tempel "\\textnormal{" p "}" q)

    ;; Pasos de Demostración EGA y Bourbaki (Sin colisiones)
    ",dst"  (tempel "\\directstep" n> q)           ;; (⇒)
    ",rst"  (tempel "\\reversestep" n> q)          ;; (⇐)
    ",cst"  (tempel "\\containedstep" n> q)        ;; (⊆)
    ",ist"  (tempel "\\inversecontainedstep" n> q) ;; (⊇)
    ",cba"  (tempel "\\casobase{" p "}" n> q)
    ",pi"   (tempel "\\pasoinductivo" n> q)
    ",hi"   (tempel "\\hipotesisind" n> q)
    ",dan"  (tempel "\\viragedangereux " q)        ;; Curva peligrosa Bourbaki ☡
    ",ddan" (tempel "\\dbviragedangereux " q)      ;; Doble curva peligrosa ☡☡
    ",brk"  (tempel "\\egabreak" n> q)             ;; Separador * * *
    ",par"  (tempel "\\parag[" p "] " q)           ;; Párrafo EGA: § 1.1
    ",npar" (tempel "\\numpar[" p "] " q)          ;; Párrafo numerado EGA

    ;; Mapeos y Morfismos (apuntes-scr.cls)
    ",map"  (tempel "\\map{" (p "f") "}{" (p "E") "}{" (p "F") "}{" (p "x") "}{" (p "f(x)") "}" q)
    ",inm"  (tempel "\\inmap{" (p "f") "}{" (p "E") "}{" (p "F") "}" q)
    
    ;; Teoremas y Entornos Bourbaki / apuntes-scr.cls (Sin colisiones)
    ",thm"  (tempel "\\begin{theorem}[" p "]" n> p n> "\\end{theorem}" q)
    ",pro"  (tempel "\\begin{proposition}[" p "]" n> p n> "\\end{proposition}" q)
    ",lem"  (tempel "\\begin{lemma}[" p "]" n> p n> "\\end{lemma}" q)
    ",cor"  (tempel "\\begin{corollary}[" p "]" n> p n> "\\end{corollary}" q)
    ",def"  (tempel "\\begin{definition}[" p "]" n> p n> "\\end{definition}" q)
    ",obs"  (tempel "\\begin{remark}[" p "]" n> p n> "\\end{remark}" q)
    ",nta"  (tempel "\\begin{notation}[" p "]" n> p n> "\\end{notation}" q)
    ",obj"  (tempel "\\begin{objective}[" p "]" n> p n> "\\end{objective}" q)
    ",ejm"  (tempel "\\begin{example}[" p "]" n> p n> "\\end{example}" q)
    ",exc"  (tempel "\\begin{exercise}[" p "]" n> p n> "\\end{exercise}" q)
    ",cm"   (tempel "\\begin{claim}[" p "]" n> p n> "\\end{claim}" q)
    ",cvb"  (tempel "\\begin{convencionbox}[" p "]" n> p n> "\\end{convencionbox}" q)
    ",sho"  (tempel "\\begin{scholium}[" p "]" n> p n> "\\end{scholium}" q)
    ",rap"  (tempel "\\begin{rappel}[" p "]" n> p n> "\\end{rappel}" q)
    ",exs"  (tempel "\\begin{exercices}" n> "\\exer " p n> "\\end{exercices}" q)
    ",ntb"  (tempel "\\begin{notabox}[" p "]" n> p n> "\\end{notabox}" q)
    ",wnb"  (tempel "\\begin{warningbox}[" p "]" n> p n> "\\end{warningbox}" q)
    ",prf"  ,#'my/aas-expand-proof-polymorphic
    ",enu"  (tempel "\\begin{enumerate}" n> "\\item " p n> "\\end{enumerate}" q)
    ",fig"  (tempel "\\begin{figure}[" (p "htpb") "]" n> "\\centering" n> "\\includegraphics[width=" (p "0.8") "\\linewidth]{" p "}" n> "\\caption{" p "}" n> "\\label{fig:" p "}" n> "\\end{figure}" q)

    ;; Solo Matemáticas
    :cond ,#'laas-mathp
    ",,i"   (tempel "_{" p "}" p)   
    ",,e"   (tempel "^{" p "}" p)
    "::"    (tempel "\\colon" p)
    ",="    (tempel "\\coloneq" p)
    "inv"   "^{-1}"             
    "Tr"    "^{\\top}"          
    "ort"   "^{\\perp}"
    ",mat"  ,#'my/insert-matrix
    ",cas"  (tempel "\\begin{cases}" n> p " & " p " \\\\" n> p " & " p n> "\\end{cases}" q)
    ",cds"  (tempel "\\begin{conditions}" n> p " & " p " \\\\" n> p " & " p n> "\\end{conditions}" q)
    ",opt"  (tempel "\\begin{mini*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(P)") "}" n> "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n> "\\end{mini*}")))

;; Registrar todos los grupos de snippets en AAS
(apply #'aas-set-snippets 'laas-mode laas-basic-snippets)
(apply #'aas-set-snippets 'laas-mode laas-subscript-snippets)
(apply #'aas-set-snippets 'laas-mode laas-superscript-snippets)
(apply #'aas-set-snippets 'laas-mode laas-differential-snippets)
(apply #'aas-set-snippets 'laas-mode laas-frac-snippet)
(apply #'aas-set-snippets 'laas-mode laas-accent-snippets)
(apply #'aas-set-snippets 'laas-mode laas-comma-snippets)

;; ==================================================================
;; --- 6. MODO MENOR Y ACTIVACIÓN ---
;; ==================================================================

;;;###autoload
(define-minor-mode laas-mode
  "Minor mode para auto-expansión inteligente de snippets LaTeX."
  :init-value nil
  :group 'laas
  (if laas-mode
      (progn
        (aas-mode +1)
        (aas-activate-keymap 'laas-mode)
        ;; Ganchos de seguridad globales en el buffer
        (add-hook 'aas-global-condition-hook #'laas--no-backslash-before-point? nil 'local)
        (add-hook 'aas-global-condition-hook #'laas--not-in-protected-command-p nil 'local)
        (add-hook 'aas-post-snippet-expand-hook #'laas-current-snippet-insert-post-space-if-wanted nil 'local))
    (aas-deactivate-keymap 'laas-mode)
    (remove-hook 'aas-global-condition-hook #'laas--no-backslash-before-point? 'local)
    (remove-hook 'aas-global-condition-hook #'laas--not-in-protected-command-p 'local)
    (remove-hook 'aas-post-snippet-expand-hook #'laas-current-snippet-insert-post-space-if-wanted 'local)))

(provide 'laas)
;;; laas.el ends here
