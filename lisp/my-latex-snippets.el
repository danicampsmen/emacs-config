;;; my-latex-snippets.el --- Snippets de LaTeX para Tempel -*- lexical-binding: t; -*-

(require 'hydra)

;; ------------------------------------------------------------------
;; --- 1. SNIPPETS DE ENVOLTURA Y TEXTO (Evil Visual Mode 'r') ---
;; ------------------------------------------------------------------
(defvar my-latex-common-snippets nil)
(setq my-latex-common-snippets '(
                                 ;; Envolturas Matemáticas Clásicas
                                 (dpp . ("\\left( " r p " \\right)" p))
                                 (pcc . ("\\left[ " r p " \\right]" p))
                                 (dll . ("\\left\\{ " r p " \\right\\}" p))
                                 (dbb . ("\\left| \\, " r p " \\, \\right|" p))
                                 (mk . ("\\( " r p " \\)"))
                                 (dm . ("\n\\[\n" r p "\n\\]" p))
								 
                                 ;; Modificadores de Texto
                                 ;; (bf . ("\\textbf{" r p "}"))  ;; Negrita (Bold Face)
                                 ;; (it . ("\\textit{" r p "}"))  ;; Cursiva (Italic Text)
                                 ;; (un . ("\\underline{" r p "}")) ;; Subrayado
                                 ;; (em . ("\\emph{" r p "}"))    ;; Énfasis
                                 ;; (tt . ("\\texttt{" r p "}"))  ;; Teletipo / Código (Monoespaciado)
                                 ;; (sc . ("\\textsc{" r p "}"))  ;; Versalitas (Small Caps)
                                 ;; (sf . ("\\textsf{" r p "}"))  ;; Sin serifas (Sans Serif)
                                 ;; (sl . ("\\textsl{" r p "}"))  ;; Inclinada (Slanted)
								 ))

;; ------------------------------------------------------------------
;; --- 2. MACROESTRUCTURAS Y ENTORNOS GENERALES ---
;; ------------------------------------------------------------------
(defvar my-latex-general-snippets nil)
(setq my-latex-general-snippets '(
								  (enu . ("\\begin{enumerate}" n> "\\item " r p n> "\\end{enumerate}" q))
								  (itm . ("\\begin{itemize}" n> "\\item " r p n> "\\end{itemize}" q))
								  (thm . ("\\begin{theorem}[" p "] \\label{thm:" (p "etiqueta") "}" n> r p n> "\\end{theorem}" q))
								  (pro . ("\\begin{proposition}[" p "] \\label{prop:" (p "etiqueta") "}" n> r p n> "\\end{proposition}" q))
								  (lem . ("\\begin{lemma}[" p "] \\label{lem:" (p "etiqueta") "}" n> r p n> "\\end{lemma}" q))
								  (cor . ("\\begin{corollary}[" p "] \\label{cor:" (p "etiqueta") "}" n> r p n> "\\end{corollary}" q))
								  (def . ("\\begin{definition}[" p "] \\label{def:" (p "etiqueta") "}" n> r p n> "\\end{definition}" q))
								  (ejm . ("\\begin{example}[" p "] \\label{ejm:" (p "etiqueta") "}" n> r p n> "\\end{example}" q))
								  (exc . ("\\begin{exercise}[" p "]" n> r p n> "\\end{exercise}" q))
								  (sol . ("\\begin{solution}" n> r p n> "\\end{solution}" q))
								  (prf . ("\\begin{proof}" n> r p n> "\\end{proof}" q))
								  (obs . ("\\begin{remark}[" p "]" n> r p n> "\\end{remark}" q))
								  (nta . ("\\begin{notation}[" p "]" n> r p n> "\\end{notation}" q))
								  (obj . ("\\begin{objective}[" p "]" n> r p n> "\\end{objective}" q))
								  (eq  . ("\\begin{equation}[" p "]" n> r p n> "\\end{equation}" q))
								  (clm . ("\\begin{claim}[" p "]" n> r p n> "\\end{claim}" q))
								  (clms . ("\\begin{claim*}[" p "]" n> r p n> "\\end{claim*}" q))



								  ;; Envuelve texto seleccionado en cualquier entorno
								  (env . ("\\begin{" (s env) "}[" p "]" n> r p n> "\\end{" (s env) "}" q))
								  
								  (fig "\\begin{figure}[" 
									   (p (completing-read "Posición: " '("htpb" "H" "h!" "t" "b") nil nil "htpb")) "]" n> 
									   "\\centering" n> 
									   "\\includegraphics[width=" (p "0.8") "\\linewidth]{" 
									   ;; Abre un buscador de archivos de imagen usando Cape/Vertico para la imagen!
									   (p (read-file-name "Imagen: " nil nil t nil (lambda (f) (string-match-p "\\.\\(png\\|jpg\\|pdf\\|svg\\)$" f)))) "}" n> 
									   "\\caption{" p "}" n> 
									   "\\label{fig:" (p "etiqueta") "}" n> 
									   "\\end{figure}" q)

								  ;; Tabla
								  (tab . ("\\begin{table}[" (p (completing-read "Posición: " '("htpb" "H" "h!" "t" "b") nil nil "htpb")) "]" n>
									      "\\centering" n>
									      "\\caption{" p "}" n>
									      "\\label{tab:" (p "etiqueta") "}" n>
									      "\\begin{tabular}{" (p "lcr") "}" n>
									      r p n>
									      "\\end{tabular}" n>
									      "\\end{table}" q))

								  ;; Diagrama conmutativo tikzcd
								  (tikz . ("\\begin{tikzcd}" n> r p n> "\\end{tikzcd}" q))

								  ;; Subfigure
								  (subf . ("\\begin{subfigure}{0.45\\linewidth}" n>
									       "\\centering" n>
									       "\\includegraphics[width=\\linewidth]{" (p "imagen") "}" n>
									       "\\caption{" p "}" n>
									       "\\end{subfigure}" q))
								  ))

;; ------------------------------------------------------------------
;; --- 3. MATEMÁTICAS: CÁLCULO Y FUENTES ---
;; ------------------------------------------------------------------
(defvar my-latex-math-snippets nil)
(setq my-latex-math-snippets '(
							   ;; Si seleccionas texto (r), se pone en el numerador.
							   ;; La 'q' final asegura que Tempel se cierre inmediatamente al terminar.
							   (fr . ("\\frac{" r p "}{" p "}" q))
							   
							   ;; Derivada inteligente que usa la región si hay una seleccionada
							   (part . ("\\frac{\\partial " r p "}{\\partial " (p "x") "}" q))
							   (diff . ("\\frac{d " (p "f") "}{d " (p "x") "}" p))
							   (sum  . ("\\sum_{" (p "i=1") "}^{" (p "\\infty") "}" p))
							   (lim  . ("\\lim_{" (p "n") "\\to " (p "\\infty") "}" p))
							   (int  . ("\\int_{" (p "a") "}^{" (p "b") "}" p))
							   (prod . ("\\prod_{" (p "i=1") "}^{" (p "n") "}" p))
							   (mbb  . ("\\symbb{" r p "}"))
							   (mcal . ("\\symcal{" r p "}"))
							   (mfr  . ("\\symfrak{" r p "}"))
							   (mrm  . ("\\mathrm{" r p "}"))
							   (mbf  . ("\\mathbf{" r p "}"))
							   (msf  . ("\\mathsf{" r p "}"))
							   (mit  . ("\\mathit{" r p "}"))
							   ;; Producto tensorial rápido (ya que lo usas mucho)
							   (ot . ("\\otimes "))
							   (mini . ("\\begin{mini*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(P)") "}" n> "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n> "\\end{mini*}"))

							   (maxi . ("\\begin{maxi*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(D)") "}" n> "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n> "\\end{maxi*}"))
							   (acon . ("\\addConstraint{" (p "h(x)") "}{" (p "= 0") "}" q))

							   ;; Funciones (Dominio, Codominio y Asignación)
							   (dmap . ("\\map{" p "}{" p "}{" p "}{" p "}{" p "}{" p "}" q))
							   (evr . ("\\Evr"))
							   (evc . ("\\Evc"))

							   (ceq . ("\\coloneq" q))
							   (op  . ("\\operatorname{" p "}" q))
							   (ix  . ("\\index{" p "}" q))

							   ;; --- Geometría Compleja / Kähler ---
							   (dox  . ("\\overline{\\partial}"))           ;; ∂̄ (operador Dolbeault)
							   (del  . ("\\partial"))                         ;; ∂
							   (delb . ("\\overline{\\partial}"))             ;; alias ∂̄
							   (om   . ("\\omega"))                           ;; forma de Kähler
							   (hodge . ("\\Delta_{d}"))                      ;; Laplaciano de Hodge
							   (drc  . ("d^{c}"))                             ;; d^c = J⁻¹ d J

							   ;; --- Optimización No Lineal ---
							   (kkt . ("\\text{sujeto a: } \\nabla f(x) + \\lambda^{\\top} \\nabla h(x) + \\mu^{\\top} \\nabla g(x) = 0" q))
							   (lagr . ("\\symcal{L}(" p "x, \\lambda, \\mu) = " p "f(x) + \\lambda^{\\top} h(x) + \\mu^{\\top} g(x)" q))
							   (hess . ("\\nabla^{2} f(" p "x)" q))
							   (grad . ("\\nabla f(" p "x)" q))

							   ;; --- Álgebra Conmutativa ---
							   (loc  . ("S^{-1}R"))                           ;; localización
							   (comp . ("\\widehat{R}"))                       ;; completación
							   (mad  . ("\\symfrak{m}-\\text{ádico}"))
							   (anill . ("(R, \\symfrak{m}, k)"))             ;; anillo local

							   ;; --- Texto y decoraciones ---
							   (tx  . ("\\text{" r p "}" q))
							   (ol  . ("\\overline{" r p "}" q))
							   (ts  . ("\\widetilde{" r p "}" q))
							   (ht  . ("\\widehat{" r p "}" q))
							   (na  . ("\\nabla"))
							   (dst . ("\\displaystyle"))
							   (pmod . ("\\pmod{" p "}" q))

							   ;; --- Variantes de fracciones ---
							   (dfr . ("\\dfrac{" r p "}{" p "}" q))
							   (tfr . ("\\tfrac{" r p "}{" p "}" q))

							   ;; --- Matrices ---
							   (bm  . ("\\begin{bmatrix}" n> r p n> "\\end{bmatrix}" q))
							   (pm  . ("\\begin{pmatrix}" n> r p n> "\\end{pmatrix}" q))

							   ;; --- Estructuras matemáticas generales ---
							   (cases . ("\\begin{cases}" n> r p n> "\\end{cases}" q))
							   (align . ("\\begin{align*}" n> r p n> "\\end{align*}" q))
							   (eqref . ("\\eqref{eq:" (p "etiqueta") "}" q))
							   ))

;; ------------------------------------------------------------------
;; --- 3.5 SNIPPETS DE ENTORNOS ESPECIALIZADOS (Cursos 2026-I) ---
;; ------------------------------------------------------------------
(defvar my-latex-specialized-snippets nil)
(setq my-latex-specialized-snippets '(
									  (pcs  . ("\\begin{proofcases}" n> r p n> "\\end{proofcases}" q))
									  (cpf  . ("\\begin{claimproof}" n> r p n> "\\end{claimproof}" q))
									  (cmt  . ("\\begin{commentary}" n> r p n> "\\end{commentary}" q))
									  ))

;; ------------------------------------------------------------------
;; --- 4. INTEGRACIÓN NATIVA CON TEMPEL ---
;; ------------------------------------------------------------------
(defun my-latex-tempel-templates ()
  "Devuelve los snippets de LaTeX solo si el modo actual es LaTeX."
  (when (derived-mode-p 'latex-mode 'LaTeX-mode)
    (append my-latex-common-snippets
            my-latex-general-snippets
            my-latex-math-snippets
            my-latex-specialized-snippets)))

(with-eval-after-load 'tempel
  ;; Añadir la función (no una variable) a las fuentes de Tempel
  (add-to-list 'tempel-template-sources 'my-latex-tempel-templates))

;; ------------------------------------------------------------------
;; --- 5. HYDRA DE AYUDA VISUAL ---
;; ------------------------------------------------------------------
(defvar my-latex-snippet-hydra-last-trigger nil
  "Último trigger insertado por la Hydra de snippets.")

(defhydra my-latex-snippet-hydra (:color blue :hint nil :columns 5)

  "
  ^Envoltura^^      ^Entornos^^       ^Matemáticas^^     ^Geom. Compleja^^    ^Optimización^^
  ──────────────────────────────────────────────────────────────────────────────────────────
  _dpp_: ()  _mk_: \\(\\)
  _pcc_: []  _dm_: \\[\\]        _enu_: enumerate    _fr_: frac          _dox_: ∂̄            _kkt_: KKT
  _dll_: {}  _tab_: table       _itm_: itemize       _part_: ∂/∂x        _delb_: ∂̄           _lagr_: Lagrangiano
  _dbb_: ||  _tikz_: tikzcd     _thm_: theorem       _sum_: ∑             _om_: ω             _hess_: Hessiano
  _subf_: subfigure   _env_: env         _pro_: prop          _lim_: lim          _om_: ω            _grad_: Gradiente
                         _fig_: figure      _lem_: lemma         _int_: ∫             _hodge_: Δ_d
                         _def_: definition  _sum_: sum          _drc_: d^c          ^^
                         _ejm_: example                     ^^               ^^
                         _prf_: proof
                         _cases_: cases
                         _align_: align*        ^^               ^^
                         _eqr_: eqref

  ^Fuentes^^          ^Álgebra Conmut.^^     ^Texto/Decoración^^
  ──────────────────────────────────────────────────────────────────
  _mbb_: \\symbb      _loc_: S⁻¹R            _tx_: \\text{...}
  _mcal_: \\symcal     _comp_: R̂             _ol_: \\overline{...}
  _mfr_: \\symfrak     _mad_: m-ádico         _ts_: \\widetilde{...}
  _mbf_: \\mathbf      _anill_: (R,m,k)       _ht_: \\widehat{...}
  _mrm_: \\mathrm                             _na_: \\nabla
  _mit_: \\mathit                             _dst_: \\displaystyle
  _msf_: \\mathsf                             _pmod_: \\pmod{...}
  _dfr_: \\dfrac       _bm_: [matrix]         _pcs_: proofcases
  _tfr_: \\tfrac       _pm_: (matrix)         _cpf_: claimproof
                                              _cmt_: commentary

  "
  ("dpp"  (my-latex-snippet-hydra-insert "dpp")  :exit t)
  ("pcc"  (my-latex-snippet-hydra-insert "pcc")  :exit t)
  ("dll"  (my-latex-snippet-hydra-insert "dll")  :exit t)
  ("dbb"  (my-latex-snippet-hydra-insert "dbb")  :exit t)
  ("mk"   (my-latex-snippet-hydra-insert "mk")   :exit t)
  ("dm"   (my-latex-snippet-hydra-insert "dm")   :exit t)
  ("enu"  (my-latex-snippet-hydra-insert "enu")  :exit t)
  ("itm"  (my-latex-snippet-hydra-insert "itm")  :exit t)
  ("thm"  (my-latex-snippet-hydra-insert "thm")  :exit t)
  ("pro"  (my-latex-snippet-hydra-insert "pro")  :exit t)
  ("lem"  (my-latex-snippet-hydra-insert "lem")  :exit t)
  ("cor"  (my-latex-snippet-hydra-insert "cor")  :exit t)
  ("def"  (my-latex-snippet-hydra-insert "def")  :exit t)
  ("ejm"  (my-latex-snippet-hydra-insert "ejm")  :exit t)
  ("prf"  (my-latex-snippet-hydra-insert "prf")  :exit t)
  ("obs"  (my-latex-snippet-hydra-insert "obs")  :exit t)
  ("clm"  (my-latex-snippet-hydra-insert "clm")  :exit t)
  ("fig"  (my-latex-snippet-hydra-insert "fig")  :exit t)
  ("tab"  (my-latex-snippet-hydra-insert "tab")  :exit t)
  ("tikz" (my-latex-snippet-hydra-insert "tikz") :exit t)
  ("subf" (my-latex-snippet-hydra-insert "subf") :exit t)
  ("env"  (my-latex-snippet-hydra-insert "env")  :exit t)
  ("fr"   (my-latex-snippet-hydra-insert "fr")   :exit t)
  ("part" (my-latex-snippet-hydra-insert "part") :exit t)
  ("sum"  (my-latex-snippet-hydra-insert "sum")  :exit t)
  ("lim"  (my-latex-snippet-hydra-insert "lim")  :exit t)
  ("int"  (my-latex-snippet-hydra-insert "int")  :exit t)
  ("pdt"  (my-latex-snippet-hydra-insert "prod") :exit t)
  ("mbb"  (my-latex-snippet-hydra-insert "mbb")  :exit t)
  ("mcal" (my-latex-snippet-hydra-insert "mcal") :exit t)
  ("mfr"  (my-latex-snippet-hydra-insert "mfr")  :exit t)
  ("mbf"  (my-latex-snippet-hydra-insert "mbf")  :exit t)
  ("mrm"  (my-latex-snippet-hydra-insert "mrm")  :exit t)
  ("mit"  (my-latex-snippet-hydra-insert "mit")  :exit t)
  ("msf"  (my-latex-snippet-hydra-insert "msf")  :exit t)
  ("ot"   (my-latex-snippet-hydra-insert "ot")   :exit t)
  ("cases" (my-latex-snippet-hydra-insert "cases") :exit t)
  ("align" (my-latex-snippet-hydra-insert "align") :exit t)
  ("eqr" (my-latex-snippet-hydra-insert "eqref") :exit t)
  ("dox"  (my-latex-snippet-hydra-insert "dox")  :exit t)
  ("delb" (my-latex-snippet-hydra-insert "delb") :exit t)
  ("om"   (my-latex-snippet-hydra-insert "om")   :exit t)
  ("hodge" (my-latex-snippet-hydra-insert "hodge") :exit t)
  ("drc"  (my-latex-snippet-hydra-insert "drc")  :exit t)
  ("kkt"  (my-latex-snippet-hydra-insert "kkt")  :exit t)
  ("lagr" (my-latex-snippet-hydra-insert "lagr") :exit t)
  ("hess" (my-latex-snippet-hydra-insert "hess") :exit t)
  ("grad" (my-latex-snippet-hydra-insert "grad") :exit t)
  ("loc"  (my-latex-snippet-hydra-insert "loc")  :exit t)
  ("comp" (my-latex-snippet-hydra-insert "comp") :exit t)
  ("mad"  (my-latex-snippet-hydra-insert "mad")  :exit t)
  ("anill" (my-latex-snippet-hydra-insert "anill") :exit t)
  ("tx"   (my-latex-snippet-hydra-insert "tx")   :exit t)
  ("ol"   (my-latex-snippet-hydra-insert "ol")   :exit t)
  ("ts"   (my-latex-snippet-hydra-insert "ts")   :exit t)
  ("ht"   (my-latex-snippet-hydra-insert "ht")   :exit t)
  ("na"   (my-latex-snippet-hydra-insert "na")   :exit t)
  ("dst"  (my-latex-snippet-hydra-insert "dst")  :exit t)
  ("pmod" (my-latex-snippet-hydra-insert "pmod") :exit t)
  ("dfr"  (my-latex-snippet-hydra-insert "dfr")  :exit t)
  ("tfr"  (my-latex-snippet-hydra-insert "tfr")  :exit t)
  ("bm"   (my-latex-snippet-hydra-insert "bm")   :exit t)
  ("pm"   (my-latex-snippet-hydra-insert "pm")   :exit t)
  ("pcs"  (my-latex-snippet-hydra-insert "pcs")  :exit t)
  ("cpf"  (my-latex-snippet-hydra-insert "cpf")  :exit t)
  ("cmt"  (my-latex-snippet-hydra-insert "cmt")  :exit t)
  ("q" nil "salir"))

(defun my-latex-snippet-hydra-insert (trigger)
  "Inserta el snippet de Tempel con el TRIGGER dado."
  (interactive)
  (setq my-latex-snippet-hydra-last-trigger trigger)
  (insert trigger)
  (tempel-expand t))

(provide 'my-latex-snippets)
