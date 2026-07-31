;;; my-packages.el --- Gestor de descargas -*- lexical-binding: t; -*-

(require 'package)
(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                         ("org"    . "https://orgmode.org/elpa/")
                         ("elpa"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

(defvar my/packages
  '(modus-themes doom-modeline nerd-icons aggressive-indent which-key gptel
    evil evil-collection evil-surround evil-mc general rainbow-delimiters
    vertico consult marginalia orderless corfu nerd-icons-corfu cape tempel 
    projectile magit auctex reftex eglot diff-hl citar undo-fu
    exec-path-from-shell vterm goggles embark embark-consult citar-embark
    highlight-parentheses julia-mode julia-repl vterm-toggle ace-window
    minions avy hl-todo expand-region drag-stuff wgrep evil-tex jinx
     org-modern calfw calfw-org markdown-mode gcmh harpoon multisession
     aidermacs)
  "Lista de paquetes a instalar.")

(dolist (pkg my/packages)
  (unless (package-installed-p pkg)
    (unless (package-archive-contents)
      (package-refresh-contents))
    (package-install pkg)))

(provide 'my-packages)
;;; my-packages.el ends here
