;;; my-latex-snippets.el --- Snippets de Tempel para apuntes-scr.cls (Bourbaki Edition) -*- lexical-binding: t; -*-

(require 'hydra)
(require 'tempel)

;; ==================================================================
;; --- 1. ENVOLTURAS Y TEXTO (Modo Visual Evil / Tempel 'r') ---
;; ==================================================================
(defvar my-latex-common-snippets
  '(
    ;; Delimitadores y Envolturas
    (dpp   . ("\\left( " r p " \\right)" q))
    (pcc   . ("\\left[ " r p " \\right]" q))
    (dll   . ("\\left\\{ " r p " \\right\\}" q))
    (dbb   . ("\\left| " r p " \\right|" q))
    (mk    . ("\\( " r p " \\)"))
    (dm    . ("\n\\[\n" r p "\n\\]" q))

    ;; Modificadores de Texto
    (bf    . ("\\textbf{" r p "}"))
    (it    . ("\\textit{" r p "}"))
    (ul    . ("\\underline{" r p "}"))
    (em    . ("\\emph{" r p "}"))
    (tt    . ("\\texttt{" r p "}"))
    (sc    . ("\\textsc{" r p "}"))
    (sf    . ("\\textsf{" r p "}"))
    (sl    . ("\\textsl{" r p "}"))
    )
  "Snippets de envoltura para texto y delimitadores.")

;; ==================================================================
;; --- 2. TEOREMAS Y ENTORNOS BOURBAKI / IHÉS (apuntes-scr.cls) ---
;; ==================================================================
(defvar my-latex-general-snippets
  '(
    ;; --- Teoremas y Proposiciones (con etiqueta canónica) ---
    (thm   . ("\\begin{theorem}[" (p "") "]\\label{thm:" (p "etiqueta") "}" n> p n> "\\end{theorem}" q))
    (prp   . ("\\begin{properties}" n> "\\propitem{" (p "Propiedad") "} " p n> "\\end{properties}" q))
    (lem   . ("\\begin{lemma}[" (p "") "]\\label{lem:" (p "etiqueta") "}" n> p n> "\\end{lemma}" q))
    (cor   . ("\\begin{corollary}[" (p "") "]\\label{cor:" (p "etiqueta") "}" n> p n> "\\end{corollary}" q))
    (def   . ("\\begin{definition}[" (p "") "]\\label{def:" (p "etiqueta") "}" n> p n> "\\end{definition}" q))
    (ejm   . ("\\begin{example}[" (p "") "]\\label{ejm:" (p "etiqueta") "}" n> p n> "\\end{example}" q))
    (exc   . ("\\begin{exercise}[" (p "") "]" n> p n> "\\end{exercise}" q))
    (sol   . ("\\begin{solution}" n> p n> "\\end{solution}" q))
    (prf   . ("\\begin{proof}" n> p n> "\\end{proof}" q))
    (obs   . ("\\begin{remark}[" (p "") "]" n> p n> "\\end{remark}" q))
    (nta   . ("\\begin{notation}[" (p "") "]" n> p n> "\\end{notation}" q))
    (obj   . ("\\begin{objective}[" (p "") "]" n> p n> "\\end{objective}" q))
    (clm   . ("\\begin{claim}[" (p "") "]\\label{clm:" (p "etiqueta") "}" n> p n> "\\end{claim}" q))
    (clms  . ("\\begin{claim*}[" (p "") "]" n> p n> "\\end{claim*}" q))

    ;; --- Entornos Específicos de apuntes-scr.cls ---
    (sch   . ("\\begin{scholium}[" (p "") "]\\label{sch:" (p "etiqueta") "}" n> p n> "\\end{scholium}" q))
    (rap   . ("\\begin{rappel}[" (p "") "]\\label{rap:" (p "etiqueta") "}" n> p n> "\\end{rappel}" q))
    (cnt   . ("\\begin{counterexample}[" (p "") "]" n> p n> "\\end{counterexample}" q))
    (cbox  . ("\\begin{convencionbox}[" (p "") "]" n> p n> "\\end{convencionbox}" q))
    (egab  . ("\\begin{egabox}[" (p "") "]" n> p n> "\\end{egabox}" q))
    (ihesb . ("\\begin{ihesbox}[" (p "") "]" n> p n> "\\end{ihesbox}" q))
    (ntb   . ("\\begin{notabox}[" (p "") "]" n> p n> "\\end{notabox}" q))
    (wnb   . ("\\begin{warningbox}[" (p "") "]" n> p n> "\\end{warningbox}" q))
    (ctrl  . ("\\begin{controlbox}[" (p "") "]" n> p n> "\\end{controlbox}" q))
    (exs   . ("\\begin{exercices}" n> "\\exer " p n> "\\end{exercices}" q))
    (nth   . ("\\begin{notehistorique}" n> p n> "\\end{notehistorique}" q))
    (env   . ("\\begin{" (s env) "}[" (p "") "]" n> p n> "\\end{" (s env) "}" q))

    ;; --- Listas Estándar, EGA y Algoritmos ---
    (enu   . ("\\begin{enumerate}" n> "\\item " p n> "\\end{enumerate}" q))
    (itm   . ("\\begin{itemize}" n> "\\item " p n> "\\end{itemize}" q))
    (egal  . ("\\begin{egalist}" n> "\\item " p n> "\\end{egalist}" q))
    (tfae  . ("\\begin{tfae}" n> "\\item " p n> "\\end{tfae}" q))
    (props . ("\\begin{properties}" n> "\\propitem{" (p "Propiedad") "} " p n> "\\end{properties}" q))
    (algst . ("\\begin{algsteps}" n> "\\algstep{" (p "Paso") "} " p n> "\\end{algsteps}" q))
    (pcs   . ("\\begin{proofcases}" n> "\\item " p n> "\\end{proofcases}" q))
    (cpf   . ("\\begin{claimproof}" n> p n> "\\end{claimproof}" q))

    ;; --- Bloques de Código y Python (apuntes-scr.cls) ---
    (pycode . ("\\begin{pythoncode}[" (p "Título") "]" n> p n> "\\end{pythoncode}" q))
    (pylib  . ("\\begin{pythonlib}[" (p "Título") "]{" (p "archivo.py") "}" n> p n> "\\end{pythonlib}" q))
    (pyexec . ("\\begin{pythonexec}[" (p "Título") "]" n> p n> "\\end{pythonexec}" q))
    (pseudo . ("\\begin{pseudocodigo}[" (p "Algoritmo") "]{" (p "python") "}" n> p n> "\\end{pseudocodigo}" q))

    ;; --- Figuras y Tablas ---
    (fig   . ("\\begin{figure}[" (p "htpb") "]" n>
              "\\centering" n>
              "\\includegraphics[width=" (p "0.8") "\\linewidth]{" (p "ruta") "}" n>
              "\\caption{" p "}" n>
              "\\label{fig:" (p "etiqueta") "}" n>
              "\\end{figure}" q))
    (incfig . ("\\begin{figure}[" (p "htpb") "]" n>
               "\\centering" n>
               "\\incfig{" (p "figura") "}" n>
               "\\caption{" p "}" n>
               "\\label{fig:" (p "etiqueta") "}" n>
               "\\end{figure}" q))
    (subf  . ("\\begin{subfigure}{" (p "0.48") "\\linewidth}" n>
              "\\centering" n>
              "\\includegraphics[width=\\linewidth]{" (p "imagen") "}" n>
              "\\caption{" p "}" n>
              "\\label{subfig:" (p "etiqueta") "}" n>
              "\\end{subfigure}" q))
    (tab   . ("\\begin{table}[" (p "htpb") "]" n>
              "\\centering" n>
              "\\caption{" p "}" n>
              "\\label{tab:" (p "etiqueta") "}" n>
              "\\begin{tabular}{" (p "lcr") "}" n>
              p n>
              "\\end{tabular}" n>
              "\\end{table}" q))
    (tblr  . ("\\begin{table}[" (p "htpb") "]" n>
              "\\centering" n>
              "\\caption{" p "}" n>
              "\\label{tab:" (p "etiqueta") "}" n>
              "\\begin{tblr}{colspec={" (p "lcr") "}}" n>
              p n>
              "\\end{tblr}" n>
              "\\end{table}" q))
    )
  "Macro-estructuras y entornos de apuntes-scr.cls.")

;; ==================================================================
;; --- 3. MATEMÁTICAS, CÁLCULO Y OPTIMIZACIÓN ---
;; ==================================================================
(defvar my-latex-math-snippets
  '(
    ;; Cálculo y Derivadas (liberado de colisiones)
    (fr    . ("\\frac{" (p "num") "}{" (p "den") "}" q))
    (dfr   . ("\\dfrac{" (p "num") "}{" (p "den") "}" q))
    (tfr   . ("\\tfrac{" (p "num") "}{" (p "den") "}" q))
    (part  . ("\\frac{\\partial " (p "f") "}{\\partial " (p "x") "}" q))
    (diff  . ("\\frac{d " (p "f") "}{d " (p "x") "}" q)) ;; ¡Limpio y funcional con TAB!
    (sum   . ("\\sum_{" (p "i=1") "}^{" (p "\\infty") "}" q))
    (lim   . ("\\lim_{" (p "n") "\\to " (p "\\infty") "}" q))
    (int   . ("\\int_{" (p "a") "}^{" (p "b") "}" q))
    (prod  . ("\\prod_{" (p "i=1") "}^{" (p "n") "}" q))

    ;; Delimitadores y Funciones Formales
    (norm  . ("\\norm{" p "}" q))
    (abs   . ("\\absolute{" p "}" q))
    (abso  . ("\\absolute{" p "}" q))
    (inr   . ("\\inner{" (p "x") "}{" (p "y") "}" q))   ;; Renombrado para no chocar con 'inn' (\in)
    (opp   . ("\\operatorname{" p "}" q))              ;; Renombrado para no chocar con 'op' (\oplus)
    (fobj  . ("\\Fobj{" (p "f") "}{" (p "M") "}{" (p "N") "}{" (p "x") "}{" (p "f(x)") "}" q))

    ;; Optimización (optidef en apuntes-scr.cls)
    (mini  . ("\\begin{mini*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(P)") "}" n>
              "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n>
              "\\end{mini*}"))
    (maxi  . ("\\begin{maxi*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(D)") "}" n>
              "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n>
              "\\end{maxi*}"))
    (acon  . ("\\addConstraint{" (p "h(x)") "}{" (p "= 0") "}" q))
    (kkt   . ("\\nabla f(x) + \\lambda^{\\top} \\nabla h(x) + \\mu^{\\top} \\nabla g(x) = 0" q))
    (lagr  . ("\\symcal{L}(" (p "x") ", \\lambda, \\mu) = " (p "f(x)") " + \\lambda^{\\top} h(x) + \\mu^{\\top} g(x)" q))
    (hess  . ("\\nabla^{2} f(" (p "x") ")" q))
    (grad  . ("\\nabla f(" (p "x") ")" q))

    ;; Entornos Matemáticos con Alineación
    (cds   . ("\\begin{conditions}" n> (p "f(x)") " & " (p "\\text{si } x > 0") " \\\\" n> (p "0") " & " (p "\\text{en otro caso}") n> "\\end{conditions}" q))
    (cases . ("\\begin{cases}" n> (p "f(x)") " & " (p "\\text{si } x > 0") " \\\\" n> (p "0") " & " (p "\\text{en otro caso}") n> "\\end{cases}" q))
    (align . ("\\begin{align*}" n> p n> "\\end{align*}" q))
    (eq    . ("\\begin{equation}" n> p n> "\\end{equation}" q))
    (bmat  . ("\\begin{bmatrix}" n> p n> "\\end{bmatrix}" q))
    (pmat  . ("\\begin{pmatrix}" n> p n> "\\end{pmatrix}" q))
    (tikz  . ("\\begin{tikzcd}" n> p n> "\\end{tikzcd}" q))

;; Vectores columna rápidos
    (vec2 . ("\\begin{pmatrix} " (p "x_1") " \\\\ " (p "x_2") " \\end{pmatrix}" q))
    (vec3 . ("\\begin{pmatrix} " (p "x_1") " \\\\ " (p "x_2") " \\\\ " (p "x_3") " \\end{pmatrix}" q))
    (vecn . ("\\begin{pmatrix} " (p "x_1") " \\\\ \\vdots \\\\ " (p "x_n") " \\end{pmatrix}" q))

    ;; Matrices con paréntesis (pmatrix)
    (pmat2 . ("\\begin{pmatrix}" n> 
              (p "a") " & " (p "b") " \\\\" n> 
              (p "c") " & " (p "d") n> 
              "\\end{pmatrix}" q))
    (pmat3 . ("\\begin{pmatrix}" n> 
              (p "a") " & " (p "b") " & " (p "c") " \\\\" n> 
              (p "d") " & " (p "e") " & " (p "f") " \\\\" n> 
              (p "g") " & " (p "h") " & " (p "i") n> 
              "\\end{pmatrix}" q))

    ;; Matrices con corchetes (bmatrix)
    (bmat2 . ("\\begin{bmatrix}" n> 
              (p "a") " & " (p "b") " \\\\" n> 
              (p "c") " & " (p "d") n> 
              "\\end{bmatrix}" q))
    )
  "Snippets matemáticos y de optimización.")

;; ==================================================================
;; --- 4. INTEGRACIÓN CON TEMPEL ---
;; ==================================================================
(defun my-latex-tempel-templates ()
  "Devuelve la colección completa de snippets solo en buffers LaTeX."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    (append my-latex-common-snippets
            my-latex-general-snippets
            my-latex-math-snippets)))

(with-eval-after-load 'tempel
  (add-to-list 'tempel-template-sources 'my-latex-tempel-templates))

;; ==================================================================
;; --- 5. HYDRA VISUAL ACTUALIZADA ( ;th ) ---
;; ==================================================================
(defhydra my-latex-snippet-hydra (:color blue :hint nil :columns 5)
  "
  ^Teoremas Bourbaki^^   |^Entornos Especiales^^   |^Matemáticas & Cálculo^^  |^Listas & Código^^       |^Optimización^^
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
  _thm_: Teorema        |_clm_: Afirmación       |_fr_: Fracción           |_enu_: Enumerate        |_mini_: mini*
  _pro_: Proposición    |_cpf_: Claimproof       |_diff_: df/dx            |_itm_: Itemize          |_maxi_: maxi*
  _lem_: Lema           |_sch_: Escolio          |_part_: ∂f/∂x            |_egal_: Egalist (EGA)   |_acon_: addConstraint
  _cor_: Corolario      |_rap_: Recordatorio     |_sum_: Sumatoria         |_tfae_: TFAE            |_kkt_: KKT
  _def_: Definición     |_cnt_: Contraejemplo    |_int_: Integral          |_prp_: Properties       |_lagr_: Lagrangiano
  _ejm_: Ejemplo        |_cbox_: Convención      |_lim_: Límite            |_pycode_: Python Code   |_cds_: Conditions
  _exc_: Ejercicio      |_egab_: EGA Box         |_norm_: Norma ‖·‖        |_pseudo_: Pseudocódigo  |_cases_: Cases
  _sol_: Solución       |_exs_: Ejercicios       |_inr_: Producto ⟨·,·⟩    |_fig_: Figura           |_align_: Align*
  _prf_: Demostración   |_nth_: Nota Histórica   |_opp_:  \\operatorname    |_incfig_: Inkscape      |_bmat_: [Matriz]
  "
  ("thm"    (my-latex-snippet-hydra-insert "thm")    :exit t)
  ("pro"    (my-latex-snippet-hydra-insert "pro")    :exit t)
  ("lem"    (my-latex-snippet-hydra-insert "lem")    :exit t)
  ("cor"    (my-latex-snippet-hydra-insert "cor")    :exit t)
  ("def"    (my-latex-snippet-hydra-insert "def")    :exit t)
  ("ejm"    (my-latex-snippet-hydra-insert "ejm")    :exit t)
  ("exc"    (my-latex-snippet-hydra-insert "exc")    :exit t)
  ("sol"    (my-latex-snippet-hydra-insert "sol")    :exit t)
  ("prf"    (my-latex-snippet-hydra-insert "prf")    :exit t)
  ("clm"    (my-latex-snippet-hydra-insert "clm")    :exit t)
  ("cpf"    (my-latex-snippet-hydra-insert "cpf")    :exit t)
  ("sch"    (my-latex-snippet-hydra-insert "sch")    :exit t)
  ("rap"    (my-latex-snippet-hydra-insert "rap")    :exit t)
  ("cnt"    (my-latex-snippet-hydra-insert "cnt")    :exit t)
  ("cbox"   (my-latex-snippet-hydra-insert "cbox")   :exit t)
  ("egab"   (my-latex-snippet-hydra-insert "egab")   :exit t)
  ("exs"    (my-latex-snippet-hydra-insert "exs")    :exit t)
  ("nth"    (my-latex-snippet-hydra-insert "nth")    :exit t)

  ("fr"     (my-latex-snippet-hydra-insert "fr")     :exit t)
  ("diff"   (my-latex-snippet-hydra-insert "diff")   :exit t)
  ("part"   (my-latex-snippet-hydra-insert "part")   :exit t)
  ("sum"    (my-latex-snippet-hydra-insert "sum")    :exit t)
  ("int"    (my-latex-snippet-hydra-insert "int")    :exit t)
  ("lim"    (my-latex-snippet-hydra-insert "lim")    :exit t)
  ("norm"   (my-latex-snippet-hydra-insert "norm")   :exit t)
  ("inr"    (my-latex-snippet-hydra-insert "inr")    :exit t)
  ("opp"    (my-latex-snippet-hydra-insert "opp")    :exit t)

  ("enu"    (my-latex-snippet-hydra-insert "enu")    :exit t)
  ("itm"    (my-latex-snippet-hydra-insert "itm")    :exit t)
  ("egal"   (my-latex-snippet-hydra-insert "egal")   :exit t)
  ("tfae"   (my-latex-snippet-hydra-insert "tfae")   :exit t)
  ("prp"    (my-latex-snippet-hydra-insert "prp")    :exit t)
  ("pycode" (my-latex-snippet-hydra-insert "pycode") :exit t)
  ("pseudo" (my-latex-snippet-hydra-insert "pseudo") :exit t)
  ("fig"    (my-latex-snippet-hydra-insert "fig")    :exit t)
  ("incfig" (my-latex-snippet-hydra-insert "incfig") :exit t)

  ("mini"   (my-latex-snippet-hydra-insert "mini")   :exit t)
  ("maxi"   (my-latex-snippet-hydra-insert "maxi")   :exit t)
  ("acon"   (my-latex-snippet-hydra-insert "acon")   :exit t)
  ("kkt"    (my-latex-snippet-hydra-insert "kkt")    :exit t)
  ("lagr"   (my-latex-snippet-hydra-insert "lagr")   :exit t)
  ("cds"    (my-latex-snippet-hydra-insert "cds")    :exit t)
  ("cases"  (my-latex-snippet-hydra-insert "cases")  :exit t)
  ("align"  (my-latex-snippet-hydra-insert "align")  :exit t)
  ("bmat"   (my-latex-snippet-hydra-insert "bmat")   :exit t)
  ("q"      nil                                      "Salir"))

(defun my-latex-snippet-hydra-insert (trigger)
  "Inserta el trigger de Tempel y lo expande de inmediato."
  (interactive)
  (insert trigger)
  (tempel-expand t))

(provide 'my-latex-snippets)
;;; my-latex-snippets.el ends here
