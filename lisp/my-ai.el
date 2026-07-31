;;; my-ai.el --- Inteligencia Artificial e Integración con Antigravity / Gemini -*- lexical-binding: t; -*-

(require 'gptel)
(require 'aidermacs)

(defvar my/gemini-backend nil
  "Instancia del backend de Gemini para GPTel.")

;; ==================================================================
;; --- 1. CONFIGURACIÓN DEL BACKEND GEMINI / ANTIGRAVITY (GPTEL) ---
;; ==================================================================

(defun my/setup-gptel-gemini ()
  "Inicializa el backend oficial de Gemini con modelos válidos."
  (let ((key (or (getenv "GEMINI_API_KEY")
                 (bound-and-true-p gptel-api-key))))
    (when key
      (setq gptel-api-key key)
      (setq my/gemini-backend
            (gptel-make-gemini "Antigravity-Gemini"
              :key key
              :stream t
              :models '(gemini-flash-latest gemini-pro-latest gemini-2.5-flash gemini-1.5-pro)))
      (setq gptel-backend my/gemini-backend)
      (setq gptel-model 'gemini-flash-latest)
      (message "Antigravity/Gemini AI configurado correctamente en GPTel."))))

(with-eval-after-load 'gptel
  (my/setup-gptel-gemini))

;; Si las claves ya estaban cargadas antes de gptel
(when (or (getenv "GEMINI_API_KEY") (bound-and-true-p gptel-api-key))
  (my/setup-gptel-gemini))

;; ==================================================================
;; --- 2. HERRAMIENTAS INTERACTIVAS DE EDICIÓN ASISTIDA POR IA ---
;; ==================================================================

;;;###autoload
(defun my/ai-chat ()
  "Abre una nueva ventana de búfer dedicada con la interfaz interactiva de Antigravity IA."
  (interactive)
  (let* ((name (generate-new-buffer-name "*Antigravity-IA*"))
         (buf (gptel name)))
    (pop-to-buffer buf)
    (goto-char (point-max))
    (message "🤖 Búfer Antigravity-IA listo. Escribe tu consulta y presiona C-c RET (o C-c g)")))

;;;###autoload
(defun my/ai-cli ()
  "Abre una ventana de terminal vterm ejecutando el comando CLI de Antigravity."
  (interactive)
  (let ((buf (generate-new-buffer-name "*Antigravity-CLI*")))
    (vterm buf)
    (vterm-send-string "antigravity\n")))

;;;###autoload
(defun my/ai-refactor-region (prompt)
  "Envía la región seleccionada a Antigravity Gemini para refactorizar en vivo.
PROMPT es la instrucción del usuario."
  (interactive "sInstrucción de refactorización: ")
  (let ((sys-prompt (if (string= prompt "")
                        "Refactoriza y optimiza este código mantenido limpio y profesional."
                      prompt)))
    (setq-local gptel-system-prompt (concat "Eres Antigravity, un asistente experto de programación y LaTeX en Emacs. " sys-prompt))
    (call-interactively #'gptel-send)))

;;;###autoload
(defun my/ai-explain-region ()
  "Explica el código o fragmento seleccionado abriendo una respuesta de Antigravity."
  (interactive)
  (setq-local gptel-system-prompt "Explica de forma clara, concisa y estructurada el código, fórmula LaTeX o mensaje de error seleccionado.")
  (call-interactively #'gptel-send))

;;;###autoload
(defun my/ai-switch-model ()
  "Permite cambiar interactivamente el modelo de Antigravity Gemini."
  (interactive)
  (let* ((models '("gemini-flash-latest" "gemini-pro-latest" "gemini-2.5-flash" "gemini-1.5-pro"))
         (selected (completing-read "Selecciona Modelo Gemini: " models nil t)))
    (when (not (string-empty-p selected))
      (setq gptel-model (intern selected))
      (message "🚀 Modelo de Antigravity cambiado a: %s" selected))))

;;;###autoload
(defun my/ai-explain-last-terminal-error ()
  "Captura el log de la terminal activa vterm y solicita un diagnóstico de Antigravity."
  (interactive)
  (let ((term-buf (or (get-buffer "*vterm*")
                      (car (cl-remove-if-not (lambda (b) (string-prefix-p "*vterm" (buffer-name b))) (buffer-list))))))
    (if term-buf
        (let ((logs (with-current-buffer term-buf
                      (buffer-substring-no-properties (max (point-min) (- (point-max) 2500)) (point-max)))))
          (let ((chat-buf (gptel (generate-new-buffer-name "*Antigravity-Error-Analysis*"))))
            (pop-to-buffer chat-buf)
            (insert (format "### ⚠️ Análisis de Error de Terminal\n```text\n%s\n```\n\nAnaliza este log de error de terminal y proporciona el diagnóstico exacto y los comandos para corregirlo:\n\n" logs))
            (gptel-send)))
      (message "⚠️ No hay ninguna ventana de terminal vterm activa."))))

;; ==================================================================
;; --- 3. CONFIGURACIÓN DEL AGENTE AIDERMACS ---
;; ==================================================================

(use-package aidermacs
  :ensure nil
  :custom
  (aidermacs-default-model "deepseek/deepseek-chat")
  (aidermacs-use-helm nil)
  (aidermacs-default-chat-mode 'code)
  :config
  (setq aidermacs-extra-args '("--no-auto-commits" "--no-gitignore" "--yes")))

(provide 'my-ai)
;;; my-ai.el ends here
