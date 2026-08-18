;;; my-latex-snippets.el --- Snippets de LaTeX para Tempel y tesis-uni.cls -*- lexical-binding: t; -*-

(require 'hydra)

;; ------------------------------------------------------------------
;; --- 1. SNIPPETS DE ENVOLTURA Y TEXTO (Evil Visual Mode 'r') ---
;; ------------------------------------------------------------------
(defvar my-latex-common-snippets nil)
(setq my-latex-common-snippets
      '(
        ;; Envolturas Matemáticas Clásicas
        (dpp   . ("\\left( " r p " \\right)" p))
        (pcc   . ("\\left[ " r p " \\right]" p))
        (dll   . ("\\left\\{ " r p " \\right\\}" p))
        (dbb   . ("\\left| \\, " r p " \\, \\right|" p))
        (mk    . ("\\( " r p " \\)"))
        (dm    . ("\n\\[\n" r p "\n\\]" q))

        ;; Modificadores de Texto
        (bf    . ("\\textbf{" r p "}"))      ;; Negrita
        (it    . ("\\textit{" r p "}"))      ;; Cursiva
        (ul    . ("\\underline{" r p "}"))   ;; Subrayado
        (em    . ("\\emph{" r p "}"))        ;; Énfasis
        (tt    . ("\\texttt{" r p "}"))      ;; Monoespaciado
        (sc    . ("\\textsc{" r p "}"))      ;; Versalitas
        (sf    . ("\\textsf{" r p "}"))      ;; Sans Serif
        (sl    . ("\\textsl{" r p "}"))      ;; Inclinada
        ))

;; ------------------------------------------------------------------
;; --- 2. MACROESTRUCTURAS Y ENTORNOS GENERALES ---
;; ------------------------------------------------------------------
(defvar my-latex-general-snippets nil)
(setq my-latex-general-snippets
      '(
        ;; Listas Estándar y EGA
        (enu   . ("\\begin{enumerate}" n> "\\item " r q n> "\\end{enumerate}"))
        (itm   . ("\\begin{itemize}" n> "\\item " r q n> "\\end{itemize}"))
        (egal  . ("\\begin{egalist}" n> "\\item " r q n> "\\end{egalist}"))
        (ega   . ("\\begin{egalist}" n> "\\item " r q n> "\\end{egalist}"))
        (tfae  . ("\\begin{tfae}" n> "\\item " r q n> "\\end{tfae}"))

        ;; Teoremas y Estructuras amsthm
        (thm   . ("\\begin{theorem}[" p "] \\label{thm:" (p "etiqueta") "}" n> r q n> "\\end{theorem}"))
        (pro   . ("\\begin{proposition}[" p "] \\label{prop:" (p "etiqueta") "}" n> r q n> "\\end{proposition}"))
        (lem   . ("\\begin{lemma}[" p "] \\label{lem:" (p "etiqueta") "}" n> r q n> "\\end{lemma}"))
        (cor   . ("\\begin{corollary}[" p "] \\label{cor:" (p "etiqueta") "}" n> r q n> "\\end{corollary}"))
        (def   . ("\\begin{definition}[" p "] \\label{def:" (p "etiqueta") "}" n> r q n> "\\end{definition}"))
        (ejm   . ("\\begin{example}[" p "] \\label{ejm:" (p "etiqueta") "}" n> r q n> "\\end{example}"))
        (exc   . ("\\begin{exercise}[" p "]" n> r q n> "\\end{exercise}"))
        (sol   . ("\\begin{solution}" n> r q n> "\\end{solution}"))
        (prf   . ("\\begin{proof}" n> r q n> "\\end{proof}"))
        (obs   . ("\\begin{remark}[" p "]" n> r q n> "\\end{remark}"))
        (nta   . ("\\begin{notation}[" p "]" n> r q n> "\\end{notation}"))
        (obj   . ("\\begin{objective}[" p "]" n> r q n> "\\end{objective}"))
        (eq    . ("\\begin{equation}[" p "]" n> r q n> "\\end{equation}"))
        (clm   . ("\\begin{claim}[" p "]" n> r q n> "\\end{claim}"))
        (clms  . ("\\begin{claim*}[" p "]" n> r q n> "\\end{claim*}"))

        ;; Cajas y Preliminares tesis-uni.cls
        (cbox  . ("\\begin{convencionbox}[" p "]" n> r q n> "\\end{convencionbox}"))
        (res   . ("\\begin{resumen}[" p "]" n> r q n> "\\end{resumen}"))
        (abst  . ("\\begin{abstracting}[" p "]" n> r q n> "\\end{abstracting}"))
        (ded   . ("\\begin{dedicatoria}" n> r q n> "\\end{dedicatoria}"))
        (agr   . ("\\begin{agradecimientos}" n> r q n> "\\end{agradecimientos}"))

        ;; Envoltura Genérica
        (env   . ("\\begin{" (s env) "}[" p "]" n> r q n> "\\end{" (s env) "}"))

        ;; Figuras y Tablas
        (fig   . ("\\begin{figure}[" 
                  (p (completing-read "Posición: " '("htpb" "H" "h!" "t" "b") nil nil "htpb")) "]" n> 
                  "\\centering" n> 
                  "\\includegraphics[width=" (p "0.8") "\\linewidth]{" 
                  (p (read-file-name "Imagen: " nil nil t nil (lambda (f) (string-match-p "\\.\\(png\\|jpg\\|pdf\\|svg\\)$" f)))) "}" n> 
                  "\\caption{" p "}" n> 
                  "\\label{fig:" (p "etiqueta") "}" n> 
                  "\\end{figure}" q))

        (tab   . ("\\begin{table}[" (p (completing-read "Posición: " '("htpb" "H" "h!" "t" "b") nil nil "htpb")) "]" n>
                  "\\centering" n>
                  "\\caption{" p "}" n>
                  "\\label{tab:" (p "etiqueta") "}" n>
                  "\\begin{tabular}{" (p "lcr") "}" n>
                  r q n>
                  "\\end{tabular}" n>
                  "\\end{table}"))

        (tblr  . ("\\begin{table}[" (p (completing-read "Posición: " '("htpb" "H" "h!" "t" "b") nil nil "htpb")) "]" n>
                  "\\centering" n>
                  "\\caption{" p "}" n>
                  "\\label{tab:" (p "etiqueta") "}" n>
                  "\\begin{tblr}{colspec={" (p "lcr") "}}" n>
                  r q n>
                  "\\end{tblr}" n>
                  "\\end{table}"))

        (tikz  . ("\\begin{tikzcd}" n> r q n> "\\end{tikzcd}"))
        (subf  . ("\\begin{subfigure}{0.45\\linewidth}" n>
                  "\\centering" n>
                  "\\includegraphics[width=\\linewidth]{" (p "imagen") "}" n>
                  "\\caption{" p "}" n>
                  "\\end{subfigure}" q))
        ))

;; ------------------------------------------------------------------
;; --- 3. MATEMÁTICAS: CÁLCULO, ÁLGEBRA Y TESIS-UNI ---
;; ------------------------------------------------------------------
(defvar my-latex-math-snippets nil)
(setq my-latex-math-snippets
      '(
        ;; Cálculo y Análisis
        (fr    . ("\\frac{" r p "}{" p "}" q))
        (part  . ("\\frac{\\partial " r p "}{\\partial " (p "x") "}" q))
        (diff  . ("\\frac{d " (p "f") "}{d " (p "x") "}" p))
        (dif   . ("\\diff " p))
        (sum   . ("\\sum_{" (p "i=1") "}^{" (p "\\infty") "}" q))
        (lim   . ("\\lim_{" (p "n") "\\to " (p "\\infty") "}" q))
        (int   . ("\\int_{" (p "a") "}^{" (p "b") "}" q))
        (prod  . ("\\prod_{" (p "i=1") "}^{" (p "n") "}" q))

        ;; Fuentes Matemáticas
        (mbb   . ("\\symbb{" r p "}"))
        (mcal  . ("\\symcal{" r p "}"))
        (mfr   . ("\\symfrak{" r p "}"))
        (mrm   . ("\\mathrm{" r p "}"))
        (mbf   . ("\\mathbf{" r p "}"))
        (msf   . ("\\mathsf{" r p "}"))
        (mit   . ("\\mathit{" r p "}"))
        (ot    . ("\\otimes "))

        ;; Delimitadores y Funciones Formales tesis-uni.cls
        (norm  . ("\\norm{" r p "}" q))
        (abso  . ("\\absolute{" r p "}" q))
        (abs   . ("\\absolute{" r p "}" q))
        (inn   . ("\\inner{" (p "x") "}{" (p "y") "}" q))
        (fobj  . ("\\Fobj{" (p "f") "}{" (p "M") "}{" (p "N") "}{" (p "x") "}{" (p "f(x)") "}" q))

        ;; Optimización No Lineal
        (mini  . ("\\begin{mini*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(P)") "}" n> "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n> "\\end{mini*}"))
        (maxi  . ("\\begin{maxi*}{" (p "x \\in \\R^n") "}{" (p "f(x)") "}{}{" (p "(D)") "}" n> "\\addConstraint{" (p "g(x)") "}{\\le 0}" q n> "\\end{maxi*}"))
        (acon  . ("\\addConstraint{" (p "h(x)") "}{" (p "= 0") "}" q))
        (kkt   . ("\\text{sujeto a: } \\nabla f(x) + \\lambda^{\\top} \\nabla h(x) + \\mu^{\\top} \\nabla g(x) = 0" q))
        (lagr  . ("\\symcal{L}(" p "x, \\lambda, \\mu) = " p "f(x) + \\lambda^{\\top} h(x) + \\mu^{\\top} g(x)" q))
        (hess  . ("\\nabla^{2} f(" p "x)" q))
        (grad  . ("\\nabla f(" p "x)" q))

        ;; Operadores y Mapeos
        (dmap  . ("\\map{" p "}{" p "}{" p "}{" p "}{" p "}{" p "}" q))
        (evr   . ("\\Evr"))
        (evc   . ("\\Evc"))
        (ceq   . ("\\coloneq" q))
        (op    . ("\\operatorname{" p "}" q))
        (ix    . ("\\index{" p "}" q))

        ;; Geometría Compleja / Kähler
        (dox   . ("\\overline{\\partial}"))
        (del   . ("\\partial"))
        (delb  . ("\\overline{\\partial}"))
        (om    . ("\\omega"))
        (hodge . ("\\Delta_{d}"))
        (drc   . ("d^{c}"))

        ;; Álgebra Conmutativa
        (loc   . ("S^{-1}R"))
        (comp  . ("\\widehat{R}"))
        (mad   . ("\\symfrak{m}-\\text{ádico}"))
        (anill . ("(R, \\symfrak{m}, k)"))

        ;; Texto y Decoraciones
        (tx    . ("\\text{" r p "}" q))
        (ol    . ("\\overline{" r p "}" q))
        (ts    . ("\\widetilde{" r p "}" q))
        (ht    . ("\\widehat{" r p "}" q))
        (na    . ("\\nabla"))
        (dsty  . ("\\displaystyle"))
        (dst   . ("\\displaystyle"))
        (pmod  . ("\\pmod{" p "}" q))

        ;; Fracciones
        (dfr   . ("\\dfrac{" r p "}{" p "}" q))
        (tfr   . ("\\tfrac{" r p "}{" p "}" q))

        ;; Matrices y Ecuaciones
        (bmat  . ("\\begin{bmatrix}" n> r q n> "\\end{bmatrix}"))
        (bm    . ("\\begin{bmatrix}" n> r q n> "\\end{bmatrix}"))
        (pmat  . ("\\begin{pmatrix}" n> r q n> "\\end{pmatrix}"))
        (pm    . ("\\begin{pmatrix}" n> r q n> "\\end{pmatrix}"))
        (cases . ("\\begin{cases}" n> r q n> "\\end{cases}"))
        (align . ("\\begin{align*}" n> r q n> "\\end{align*}"))
        (eqref . ("\\eqref{eq:" (p "etiqueta") "}" q))
        ))

;; ------------------------------------------------------------------
;; --- 3.5 SNIPPETS DE ENTORNOS ESPECIALIZADOS (EGA / tesis-uni) ---
;; ------------------------------------------------------------------
(defvar my-latex-specialized-snippets nil)
(setq my-latex-specialized-snippets
      '(
        ;; Demostraciones estructuradas
        (pcs    . ("\\begin{proofcases}" n> "\\item " r q n> "\\end{proofcases}"))
        (cpf    . ("\\begin{claimproof}" n> r q n> "\\end{claimproof}"))
        (cmt    . ("\\begin{commentary}[" p "]" n> r q n> "\\end{commentary}"))

        ;; Pasos de Demostración EGA
        (dstp   . ("\\directstep" n> q))
        (dstep  . ("\\directstep" n> q))
        (rstp   . ("\\reversestep" n> q))
        (rstep  . ("\\reversestep" n> q))
        (cstp   . ("\\containedstep" n> q))
        (cstep  . ("\\containedstep" n> q))
        (icstp  . ("\\inversecontainedstep" n> q))
        (icstep . ("\\inversecontainedstep" n> q))

        ;; Párrafos Numerados y Separadores EGA
        (parag  . ("\\parag[" p "] " q))
        (numpar . ("\\numpar[" p "] " q))
        (egab   . ("\\egabreak" n> q))
        (vd     . ("\\viragedangereux" q))
        (csum   . ("\\chaptersummary" q))

        ;; Referencias Inteligentes tesis-uni.cls
        (sref   . ("\\sref[" (p "Sección") "]{" (p "etiqueta") "}" q))
        (eref   . ("\\eref{" (p "etiqueta") "}" q))
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
  (add-to-list 'tempel-template-sources 'my-latex-tempel-templates))

;; ------------------------------------------------------------------
;; --- 5. HYDRA DE AYUDA VISUAL UNIFICADA ---
;; ------------------------------------------------------------------
(defvar my-latex-snippet-hydra-last-trigger nil)

(defhydra my-latex-snippet-hydra (:color blue :hint nil :columns 5)
  "
  ^Envoltura^^      ^Entornos^^       ^Matemáticas^^     ^Geom. Compleja^^   ^Optimización^^
  ──────────────────────────────────────────────────────────────────────────────────────────
  _dpp_: ()         _enu_: enumerate  _fr_: frac         _dox_: ∂̄            _kkt_: KKT
  _pcc_: []         _itm_: itemize    _part_: ∂/∂x       _delb_: ∂̄           _lagr_: Lagrangiano
  _dll_: {}         _egal_: egalist   _diff_: df/dx      _om_: ω             _hess_: Hessiano
  _dbb_: ||         _tfae_: tfae      _sum_: ∑           _hodge_: Δd         _grad_: Gradiente
  _mk_: \\(\\)      _thm_: theorem    _lim_: lim         _drc_: d^c          _acon_: addConstraint
  _dm_: \\[\\]      _pro_: prop       _int_: ∫           ^^                  _mini_: mini*
  _tab_: table      _lem_: lemma      _pdt_: ∏           ^^                  _maxi_: maxi*
  _tblr_: tblr      _cor_: corolario  _norm_: ‖·‖        ^^                  ^^
  _tikz_: tikzcd    _def_: definition _abso_: |·|        ^^                  ^^
  _subf_: subfig    _ejm_: example    _inn_: ⟨·,·⟩       ^^                  ^^
  _fig_: figure     _prf_: proof      _fobj_: Fobj       ^^                  ^^
  _env_: env        _cases_: cases    _align_: align*    ^^                  ^^

  ^Fuentes^^        ^Álgebra Conmut.^^ ^Pasos EGA / IHÉS^^ ^Referencias / Cajas^^ ^Texto/Decoración^^
  ─────────────────────────────────────────────────────────────────────────────────────────────────
  _mbb_: \\symbb    _loc_: S⁻¹R        _dstp_: (⇒)        	 _sref_: \\sref      			_tx_: \\text{...}
  _mcal_: \\symcal  _comp_: R̂          _rstp_: (⇐)        	 _eref_: \\eref      			_ol_: \\overline{...}
  _mfr_: \\symfrak  _mad_: m-ádico     _cstp_: (⊆)        	 _cbox_: convencion  			_ts_: \\widetilde{...}
  _mbf_: \\mathbf   _anill_: (R,m,k)   _icstp_: (⊇)       	 _vd_: virage dang   			_ht_: \\widehat{...}
  _mrm_: \\mathrm   ^^                 _parag_: parag     	 _eqr_: eqref        			_na_: \\nabla
  _mit_: \\mathit   ^^                 _numpar_: numpar   	 _res_: resumen      			_dsty_: \\displaystyle
  _msf_: \\mathsf   _dfr_: \\dfrac     _egab_: egabreak   	 _abst_: abstract    			_pmod_: \\pmod{...}
  _ot_: \\otimes    _tfr_: \\tfrac     _pcs_: proofcases  	 _ded_: dedicatoria  			_bmat_: [matrix]
  ^^                ^^                 _cpf_: claimproof  	 _agr_: agradecim.   			_pmat_: (matrix)
  ^^                ^^                 _cmt_: commentary  	 _clm_: claim        			^^
  "
  ;; Envolturas
  ("dpp"    (my-latex-snippet-hydra-insert "dpp")    :exit t)
  ("pcc"    (my-latex-snippet-hydra-insert "pcc")    :exit t)
  ("dll"    (my-latex-snippet-hydra-insert "dll")    :exit t)
  ("dbb"    (my-latex-snippet-hydra-insert "dbb")    :exit t)
  ("mk"     (my-latex-snippet-hydra-insert "mk")     :exit t)
  ("dm"     (my-latex-snippet-hydra-insert "dm")     :exit t)

  ;; Entornos Estándar y EGA
  ("enu"    (my-latex-snippet-hydra-insert "enu")    :exit t)
  ("itm"    (my-latex-snippet-hydra-insert "itm")    :exit t)
  ("egal"   (my-latex-snippet-hydra-insert "egal")   :exit t)
  ("tfae"   (my-latex-snippet-hydra-insert "tfae")   :exit t)
  ("thm"    (my-latex-snippet-hydra-insert "thm")    :exit t)
  ("pro"    (my-latex-snippet-hydra-insert "pro")    :exit t)
  ("lem"    (my-latex-snippet-hydra-insert "lem")    :exit t)
  ("cor"    (my-latex-snippet-hydra-insert "cor")    :exit t)
  ("def"    (my-latex-snippet-hydra-insert "def")    :exit t)
  ("ejm"    (my-latex-snippet-hydra-insert "ejm")    :exit t)
  ("prf"    (my-latex-snippet-hydra-insert "prf")    :exit t)
  ("obs"    (my-latex-snippet-hydra-insert "obs")    :exit t)
  ("clm"    (my-latex-snippet-hydra-insert "clm")    :exit t)
  ("fig"    (my-latex-snippet-hydra-insert "fig")    :exit t)
  ("tab"    (my-latex-snippet-hydra-insert "tab")    :exit t)
  ("tblr"   (my-latex-snippet-hydra-insert "tblr")   :exit t)
  ("tikz"   (my-latex-snippet-hydra-insert "tikz")   :exit t)
  ("subf"   (my-latex-snippet-hydra-insert "subf")   :exit t)
  ("env"    (my-latex-snippet-hydra-insert "env")    :exit t)

  ;; Matemáticas y Cálculo
  ("fr"     (my-latex-snippet-hydra-insert "fr")     :exit t)
  ("part"   (my-latex-snippet-hydra-insert "part")   :exit t)
  ("diff"   (my-latex-snippet-hydra-insert "diff")   :exit t)
  ("sum"    (my-latex-snippet-hydra-insert "sum")    :exit t)
  ("lim"    (my-latex-snippet-hydra-insert "lim")    :exit t)
  ("int"    (my-latex-snippet-hydra-insert "int")    :exit t)
  ("pdt"    (my-latex-snippet-hydra-insert "prod")   :exit t)
  ("norm"   (my-latex-snippet-hydra-insert "norm")   :exit t)
  ("abso"   (my-latex-snippet-hydra-insert "abs")    :exit t)
  ("inn"    (my-latex-snippet-hydra-insert "inn")    :exit t)
  ("fobj"   (my-latex-snippet-hydra-insert "fobj")   :exit t)
  ("cases"  (my-latex-snippet-hydra-insert "cases")  :exit t)
  ("align"  (my-latex-snippet-hydra-insert "align")  :exit t)

  ;; Fuentes
  ("mbb"    (my-latex-snippet-hydra-insert "mbb")    :exit t)
  ("mcal"   (my-latex-snippet-hydra-insert "mcal")   :exit t)
  ("mfr"    (my-latex-snippet-hydra-insert "mfr")    :exit t)
  ("mbf"    (my-latex-snippet-hydra-insert "mbf")    :exit t)
  ("mrm"    (my-latex-snippet-hydra-insert "mrm")    :exit t)
  ("mit"    (my-latex-snippet-hydra-insert "mit")    :exit t)
  ("msf"    (my-latex-snippet-hydra-insert "msf")    :exit t)
  ("ot"     (my-latex-snippet-hydra-insert "ot")     :exit t)

  ;; Geometría Compleja
  ("dox"    (my-latex-snippet-hydra-insert "dox")    :exit t)
  ("delb"   (my-latex-snippet-hydra-insert "delb")   :exit t)
  ("om"     (my-latex-snippet-hydra-insert "om")     :exit t)
  ("hodge"  (my-latex-snippet-hydra-insert "hodge")  :exit t)
  ("drc"    (my-latex-snippet-hydra-insert "drc")    :exit t)

  ;; Optimización
  ("kkt"    (my-latex-snippet-hydra-insert "kkt")    :exit t)
  ("lagr"   (my-latex-snippet-hydra-insert "lagr")   :exit t)
  ("hess"   (my-latex-snippet-hydra-insert "hess")   :exit t)
  ("grad"   (my-latex-snippet-hydra-insert "grad")   :exit t)
  ("acon"   (my-latex-snippet-hydra-insert "acon")   :exit t)
  ("mini"   (my-latex-snippet-hydra-insert "mini")   :exit t)
  ("maxi"   (my-latex-snippet-hydra-insert "maxi")   :exit t)

  ;; Álgebra Conmutativa
  ("loc"    (my-latex-snippet-hydra-insert "loc")    :exit t)
  ("comp"   (my-latex-snippet-hydra-insert "comp")   :exit t)
  ("mad"    (my-latex-snippet-hydra-insert "mad")    :exit t)
  ("anill"  (my-latex-snippet-hydra-insert "anill")  :exit t)

  ;; Pasos y Párrafos EGA (tesis-uni.cls)
  ("dstp"   (my-latex-snippet-hydra-insert "dstp")   :exit t)
  ("rstp"   (my-latex-snippet-hydra-insert "rstp")   :exit t)
  ("cstp"   (my-latex-snippet-hydra-insert "cstp")   :exit t)
  ("icstp"  (my-latex-snippet-hydra-insert "icstp")  :exit t)
  ("parag"  (my-latex-snippet-hydra-insert "parag")  :exit t)
  ("numpar" (my-latex-snippet-hydra-insert "numpar") :exit t)
  ("egab"   (my-latex-snippet-hydra-insert "egab")   :exit t)
  ("vd"     (my-latex-snippet-hydra-insert "vd")     :exit t)
  ("pcs"    (my-latex-snippet-hydra-insert "pcs")    :exit t)
  ("cpf"    (my-latex-snippet-hydra-insert "cpf")    :exit t)
  ("cmt"    (my-latex-snippet-hydra-insert "cmt")    :exit t)

  ;; Cajas y Preliminares tesis-uni.cls
  ("sref"   (my-latex-snippet-hydra-insert "sref")   :exit t)
  ("eref"   (my-latex-snippet-hydra-insert "eref")   :exit t)
  ("cbox"   (my-latex-snippet-hydra-insert "cbox")   :exit t)
  ("res"    (my-latex-snippet-hydra-insert "res")    :exit t)
  ("abst"   (my-latex-snippet-hydra-insert "abst")   :exit t)
  ("ded"    (my-latex-snippet-hydra-insert "ded")    :exit t)
  ("agr"    (my-latex-snippet-hydra-insert "agr")    :exit t)
  ("eqr"    (my-latex-snippet-hydra-insert "eqref")  :exit t)

  ;; Texto y Variaciones
  ("tx"     (my-latex-snippet-hydra-insert "tx")     :exit t)
  ("ol"     (my-latex-snippet-hydra-insert "ol")     :exit t)
  ("ts"     (my-latex-snippet-hydra-insert "ts")     :exit t)
  ("ht"     (my-latex-snippet-hydra-insert "ht")     :exit t)
  ("na"     (my-latex-snippet-hydra-insert "na")     :exit t)
  ("dsty"   (my-latex-snippet-hydra-insert "dsty")   :exit t)
  ("pmod"   (my-latex-snippet-hydra-insert "pmod")   :exit t)
  ("dfr"    (my-latex-snippet-hydra-insert "dfr")    :exit t)
  ("tfr"    (my-latex-snippet-hydra-insert "tfr")    :exit t)
  ("bmat"   (my-latex-snippet-hydra-insert "bmat")   :exit t)
  ("pmat"   (my-latex-snippet-hydra-insert "pmat")   :exit t)
  ("q"      nil                                      "salir"))

(defun my-latex-snippet-hydra-insert (trigger)
  (interactive)
  (setq my-latex-snippet-hydra-last-trigger trigger)
  (insert trigger)
  (tempel-expand t))

(provide 'my-latex-snippets)
;;; my-latex-snippets.el ends here
