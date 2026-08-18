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

(require 'subr-x) ; Asegura que string-trim funcione

;; ==================================================================
;; --- 0. PREVENIR PLEGADO DENTRO DE COMENTARIOS (SÚPER BLINDADO) ---
;; ==================================================================

(ignore-errors (advice-remove 'TeX-fold-make-overlay #'my/tex-fold-ignore-comments-advice))

(defun my/tex-fold-hide-item-advice (orig-fun ov &rest args)
  "Evita que AUCTeX oculte (pliegue) código comentado haciéndolo transparente."
  (apply orig-fun ov args)
  (let ((start (overlay-start ov)))
    (when (and start (nth 4 (syntax-ppss start)))
      (overlay-put ov 'display nil))))

(advice-add 'TeX-fold-hide-item :around #'my/tex-fold-hide-item-advice)

;; ==================================================================
;; --- 1. LÓGICA DE COLORES Y EXTRACCIÓN DE TÍTULOS ---
;; ==================================================================

(defconst my/latex-list-face '(:foreground "#98be65" :weight bold))

(defun my/latex-get-env-face (env)
  (let ((env-name (downcase (or env ""))))
    (cond 
     ((string-match-p "theorem\\|corollary\\|lemma\\|proposition\\|afirmacion\\|claim" env-name) 
      '(:foreground "#82aaff" :weight bold))
     ((string-match-p "definition\\|notation\\|objective\\|objetive\\|notabox\\|controlbox" env-name) 
      '(:foreground "#e5c07b" :weight bold))
     ((string-match-p "warning\\|attention\\|nota\\|warningbox\\|counterexample" env-name) 
      '(:foreground "#ff5370" :weight bold))
     ((string-match-p "proof\\|solution\\|remark\\|commentary\\|pruebaafirmacion" env-name) 
      '(:foreground "#a6accd" :slant italic :weight bold))
     ((string-match-p "matrix\\|equation\\|align\\|conditions\\|caso\\|condicion" env-name) 
      '(:foreground "#89ddff" :slant italic))
     ((string-match-p "enumerate\\|itemize\\|description\\|enuthm" env-name) 
      '(:foreground "#c3e88d" :weight bold))
     ((string-match-p "pseudocodigo\\|pythonlib\\|pythonexec\\|pythoncode\\|verbatim\\|minted" env-name) 
      '(:foreground "#50c878" :weight bold))
     (t '(:foreground "#676e95" :weight bold)))))

(defun my/merge-face (text new-face)
  (let ((str (copy-sequence (or text ""))))
    (add-face-text-property 0 (length str) new-face t str)
    str))

(defun my/latex-get-env-title (env)
  (let ((env-safe (or env "")))
    (save-excursion
      (condition-case nil
          (when (search-forward "}" (line-end-position) t)
            (skip-chars-forward " \t\n")
            (cond
             ((string-match-p "mini\\|maxi" env-safe)
              (while (looking-at "\\(?:|[^|]+|\\|\\[[^]]+\\]\\|<[^>]+>\\)")
                (forward-sexp)
                (skip-chars-forward " \t\n"))
              (let (var func result)
                (when (looking-at "{")
                  (let ((s (1+ (point)))) (forward-sexp) (setq var (string-trim (buffer-substring-no-properties s (1- (point))))))
                  (skip-chars-forward " \t\n")
                  (when (looking-at "{")
                    (let ((s (1+ (point)))) (forward-sexp) (setq func (string-trim (buffer-substring-no-properties s (1- (point))))))
                    (skip-chars-forward " \t\n")
                    (when (looking-at "{")
                      (forward-sexp)
                      (skip-chars-forward " \t\n")
                      (when (looking-at "{")
                        (let ((s (1+ (point)))) (forward-sexp) (setq result (string-trim (buffer-substring-no-properties s (1- (point))))))))))
                (let* ((r-str (if (and result (not (string-empty-p result))) (concat result " | ") ""))
                       (v-str (if (and var (not (string-empty-p var))) (concat var " : ") ""))
                       (f-str (if (and func (not (string-empty-p func))) func "f(x)")))
                  (format "%s%s%s" r-str v-str f-str))))
             ((string-match-p "caso\\|condicion\\|pseudocodigo\\|pythonlib" env-safe)
              (when (looking-at "{")
                (let ((s (1+ (point))))
                  (forward-sexp)
                  (string-trim (buffer-substring-no-properties s (1- (point)))))))
             ((looking-at "\\[")
              (let ((s (1+ (point))))
                (forward-sexp)
                (string-trim (buffer-substring-no-properties s (1- (point))))))))
        (error nil)))))

;; ==================================================================
;; --- 2. FORMATEADORES DE PLEGADO (TEX-FOLD) ---
;; ==================================================================

(defun my/fold-todo-format (text &rest _args)
  (my/merge-face (format " 🛑 TODO: %s " (or text "")) '(:background "#ff6c6b" :foreground "#ffffff" :weight bold)))

(defun my/fold-fixme-format (text &rest _args)
  (my/merge-face (format " 🛠️ FIXME: %s " (or text "")) '(:background "#ff0000" :foreground "#ffffff" :weight bold)))

(defun my/fold-debug-format (text &rest _args)
  (my/merge-face (format " 🐞 DEBUG: %s " (or text "")) '(:background "#a020f0" :foreground "#ffffff" :weight bold)))

(defun my/fold-note-format (text &rest _args)
  (my/merge-face (format " ℹ️ NOTE: %s " (or text "")) '(:background "#0088bb" :foreground "#ffffff" :weight bold)))

(defun my/fold-deftech-format (text &rest _args)
  (my/merge-face (or text "") '(:foreground "#ff80df" :weight bold :underline t)))

(defun my/fold-usual-format (text &rest _args)
  (my/merge-face (or text "") '(:foreground "#ffcb6b" :weight bold)))

(defun my/fold-highlightgreen-format (text &rest _args)
  (my/merge-face (or text "") '(:foreground "#98be65" :weight bold)))
  
(defvar my/latex-macros-word nil "Caché de regex para palabras.")
(defvar my/latex-macros-sym nil "Caché de regex para símbolos.")

(defconst my/unicode-superscripts
  '(("0" . "⁰") ("1" . "¹") ("2" . "²") ("3" . "³") ("4" . "⁴") ("5" . "⁵") ("6" . "⁶") ("7" . "⁷") ("8" . "⁸") ("9" . "⁹")
    ("+" . "⁺") ("-" . "⁻") ("=" . "⁼") ("(" . "⁽") (")" . "⁾")
    ("a" . "ᵃ") ("b" . "ᵇ") ("c" . "ᶜ") ("d" . "ᵈ") ("e" . "ᵉ") ("f" . "ᶠ") ("g" . "ᵍ") ("h" . "ʰ") ("i" . "ⁱ") ("j" . "ʲ")
    ("k" . "ᵏ") ("l" . "ˡ") ("m" . "ᵐ") ("n" . "ⁿ") ("o" . "ᵒ") ("p" . "ᵖ") ("r" . "ʳ") ("s" . "ˢ") ("t" . "ᵗ") ("u" . "ᵘ")
    ("v" . "ᵛ") ("w" . "ʷ") ("x" . "ˣ") ("y" . "ʸ") ("z" . "ᶻ")
    ("T" . "ᵀ") ("*" . "⃰" )))

(defconst my/unicode-subscripts
  '(("0" . "₀") ("1" . "₁") ("2" . "₂") ("3" . "₃") ("4" . "₄") ("5" . "₅") ("6" . "₆") ("7" . "₇") ("8" . "₈") ("9" . "₉")
    ("+" . "₊") ("-" . "₋") ("=" . "₌") ("(" . "₍") (")" . "₎")
    ("a" . "ₐ") ("e" . "ₑ") ("h" . "ₕ") ("i" . "ᵢ") ("j" . "ⱼ") ("k" . "ₖ") ("l" . "ₗ") ("m" . "ₘ") ("n" . "ₙ") ("o" . "ₒ")
    ("p" . "ₚ") ("r" . "ᵣ") ("s" . "ₛ") ("t" . "ₜ") ("u" . "ᵤ") ("v" . "ᵥ") ("x" . "ₓ")))

(defun my/translate-to-scripts (text type)
  (save-match-data
    (let ((map (if (eq type 'super) my/unicode-superscripts my/unicode-subscripts)))
      (mapconcat (lambda (c)
                   (let* ((char (char-to-string c))
                          (match (assoc char map)))
                     (if match (cdr match) char)))
                 (or text "") ""))))

(defun my/latex-clean-folded-text (text)
  (if (not (stringp text))
      ""
    (unless my/latex-macros-word
      (let (words syms)
        (dolist (pair my/latex-prettify-symbols-alist)
          (if (string-match-p "[A-Za-z]$" (car pair))
              (push (car pair) words)
            (push (car pair) syms)))
        (setq my/latex-macros-word (if words (concat "\\(" (regexp-opt words) "\\)\\b") nil)
              my/latex-macros-sym  (if syms (regexp-opt syms) nil))))

    (let ((str (substring-no-properties text)))
      (setq str (replace-regexp-in-string "\\\\[][()]" "" str))

      (when my/latex-macros-word
        (setq str (replace-regexp-in-string
                   my/latex-macros-word
                   (lambda (m)
                     (let ((match (assoc m my/latex-prettify-symbols-alist)))
                       (if match (char-to-string (cdr match)) m)))
                   str t t)))

      (when my/latex-macros-sym
        (setq str (replace-regexp-in-string
                   my/latex-macros-sym
                   (lambda (m)
                     (let ((match (assoc m my/latex-prettify-symbols-alist)))
                       (if match (char-to-string (cdr match)) m)))
                   str t t)))

      (setq str (replace-regexp-in-string
                 "\\([_^]\\)\\(?:{\\([^}]+\\)}\\|\\([^{ \\t\\n\\\\]+\\)\\)"
                 (lambda (m)
                   (if (string-match "\\([_^]\\)\\(?:{\\([^}]+\\)}\\|\\([^{ \\t\\n\\\\]+\\)\\)" m)
                       (let* ((type-char (match-string 1 m))
                              (content (or (match-string 2 m) (match-string 3 m) ""))
                              (type (if (string= type-char "^") 'super 'sub)))
                         (my/translate-to-scripts content type))
                     m))
                 str t t))

      (setq str (replace-regexp-in-string "\\\\[ ,;]\\|  +" " " str))
      (string-trim str))))

(defun my/latex-fold-begin-format (env &rest _args)
  (let* ((env-str (capitalize (or env "env")))
         (face (my/latex-get-env-face env))
         (title (my/latex-get-env-title env))
         (base-str (my/merge-face (format "--- %s" env-str) face)))
    (if (and title (not (string-empty-p (string-trim title))))
        (concat base-str (my/merge-face (format " [%s] ---" (my/latex-clean-folded-text title)) face))
      (concat base-str (my/merge-face " ---" face)))))

(defun my/latex-fold-end-format (env &rest _args)
  (my/merge-face (format "--- Fin de %s ---" (capitalize (or env "env")))
                 (my/latex-get-env-face env)))

(defun my/fold-item-format (&rest _args) (my/merge-face "➣" my/latex-list-face))
(defun my/fold-textbf-format (text &rest _args) (my/merge-face (or text "") '(:foreground "#ffffff" :weight bold)))
(defun my/fold-textit-format (text &rest _args) (my/merge-face (or text "") '(:slant italic)))
(defun my/fold-textcolor-red-format (c text &rest _args)
  (if (equal c "red")
      (my/merge-face (or text "") '(:foreground "#ff6c6b" :weight bold))
    (my/merge-face (format "{%s}" (or text "")) '(:foreground "#aaaaaa"))))

(defun my/fold-norm-format (text &rest _) (my/merge-face (format "‖ %s ‖" (my/latex-clean-folded-text (or text ""))) 'font-latex-math-face))
(defun my/fold-abs-format (text &rest _) (my/merge-face (format "| %s |" (my/latex-clean-folded-text (or text ""))) 'font-latex-math-face))
(defun my/fold-interno-format (t1 t2 &rest _) (my/merge-face (format "〈 %s , %s 〉" (my/latex-clean-folded-text (or t1 "")) (my/latex-clean-folded-text (or t2 ""))) 'font-latex-math-face))
(defun my/fold-math-accent-format (accent text) (my/merge-face (format "%s%s" accent (my/latex-clean-folded-text (or text ""))) 'font-latex-math-face))

(defun my/fold-overline-format (t1 &rest _) (my/fold-math-accent-format "‾‾" t1))
(defun my/fold-hat-format (t1 &rest _)      (my/fold-math-accent-format "ˆ" t1))
(defun my/fold-tilde-format (t1 &rest _)    (my/fold-math-accent-format "˜" t1))
(defun my/fold-bar-format (t1 &rest _)      (my/fold-math-accent-format "‾" t1))
(defun my/fold-check-format (t1 &rest _)    (my/fold-math-accent-format "ˇ" t1))

(defun my/fold-operatorname-format (text &rest _) (my/merge-face (my/latex-clean-folded-text (or text "")) '(:foreground "#89ddff" :weight normal :slant normal)))
(defun my/fold-index-format (text &rest _)
  (let ((clean (my/latex-clean-folded-text (or text ""))))
    (setq clean (replace-regexp-in-string "\\\\([ \t]*\\|[ \t]*\\\\)" "" clean))
    (my/merge-face (format "[📑 %s]" clean) '(:foreground "#c792ea" :slant italic :weight light))))

(defface my-fold-part-face '((t :foreground "#d3869b" :weight bold :height 1.6)) "Cara partes.")
(defface my-fold-chapter-face '((t :foreground "#d3869b" :weight bold :height 1.5)) "Cara capítulos.")
(defface my-fold-section-face '((t :foreground "#82aaff" :weight bold :height 1.3)) "Cara secciones.")
(defface my-fold-subsection-face '((t :foreground "#82aaff" :weight bold :slant italic :height 1.15)) "Cara subsecciones.")

(defun my/fold-part-format (text &rest _args) (my/merge-face (format "❖ %s" (my/latex-clean-folded-text (or text ""))) 'my-fold-part-face))
(defun my/fold-chapter-format (text &rest _args) (my/merge-face (format "¶ %s" (my/latex-clean-folded-text (or text ""))) 'my-fold-chapter-face))
(defun my/fold-section-format (text &rest _args) (my/merge-face (format "§ %s" (my/latex-clean-folded-text (or text ""))) 'my-fold-section-face))
(defun my/fold-subsection-format (text &rest _args) (my/merge-face (format "§§ %s" (my/latex-clean-folded-text (or text ""))) 'my-fold-subsection-face))
(defun my/fold-subsubsection-format (text &rest _args) (my/merge-face (format "§§§ %s" (my/latex-clean-folded-text (or text ""))) '(:foreground "#82aaff")))

(defun my/fold-map-format (&rest _args)
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
                  (my/merge-face (format "%s: %s → %s" n d c) 'font-latex-math-face)
                (let* ((w-n (string-width n)) (w-d (string-width d)) (w-c (string-width c))
                       (w-v (string-width v)) (w-e (string-width e-full))
                       (source-col (save-excursion (re-search-backward "\\\\map\\b") (current-column)))
                       (indent-size (max 0 (+ source-col w-n 2)))
                       (indent-spaces (make-string indent-size ?\s))
                       (max-w1 (max w-d w-v)) (diff-d (max 0 (- max-w1 w-d)))
                       (pad-l-d (make-string (/ diff-d 2) ?\s)) (pad-r-d (make-string (- diff-d (/ diff-d 2)) ?\s))
                       (diff-v (max 0 (- max-w1 w-v))) (pad-l-v (make-string (/ diff-v 2) ?\s))
                       (pad-r-v (make-string (- diff-v (/ diff-v 2)) ?\s))
                       (max-w2 (max w-c w-e)) (diff-c (max 0 (- max-w2 w-c))) (pad-l-c (make-string (/ diff-c 2) ?\s))
                       (diff-e (max 0 (- max-w2 w-e))) (pad-l-e (make-string (/ diff-e 2) ?\s)))
                  (my/merge-face (format "%s: %s%s%s → %s%s\n%s%s%s%s ↦ %s%s"
                                         n pad-l-d d pad-r-d pad-l-c c indent-spaces pad-l-v v pad-r-v pad-l-e e-full)
                                 'font-latex-math-face))))))
      "[Error: No se pudo analizar \\map]")))

(with-eval-after-load 'font-latex
  (let ((unified-color "#d3869b") (unified-height 1.1) (unified-weight 'bold))
    (dolist (face '(font-latex-sectioning-1-face font-latex-sectioning-2-face 
                    font-latex-sectioning-3-face font-latex-sectioning-4-face font-latex-sectioning-5-face)) 
      (set-face-attribute face nil :foreground unified-color :weight unified-weight :height unified-height)))
   ;; Usar la fuente default (Iosevka Term, monoespaciada) para matemáticas
   ;; para mantener la alineación visual de & en entornos align*
   (set-face-attribute 'font-latex-math-face nil :family "Iosevka Term" :weight 'light)
   (set-face-attribute 'font-latex-script-char-face nil :family "Iosevka Term" :weight 'light))

(with-eval-after-load 'tex-fold
  (set-face-attribute 'TeX-fold-folded-face nil :foreground "#a6accd" :weight 'normal))

;; ==================================================================
;; --- 3. DICCIONARIO UNICODE ---
;; ==================================================================
(defconst my/latex-prettify-symbols-alist
  '(("\\left." . ?\s) ("\\right|" . ?|) ("\\qquad" . ?\u2003) ("\\item" . ?•) ("\\qed" . ?∎) ("\\blacksquare" . ?∎)
    ("\\square" . ?□) ("\\S" . ?§) ("\\P" . ?¶) ("\\ldots" . ?…) ("\\dots" . ?…) ("\\cdots" . ?⋯)
    ("\\," . ?_ ) ("\\quad" . ?⎵) ("\\prime" . ?′) ("\\not=" . ?≠) ("\\neq" . ?≠) ("\\in" . ?∈) ("\\notin" . ?∉)
    ("\\ni" . ?∋) ("\\subset" . ?⊂) ("\\subseteq" . ?⊆) ("\\sqsubseteq" . ?⊑) ("\\sqsupseteq" . ?⊒) ("\\cup" . ?∪)
    ("\\cap" . ?∩) ("\\forall" . ?∀) ("\\exists" . ?∃) ("\\nexists" . ?∄) ("\\land" . ?∧) ("\\wedge" . ?∧)
    ("\\lor" . ?∨) ("\\vee" . ?∨) ("\\neg" . ?¬) ("\\emptyset" . ?∅) ("\\setminus" . ?∖) ("\\uplus" . ?⊎)
    ("\\subsetneq" . ?⊊) ("\\supsetneq" . ?⊋) ("\\nsubseteq" . ?⊈) ("\\nsupseteq" . ?⊉) ("\\vdash" . ?⊢) ("\\dashv" . ?⊣)
    ("\\models" . ?⊨) ("\\Vdash" . ?⊩) ("\\nvdash" . ?⊬) ("\\nvDash" . ?⊭) ("\\bigwedge" . ?⋀) ("\\bigvee" . ?⋁) ("\\bigcap" . ?⋂)
    ("\\bigcup" . ?⋃) ("\\sum" . ?∑) ("\\prod" . ?∏) ("\\coprod" . ?∐) ("\\amalg" . ?∐) ("\\circ" . ?∘) ("\\bullet" . ?∙) ("\\bigbullet" . ?●)
    ("\\otimes" . ?⊗) ("\\oplus" . ?⊕) ("\\boxplus" . ?⊞) ("\\boxminus" . ?⊟) ("\\boxtimes" . ?⊠) ("\\boxdot" . ?⊡)
    ("\\times" . ?×) ("\\cdot" . ?⋅) ("\\star" . ?⋆) ("\\ast" . ?∗) ("\\pm" . ?±) ("\\mp" . ?∓) ("\\Join" . ?⋈)
    ("\\leq" . ?≤) ("\\le" . ?≤) ("\\geq" . ?≥) ("\\ge" . ?≥) ("\\equiv" . ?≡) ("\\sim" . ?∼) ("\\approx" . ?≈) ("\\cong" . ?≅)
    ("\\simeq" . ?≃) ("\\propto" . ?∝) ("\\Rightarrow" . ?⇒) ("\\Longrightarrow" . ?⟹) ("\\Longleftarrow" . ?⟸)
    ("\\Longleftrightarrow" . ?⟺) ("\\longrightarrow" . ?⟶) ("\\rightarrow" . ?→) ("\\to" . ?→) ("\\leftarrow" . ?←)
    ("\\gets" . ?←) ("\\mapsto" . ?↦) ("\\implies" . ?⟹) ("\\iff" . ?⟺) ("\\hookrightarrow" . ?↪) ("\\twoheadrightarrow" . ?↠)
    ("\\rightrightarrows" . ?⇉) ("\\leftleftarrows" . ?⇇) ("\\rightleftarrows" . ?⇄) ("\\leftrightarrows" . ?⇆)
    ("\\leftrightarrow" . ?↔) ("\\longleftrightarrow" . ?⟷) ("\\rightarrowtail" . ?↣) ("\\longmapsto" . ?⟼)
    ("\\leadsto" . ?⇝) ("\\nrightarrow" . ?↛) ("\\nRightarrow" . ?⇏) ("\\uparrow" . ?↑) ("\\downarrow" . ?↓) ("\\updownarrow" . ?↕)
    ("\\infty" . ?∞) ("\\partial" . ?∂) ("\\nabla" . ?∇) ("\\int" . ?∫) ("\\oint" . ?∮) ("\\sqrt" . ?√)
    ("\\perp" . ?⟂) ("\\parallel" . ?∥) ("\\angle" . ?∠) ("\\measuredangle" . ?∡) ("\\triangle" . ?△) ("\\Box" . ?□)
    ("\\diamond" . ?◇) ("\\dagger" . ?†) ("\\top" . ?⊤) ("\\bot" . ?⊥) ("\\Id" . ?𝟙) ("\\Re" . ?ℜ) ("\\Im" . ?ℑ)
    ("\\hbar" . ?ℏ) ("\\ell" . ?ℓ) ("\\wp" . ?℘) ("\\aleph" . ?ℵ) ("\\beth" . ?ℶ) ("\\gimel" . ?ℷ)
    ("\\I" . ?\U0001D540) ("\\A" . ?\U0001D49C) ("\\Cls" . ?\U0001D49E) ("\\R" . ?\U0000211D) ("\\C" . ?\U00002102) ("\\Z" . ?\U00002124) ("\\N" . ?\U00002115) ("\\Q" . ?\U0000211A)
    ("\\symbb{A}" . ?\U0001D538) ("\\symbb{C}" . ?\U00002102) ("\\symbb{D}" . ?\U0001D53B) ("\\symbb{E}" . ?\U0001D53C) ("\\symbb{F}" . ?\U0001D53D) ("\\symbb{G}" . ?\U0001D53E)
    ("\\symbb{H}" . ?\U0000210D) ("\\symbb{I}" . ?\U0001D540) ("\\symbb{K}" . ?\U0001D542) ("\\symbb{N}" . ?\U00002115) ("\\symbb{P}" . ?\U00002119) ("\\symbb{Q}" . ?\U0000211A)
    ("\\symbb{R}" . ?\U0000211D) ("\\symbb{S}" . ?\U0001D54A) ("\\symbb{T}" . ?\U0001D54B) ("\\symbb{V}" . ?\U0001D550) ("\\symbb{Z}" . ?\U00002124)
    ("\\symcal{A}" . ?\U0001D49C) ("\\symcal{B}" . ?\U0000212C) ("\\symcal{C}" . ?\U0001D49E) ("\\symcal{D}" . ?\U0001D49F) ("\\symcal{E}" . ?\U00002130) ("\\symcal{F}" . ?\U00002131)
    ("\\symcal{G}" . ?\U0001D4A2) ("\\symcal{H}" . ?\U0000210B) ("\\symcal{I}" . ?\U00002110) ("\\symcal{J}" . ?\U0001D4A5) ("\\symcal{K}" . ?\U0001D4A6) ("\\symcal{L}" . ?\U00002112)
    ("\\symcal{M}" . ?\U00002133) ("\\symcal{N}" . ?\U0001D4A9) ("\\symcal{O}" . ?\U0001D4AA) ("\\symcal{P}" . ?\U0001D4AB) ("\\symcal{Q}" . ?\U0001D4AC) ("\\symcal{R}" . ?\U0000211B)
    ("\\symcal{S}" . ?\U0001D4AE) ("\\symcal{T}" . ?\U0001D4AF) ("\\symcal{U}" . ?\U0001D4B0) ("\\symcal{V}" . ?\U0001D4B1) ("\\symcal{W}" . ?\U0001D4B2) ("\\symcal{X}" . ?\U0001D4B3)
    ("\\symcal{Y}" . ?\U0001D4B4) ("\\symcal{Z}" . ?\U0001D4B5)
    ("\\alpha" . ?α) ("\\beta" . ?β) ("\\gamma" . ?γ) ("\\delta" . ?δ) ("\\epsilon" . ?ϵ) ("\\varepsilon" . ?ε) ("\\zeta" . ?ζ) ("\\eta" . ?η)
    ("\\theta" . ?θ) ("\\vartheta" . ?ϑ) ("\\iota" . ?ι) ("\\kappa" . ?κ) ("\\lambda" . ?λ) ("\\mu" . ?μ) ("\\nu" . ?ν) ("\\xi" . ?ξ)
    ("\\pi" . ?π) ("\\rho" . ?ρ) ("\\sigma" . ?σ) ("\\tau" . ?τ) ("\\upsilon" . ?υ) ("\\phi" . ?φ) ("\\varphi" . ?φ) ("\\chi" . ?χ)
    ("\\psi" . ?ψ) ("\\omega" . ?ω)
    ("\\Gamma" . ?Γ) ("\\Delta" . ?Δ) ("\\Theta" . ?Θ) ("\\Lambda" . ?Λ) ("\\Xi" . ?Ξ) ("\\Pi" . ?Π) ("\\Sigma" . ?Σ) ("\\Phi" . ?Φ) ("\\Psi" . ?Ψ) ("\\Omega" . ?Ω)
    ("\\symfrak{A}" . ?𝔄) ("\\symfrak{B}" . ?𝔅) ("\\symfrak{C}" . ?ℭ) ("\\symfrak{D}" . ?𝔇) ("\\symfrak{E}" . ?𝔈) ("\\symfrak{F}" . ?𝔉)
    ("\\symfrak{G}" . ?𝔊) ("\\symfrak{H}" . ?ℌ) ("\\symfrak{I}" . ?ℑ) ("\\symfrak{J}" . ?𝔍) ("\\symfrak{K}" . ?𝔎) ("\\symfrak{L}" . ?𝔏)
    ("\\symfrak{M}" . ?𝔐) ("\\symfrak{N}" . ?𝔑) ("\\symfrak{O}" . ?𝔒) ("\\symfrak{P}" . ?𝔓) ("\\symfrak{Q}" . ?𝔔) ("\\symfrak{R}" . ?ℜ)
    ("\\symfrak{S}" . ?𝔖) ("\\symfrak{T}" . ?𝔗) ("\\symfrak{U}" . ?𝔘) ("\\symfrak{V}" . ?𝔙) ("\\symfrak{W}" . ?𝔚) ("\\symfrak{X}" . ?𝔛) ("\\symfrak{Y}" . ?𝔜) ("\\symfrak{Z}" . ?ℨ)
    ("\\symfrak{a}" . ?𝔞) ("\\symfrak{b}" . ?𝔟) ("\\symfrak{c}" . ?𝔠) ("\\symfrak{d}" . ?𝔡) ("\\symfrak{e}" . ?𝔢) ("\\symfrak{f}" . ?𝔣)
    ("\\symfrak{g}" . ?𝔤) ("\\symfrak{h}" . ?𝔥) ("\\symfrak{i}" . ?𝔦) ("\\symfrak{j}" . ?𝔧) ("\\symfrak{k}" . ?𝔨) ("\\symfrak{l}" . ?𝔩)
    ("\\symfrak{m}" . ?𝔪) ("\\symfrak{n}" . ?𝔫) ("\\symfrak{o}" . ?𝔬) ("\\symfrak{p}" . ?𝔭) ("\\symfrak{q}" . ?𝔮) ("\\symfrak{r}" . ?𝔯)
    ("\\symfrak{s}" . ?𝔰) ("\\symfrak{t}" . ?𝔱) ("\\symfrak{u}" . ?𝔲) ("\\symfrak{v}" . ?𝔳) ("\\symfrak{w}" . ?𝔴) ("\\symfrak{x}" . ?𝔵) ("\\symfrak{y}" . ?𝔶) ("\\symfrak{z}" . ?𝔷)
    ("\\langle" . ?⟨ ) ("\\rangle" . ?⟩ ) ("\\left\\langle" . ?⟪) ("\\right\\rangle" . ?⟫)
    ("\\lVert" . ?‖ ) ("\\rVert" . ?‖ ) ("\\left|" . ?│) ("\\right|" . ?│) ("\\big|" . ?│)
    ("\\{" . ?{ ) ("\\}" . ?} ) ("\\left\\{" . ?❴) ("\\right\\}" . ?❵ ) ("\\left[" . ?［ ) ("\\right]" . ?］) ("\\left(" . ?⦅) ("\\right)" . ?⦆)
    ;;; ("\\[" . ?┏) ("\\]" . ?┗)
    ("\\coloneq" . ?\u2254 ) ("\\colon" . ?: ) ("\\therefore" . ?∴ ) ("\\because" . ?∵ )
    ("^2" . ?² ) ("^3" . ?³ ) ("\\diff" . ?\u2146) ("\\E" . ?\u2147) ("\\Imath" . ?\u2148) ("\\syss" . ?\u27FA) ("\\ent" . ?\u21D2)
    ("\\episum" . ?#) ("\\epimult" . ?⋆)))

;; ==================================================================
;; --- 5. VISUAL ZEN MODE (INTERRUPTOR Y FOCUS LINE) ---
;; ==================================================================

(defvar-local my/latex-fold-timer nil)
(defvar-local my/latex--last-unfolded-line-pos nil)

(defun my/latex-unfold-current-line-hook ()
  "Mantiene la línea actual desplegada (raw) y repliega la anterior al salir."
  (when (and my/latex-visual-mode (bound-and-true-p TeX-fold-mode))
    (let ((curr-line-pos (line-beginning-position)))
      ;; Solo ejecutamos la lógica si realmente cambiamos de línea
      (unless (equal curr-line-pos my/latex--last-unfolded-line-pos)
        
        ;; 1. RE-PLEGAR LA LÍNEA ANTERIOR
        (when (and my/latex--last-unfolded-line-pos
                   (< my/latex--last-unfolded-line-pos (point-max)))
          (save-excursion
            (goto-char my/latex--last-unfolded-line-pos)
            (ignore-errors
              ;; AUCTeX escanea la línea y vuelve a colapsar sus macros/entornos
              (TeX-fold-region (line-beginning-position) (line-end-position)))))
        
        ;; 2. ACTUALIZAR EL RASTREADOR DE POSICIÓN
        (setq my/latex--last-unfolded-line-pos curr-line-pos)
        
        ;; 3. DESPLEGAR LA LÍNEA ACTUAL
        (ignore-errors
          (TeX-fold-clearout-region curr-line-pos (line-end-position)))))))

(defun my/latex-fold-visible-region ()
  "Fuerza el coloreado y pliega la porción visible (Timer en segundo plano)."
  (when (and (buffer-live-p (current-buffer))
             (derived-mode-p 'LaTeX-mode)
             (bound-and-true-p TeX-fold-mode))
    (let ((win (get-buffer-window (current-buffer))))
      (when win
        (with-silent-modifications
          (let* ((w-start (or (window-start win) (point-min)))
                 (w-end   (or (window-end win t) (point-max)))
                 (start   (max (point-min) (- w-start 500)))
                 (end     (min (point-max) (+ w-end 500)))
                 (curr-line-start (line-beginning-position))
                 (curr-line-end   (line-end-position)))
            (font-lock-ensure start end)
            (TeX-fold-region start end)
            ;; Garantizar que la línea del cursor siga desplegada tras el barrido general
            (TeX-fold-clearout-region curr-line-start curr-line-end)))))))

(defun my/latex-trigger-idle-fold (&rest _)
  "Recalcula pliegues de la pantalla al editar texto."
  (when my/latex-visual-mode
    (when my/latex-fold-timer
      (cancel-timer my/latex-fold-timer))
    (setq my/latex-fold-timer
          (run-with-idle-timer 1.5 nil #'my/latex-fold-visible-region))))

(defun my/latex-visual-setup ()
  (TeX-add-symbols 
   '("map" t t t t t t) '("inmap" t t t) '("mapchain" t t t t t t t)
   '("chart" t t) '("chartcoords" t t) '("rest" t t) '("transmap" t t)
   '("morf" t t t) '("TODO" t) '("FIXME" t) '("DEBUG" t) '("NOTE" t)
   '("deftech" t) '("usual" t) '("highlightgreen" t)
   '("dependencias" t) '("blueprint" t) '("casobase" t))

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
					
					;; Pasos y estructura EGA (tesis-uni.cls)
					(" (⇒) " ("directstep"))
					(" (⇐) " ("reversestep"))
					(" (⊆) " ("containedstep"))
					(" (⊇) " ("inversecontainedstep"))
					(" ⚠️ " ("viragedangereux"))
					(" ─── * * * ─── " ("egabreak"))
					("[§ {1}]" ("sref"))
					("({1})" ("eref"))
					(" ⚙️ Convención: {1} " ("convencionbox"))

					("📝 {1}" ("caption"))
					("[ 🖼️ {1} ]" ("includegraphics"))
					("[ 🖼️ {2} ]" ("import"))
					(" ↔️ Centrado " ("centering"))

					("Supp" ("Supp"))
					("dim" ("dim"))
					("det" ("det"))
					("ker" ("Ker"))
					("im" ("Im"))
					("Frac" ("Frac"))

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

					(my/fold-map-format ("map"))

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
					(my/latex-fold-end-format ("end"))))
  
  ;; ⚠️ APAGAMOS el revelador automático de AUCTeX, ya que causaba el salto del cursor
  (setq-local TeX-fold-auto-reveal nil) 
  (setq-local TeX-fold-auto t)
  (TeX-fold-mode 1)

  ;; Activamos nuestro propio sistema Line Focus de forma reactiva a cada movimiento
  (add-hook 'post-command-hook #'my/latex-unfold-current-line-hook nil t)
  (add-hook 'after-change-functions #'my/latex-trigger-idle-fold nil t)
  
  (setq prettify-symbols-compose-predicate #'prettify-symbols-default-compose-p)
  (setq-local prettify-symbols-alist my/latex-prettify-symbols-alist)
  (setq-local prettify-symbols-unprettify-at-point 'right-edge)
  (prettify-symbols-mode 1)
  (rainbow-delimiters-mode 1)
  
  (font-lock-flush)
  (font-lock-ensure)
  
  (run-with-timer 0.1 nil (lambda () 
                            (when (and (buffer-live-p (current-buffer))
                                       (derived-mode-p 'LaTeX-mode))
                              (TeX-fold-buffer))))
                              
  (message "✅ Visual Zen Activado: Foco de Línea Simétrico."))

(defface my-latex-math-bracket-face
  '((t :foreground "#555555"))
  "Cara discreta para los delimitadores matemáticos.")

(font-lock-add-keywords 'LaTeX-mode
  '(("\\\\(\\|\\\\)\\|\\\\\\[\\|\\\\\\]" 0 'my-latex-math-bracket-face prepend)))

(defun my/latex-visual-teardown ()
  (when (bound-and-true-p TeX-fold-mode)
    (TeX-fold-clearout-buffer)
    (TeX-fold-mode -1))
  (remove-hook 'post-command-hook #'my/latex-unfold-current-line-hook t)
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

(require 'evil)

(with-eval-after-load 'evil-tex
  (define-key evil-tex-mode-map (kbd "M") nil)
  (evil-define-key 'normal evil-tex-mode-map
    (kbd "ts") evil-tex-toggle-map
    (kbd "[[") 'evil-tex-goto-section-boundary-back
    (kbd "]]") 'evil-tex-goto-section-boundary-forward)
  (define-key evil-tex-mode-map (kbd "s") nil))
(add-hook 'LaTeX-mode-hook #'evil-tex-mode)

(add-hook 'LaTeX-mode-hook #'my/latex-visual-mode)

(defun my/latex-fold-after-snippet ()
  "Pliega de forma segura después de expandir un snippet sin lanzar errores de argumentos."
  (when (derived-mode-p 'LaTeX-mode)
    (my/latex-fold-visible-region)))

(add-hook 'tempel-done-hook #'my/latex-fold-after-snippet)

(provide 'my-latex-visuals)
