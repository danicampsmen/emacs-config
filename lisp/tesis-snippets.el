;;; tesis-snippets.el --- Snippets específicos para la tesis de Geometría Compleja -*- lexical-binding: t; -*-

;; ------------------------------------------------------------------
;; Este archivo contiene snippets Tempel especializados para
;; Geometría Compleja y Variedades de Kähler.
;; Se carga condicionalmente cuando el proyecto actual es la tesis.
;; ------------------------------------------------------------------

(defvar tesis-complex-geometry-snippets nil
  "Snippets Tempel para Geometría Compleja.")

;; ------------------------------------------------------------------
;; --- 1. ESTRUCTURAS CASI-COMPLEJAS ---
;; ------------------------------------------------------------------
(setq tesis-complex-geometry-snippets
      '(
        ;; --- Variedades casi-complejas ---
        (ac   . ("\\symcal{A}^{" (p "p,q") "}"))               ;; (p,q)-formas
        (acf  . ("\\symcal{A}^{\\bullet}_{\\Complex}"))          ;; álgebra de formas complejas
        (zco  . ("\\Complex"))                                    ;; ℂ
        (jop  . ("J"))                                            ;; estructura casi-compleja
        (nij  . ("N_{J}"))                                        ;; tensor de Nijenhuis
        (t10  . ("T^{1,0}M"))                                    ;; fibrado holomorfo tangente
        (t01  . ("T^{0,1}M"))                                    ;; fibrado antiholomorfo tangente

        ;; --- Cohomología de Dolbeault ---
        (dolb . ("H_{\\overline{\\partial}}^{p,q}(X)"))
        (dolr . ("H^{p,q}_{\\overline{\\partial}}(X)"))           ;; alias
        (betti . ("b_{" (p "k") "}"))                             ;; números de Betti
        (hodge-d . ("H^{k}_{dR}(X)"))                             ;; cohomología de de Rham

        ;; --- Métricas de Kähler ---
        (kahm  . ("\\omega = \\frac{i}{2} \\sum_{i,j} h_{i\\overline{j}} dz^{i} \\wedge d\\overline{z}^{j}"))
        (ric   . ("\\operatorname{Ric}(\\omega)"))               ;; curvatura de Ricci
        (ricf  . ("\\rho = \\operatorname{Ric}(\\omega)"))
        (kahpot . ("\\omega = i \\partial \\overline{\\partial} \\phi")) ;; potencial de Kähler

        ;; --- Operadores ---
        (dpart . ("\\partial"))                                    ;; ∂
        (dbarr . ("\\overline{\\partial}"))                        ;; ∂̄
        (lef   . ("L(\\alpha) = \\omega \\wedge \\alpha"))        ;; operador de Lefschetz
        (lefs  . ("\\Lambda"))                                     ;; adjunto de Lefschetz
        (lald  . ("\\Delta_{\\overline{\\partial}}"))             ;; Laplaciano de Dolbeault

        ;; --- Fibrados y haces ---
        (canb  . ("K_{X}"))                                       ;; fibrado canónico
        (canbf . ("\\omega_{X}"))                                  ;; haz canónico
        (holsec . ("H^{0}(X, \\symcal{O}(D))"))                  ;; secciones holomorfas
        (divcl . ("\\operatorname{Div}(X)"))                      ;; divisores

        ;; --- Dualidad de Serre y Kodaira ---
        (serre . ("H^{p,q}(X) \\cong H^{n-p,n-q}(X)^{*}"))
        (kodv  . ("\\operatorname{kod}(X)"))                      ;; dimensión de Kodaira

        ;; --- Variedades de Calabi-Yau ---
        (cy    . ("c_{1}(X) = 0"))                                ;; primera clase de Chern nula
        (calabi . ("\\operatorname{Hol}(X) \\subseteq SU(n)"))
        ))

;; ------------------------------------------------------------------
;; --- 2. INTEGRACIÓN CON TEMPEL ---
;; ------------------------------------------------------------------
(defun tesis-complex-geometry-tempel-templates ()
  "Devuelve snippets de Geometría Compleja si estamos en la tesis."
  (when (and (derived-mode-p 'latex-mode 'LaTeX-mode)
             (tesis-project-p))
    tesis-complex-geometry-snippets))

(defun tesis-project-p ()
  "Devuelve t si el proyecto actual parece ser la tesis de Geometría Compleja."
  (when-let ((root (ignore-errors (projectile-project-root))))
    (or (string-match-p "Variedades.*Complejas" root)
        (string-match-p "Tesis" root)
        (string-match-p "Monografia" root)
        (string-match-p "geometria.*compleja" root)
        (string-match-p "kahler" root)
        (string-match-p "Geometria-Compleja" root))))

(with-eval-after-load 'tempel
  (add-to-list 'tempel-template-sources 'tesis-complex-geometry-tempel-templates))

(provide 'tesis-snippets)
