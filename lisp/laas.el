;;; laas.el --- A bundle of as-you-type LaTeX snippets -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020-2021 Yoav Marco, TEC
;; Modified by: Fayfer (Versión Definitiva Fusionada con Tempel)
;;
;;; Commentary:
;; Motor de expansión automática de snippets matemáticos y estructurales.
;; 100% optimizado para usar `tempel` y sin rastro de `yasnippet`.
;;
;;; Code:

(require 'aas)
(require 'texmathp)
(require 'tempel)
(require 'my-editor)

(defgroup laas nil
  "LaTeX snippets that expand mid-typing."
  :prefix "laas-"
  :group 'aas)

(defun laas-current-snippet-insert-post-space-if-wanted ()
  "Insert a space at point, if it seems warranted."
  (when (and (stringp aas-transient-snippet-expansion)
             (= ?\\ (aref aas-transient-snippet-expansion 0))
             (not (memq (char-after) '(?\) ?\]))))
    (insert " ")))

(defun laas-insert-script (s)
  "Add a subscript with a text of S (string)."
  (interactive (list (this-command-keys)))
  (pcase aas-transient-snippet-condition-result
    ('one-sub
     (insert "_" s))
    ('extended-sub
     (backward-char)
     (insert "{")
     (forward-char)
     (insert s "}"))))

(defun laas-mathp ()
  "Determine whether point is within a LaTeX maths block."
  (cond
   ((derived-mode-p 'latex-mode) (texmathp))
   ((derived-mode-p 'org-mode) (laas-org-mathp))
   (t nil)))

(declare-function org-inside-LaTeX-fragment-p "org")
(declare-function org-element-at-point "org-element")
(declare-function org-element-type "org-element")

(defun laas-org-mathp ()
  (or (org-inside-LaTeX-fragment-p)
      (eq (org-element-type (org-element-at-point)) 'latex-environment)))

(defun laas-auto-script-condition ()
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
  "Return the starting position of the left-adjacent TeX object from POINT."
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
  "Wrap previous TeX object in TEX-COMMAND."
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
;; --- FUNCIONES INTELIGENTES TEMPEL (Fracciones y Evaluaciones) ---
;; ==================================================================

(defun laas-frac-cond ()
  (cond ((and (= (char-before) ?/) (laas-mathp)) 'standalone-frac)
        ((laas-object-on-left-condition) 'wrapping-frac)))

(defun laas-smart-fraction ()
  "Expansión pura de fracciones usando Tempel."
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
;; --- LÓGICA POLIMÓRFICA INTEGRADA ---
;; ==================================================================

(defun my/aas-normal-mode-p ()
  "Verifica si estamos en modo texto y precedidos de espacio o delimitadores."
  (and (not (laas-mathp))
       (or (bobp) 
           (memq (char-before) '(?\s ?\n ?\t ?\{ ?\[ ?\( ?~)))))

(defun my/aas-proof-context ()
  "Determina el contexto de demostración según el entorno de tesis-uni.cls."
  (let ((current-env (if (fboundp 'LaTeX-current-environment) (LaTeX-current-environment) "document")))
    (cond
     ;; Si estamos dentro de un proof, claim o claim*, el siguiente nivel es claimproof
     ((member current-env '("proof" "claim" "claim*")) 'afirmacion)
     ((member current-env '("exercise" "problem" "question" "exc")) 'solucion)
     (t 'demostracion))))

(defun my/aas-expand-proof-polymorphic ()
  "Expande el entorno de prueba correcto según tesis-uni.cls."
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

;; ==================================================================
;; --- DICCIONARIOS DE SNIPPETS ---
;; ==================================================================

;; Función faltante restaurada:
(defun laas-latex-accent-cond ()
  (or (derived-mode-p 'latex-mode)
      (laas-mathp)))

(defvar laas-basic-snippets
  '(:cond laas-mathp
    "!=" "\\neq"  "!>" "\\mapsto"  "**" "\\cdot"  "+-" "\\pm"  "-+" "\\mp"
    "->" "\\to"   "..." "\\dots"   "<<" "\\ll"    "<=" "\\leq" "<>" "\\diamond"
    "=<" "\\impliedby" "==" "&="   "=>" "\\implies" ">=" "\\geq" ">>" "\\gg"
    "AA" "\\forall" "EE" "\\exists" "cb" "^3" "sr" "^2"
    "iff" "\\iff" "inn" "\\in" "nin" "\\not\\in" "xx" "\\times"
    "|->" "\\mapsto" "|=" "\\models" "||" "\\mid" "~=" "\\approx" "~~" "\\sim"
    "part" (tempel "\\frac{\\partial " p "}{\\partial " p "}" q)
    "arccos" "\\arccos" "arccot" "\\arccot" "arccsc" "\\arccsc" "arcsec" "\\arcsec"
    "arcsin" "\\arcsin" "arctan" "\\arctan" "cos" "\\cos" "cot" "\\cot"
    "csc" "\\csc" "exp" "\\exp" "ln" "\\ln" "log" "\\log" "perp" "\\perp"
    "sin" "\\sin" "tan" "\\tan" "star" "\\star" "gcd" "\\gcd" "min" "\\min"
    "max" "\\max" "eqv" "\\equiv"
    "CC" "\\C" "FF" "\\F" "HH" "\\H" "NN" "\\N" "PP" "\\P" "QQ" "\\Q" "RR" "\\R" "ZZ" "\\Z"
    "rrn" "\\R ^n"
	"ccn" "\\C ^n"
	"cinf" (tempel "\\symcal{C}^{\\infty}(" (p "M") ")" q)
    "hom"  (tempel "\\symcal{L}(" (p "V") " ; " (p "W") ")" q)
    "diff" (tempel "d F_{" (p "p") "}" q) ;; Para el diferencial dF_p
	"def" "\\coloneq"
	"tpm" (tempel "T_{" (p "p") "}" (p "M") q)
	"ctp" (tempel "T^{*}_{" (p "p") "}" (p "M") q)
	"qd" "\\quad" "qqd" "\\qquad"

    ";a" "\\alpha" ";A" "\\forall" ";;A" "\\aleph" ";b" "\\beta"
    ";c" "\\subset" ";;c" "\\subseteq" ";d" "\\delta" ";;d" "\\partial"
    ";D" "\\Delta" ";;D" "\\nabla" ";e" "\\epsilon" ";;e" "\\varepsilon"
    ";E" "\\exists" ";;;E" "\\ln" ";f" "\\phi" ";;f" "\\varphi" ";F" "\\Phi"
    ";g" "\\gamma" ";G" "\\Gamma" ";;;G" "10^{?}" ";h" "\\eta" ";;h" "\\hbar"
    ;; ";i" "\\in"
	"ox" "\\otimes"
	"op" "\\oplus"
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
    ";;>" "\\longrightarrow" ";." "\\cdot" "sgn" "\\sgn"
    
    :cond laas-object-on-left-condition
    "|e" my/laas-smart-eval)
  "Basic math snippets.")

(defvar laas-subscript-snippets
  `(:cond ,#'laas-auto-script-condition
    ,@(cl-loop for key in '("ii" "jj" "nn" "kk" "pp" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
               collect key collect #'laas-insert-script)
    "ip1" "_{i+1}" "im1" "_{i-1}" "jp1" "_{j+1}" "jm1" "_{j-1}"
    "np1" "_{n+1}" "nm1" "_{n-1}" "kp1" "_{k+1}" "km1" "_{k-1}")
  "Automatic subscripts.")
  
(defvar laas-superscript-snippets
  `(:cond ,#'laas-mathp
    ;; 1. Números (0-9): x`2 -> x^2
    ,@(cl-loop for key across "0123456789"
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 2. Letras minúsculas (EXCEPTO i, j, k, n, m para no chocar con las sumas/restas)
    ,@(cl-loop for key across "abcdefghlopqrstuvwxyz"
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 3. Mayúsculas (Omitimos I, T, O por los atajos especiales de abajo)
    ,@(cl-loop for key across "ABCDEFGHJKLMNPQRSUVWXYZ" 
               collect (concat "`" (char-to-string key)) 
               collect (concat "^" (char-to-string key)))
               
    ;; 4. Índices base con DOBLE TOQUE (Para permitir los atajos de abajo)
    "`ii" " ^i"
    "`jj" " ^j"
    "`kk" " ^k"
    "`nn" " ^n"
    "``m" " ^m"
    
    ;; 5. MATEMÁTICAS DE ÍNDICES (+1 y -1)
    "`ip1" "^{i+1}"   "`im1" "^{i-1}"
    "`jp1" "^{j+1}"   "`jm1" "^{j-1}"
    "`kp1" "^{k+1}"   "`km1" "^{k-1}"
    "`np1" "^{n+1}"   "`nm1" "^{n-1}"
    "`mp1" "^{m+1}"   "`mm1" "^{m-1}"
               
    ;; 6. Operadores frecuentes
    "`-" "^{-}"
    "`+" "^{+}"
    "`*" "^{*}"
    "`T" "^{\\top}"
    "``" "^{-1}"
    "`O" "^{\\perp}")
  "Superíndices ultrarrápidos y combinados usando la comilla invertida.")

(defvar laas-frac-snippet
  `(:cond ,#'laas-frac-cond "/" ,#'laas-smart-fraction))

(defvar laas-accent-snippets
  `(;; Texto normal y matemática
    :cond ,#'laas-latex-accent-cond
    "'r" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symrm" "textrm")))
    "'i" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symit" "textit")))
    "'b" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symbf" "textbf")))
    "'e" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symem" "emph")))
    "'y" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symtt" "texttt")))
    "'f" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symsf" "textsf")))
    "'k" ,(lambda () (interactive) (laas-wrap-previous-object (if (laas-mathp) "symfrak" "textfrak")))
    ;; Solo texto normal
    :cond ,(lambda () (and (derived-mode-p 'latex-mode) (not (laas-mathp))))
    "'l" ,(lambda () (interactive) (laas-wrap-previous-object "textsl"))
    ;; Solo matemática + Wrappers especiales
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
  "Accents and wrappers.")

(defvar laas-comma-snippets
  `(;; Editorial
    ",td"  (tempel "\\TODO{" p "}" q)
    ",fx"  (tempel "\\FIXME{" p "}" q)
    ",db"  (tempel "\\DEBUG{" p "}" q)
    ",nte" (tempel "\\NOTE{" p "}" q)
    
    ;; Polimórficos
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
	",fk" ,(my/aas-make-polymorphic '("\\symfrak{" p "}" p) '("\\textfrak{" p"}" p))
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
    
    ;; Teoremas y Entornos (Con 'q' para evitar espacios basura)
    ",thm" (tempel "\\begin{theorem}[" p "]" n> p n> "\\end{theorem}" q)
    ",pro" (tempel "\\begin{proposition}[" p "]" n> p n> "\\end{proposition}" q)
    ",lem" (tempel "\\begin{lemma}[" p "]" n> p n> "\\end{lemma}" q)
    ",cor" (tempel "\\begin{corollary}[" p "]" n> p n> "\\end{corollary}" q)
    ",def" (tempel "\\begin{definition}[" p "]" n> p n> "\\end{definition}" q)
    ",obs" (tempel "\\begin{remark}[" p "]" n> p n> "\\end{remark}" q)
    ",nta" (tempel "\\begin{notation}[" p "]" n> p n> "\\end{notation}" q)
    ",obj" (tempel "\\begin{objective}[" p "]" n> p n> "\\end{objective}" q)
    ",ejm" (tempel "\\begin{example}[" p "]" n> p n> "\\end{example}" q)
    ",exc" (tempel "\\begin{exercise}[" p "]" n> p n> "\\end{exercise}" q)
    ",prf" ,#'my/aas-expand-proof-polymorphic
    ",enu" (tempel "\\begin{enumerate}[label=\\normalfont" (p "\\arabic") "*., leftmargin=" (p "10mm") "]" n> "\\item " p n> "\\end{enumerate}" q)
    ",fig" (tempel "\\begin{figure}[" (p "htpb") "]" n> "\\centering" n> "\\includegraphics[width=" (p "0.8") "\\linewidth]{" p "}" n> "\\caption{" p "}" n> "\\label{fig:" p "}" n> "\\end{figure}" q)

    ;; Solo Matemáticas
    :cond ,#'laas-mathp
    ",,i" (tempel "_{" p "}" p)   
    ",,e" (tempel "^{" p "}" p)
    "::"  (tempel "\\colon" p)
    ",="  (tempel "\\coloneq" p)
    "inv" "^{-1}"             
    "Tr"  "^{\\top}"          
    "ort" "^{\\perp}"
	",mat" ,#'my/insert-matrix
    ",cases" (tempel "\\begin{cases}" n> p " & \\text{si } " p " \\\\" n> p " & \\text{si } " p n> "\\end{cases}" q)
    ",cas"   (tempel "\\begin{cases}" n> p " \\\\" n> p n> "\\end{cases}" q)
   ))

(defun laas--no-backslash-before-point? ()
  (not (eq (char-before) ?\\)))

(apply #'aas-set-snippets 'laas-mode laas-basic-snippets)
(apply #'aas-set-snippets 'laas-mode laas-subscript-snippets)
(apply #'aas-set-snippets 'laas-mode laas-superscript-snippets)
(apply #'aas-set-snippets 'laas-mode laas-frac-snippet)
(apply #'aas-set-snippets 'laas-mode laas-accent-snippets)
(apply #'aas-set-snippets 'laas-mode laas-comma-snippets)

;;;###autoload
(define-minor-mode laas-mode
  "Minor mode for enabling a ton of auto-activating LaTeX snippets."
  :init-value nil
  :group 'laas
  (if laas-mode
      (progn
        (aas-mode +1)
        (aas-activate-keymap 'laas-mode)
        (add-hook 'aas-global-condition-hook #'laas--no-backslash-before-point? nil 'local)
        (add-hook 'aas-post-snippet-expand-hook #'laas-current-snippet-insert-post-space-if-wanted nil 'local))
    (aas-deactivate-keymap 'laas-mode)
    (remove-hook 'aas-global-condition-hook #'laas--no-backslash-before-point? 'local)
    (remove-hook 'aas-post-snippet-expand-hook #'laas-current-snippet-insert-post-space-if-wanted 'local)))

(provide 'laas)
;;; laas.el ends here
