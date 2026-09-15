;;; my-ai.el --- Integración Total de Google Antigravity en Emacs -*- lexical-binding: t; -*-

;; ====================================================================
;;  GOOGLE ANTIGRAVITY FOR EMACS
;;  Controlador maestro para CLI (agy), Agent REPL (vterm), Inline Edits,
;;  Diff Previews, Diagnósticos, Contexto Dired/Magit/LaTeX y Transient UI.
;; ====================================================================

(require 'cl-lib)
(require 'transient)
(require 'gptel nil t)
(require 'aidermacs nil t)
(require 'vterm nil t)

;; ====================================================================
;; --- 1. CONFIGURACIÓN Y ESTADO DINÁMICO DE ANTIGRAVITY ---
;; ====================================================================

(defgroup my-antigravity nil
  "Opciones de integración para Google Antigravity en Emacs."
  :group 'tools
  :prefix "my/antigravity-")

(defcustom my/antigravity-executable
  (or (executable-find "agy")
      (expand-file-name ".local/bin/agy" (getenv "HOME"))
      "agy")
  "Ruta al ejecutable CLI de Antigravity (`agy`)."
  :type 'string
  :group 'my-antigravity)

(defcustom my/antigravity-default-model "gemini-3.8-flash-high"
  "Modelo por defecto para las sesiones de Antigravity."
  :type 'string
  :group 'my-antigravity)

(defvar my/antigravity-model "gemini-3.8-flash-high"
  "Modelo activo actualmente para Antigravity.")

(defconst my/antigravity-fallback-models
  '(("gemini-3.8-flash-high"     . "Gemini 3.8 Flash (High)")
    ("gemini-3.8-flash-medium"   . "Gemini 3.8 Flash (Medium)")
    ("gemini-3.8-flash-low"      . "Gemini 3.8 Flash (Low)")
    ("gemini-3.7-flash-high"     . "Gemini 3.7 Flash (High)")
    ("gemini-3.7-flash-medium"   . "Gemini 3.7 Flash (Medium)")
    ("gemini-3.7-flash-low"      . "Gemini 3.7 Flash (Low)")
    ("gemini-3.6-flash-high"     . "Gemini 3.6 Flash (High)")
    ("gemini-3.6-flash-medium"   . "Gemini 3.6 Flash (Medium)")
    ("gemini-3.6-flash-low"      . "Gemini 3.6 Flash (Low)")
    ("gemini-3.1-pro-high"       . "Gemini 3.1 Pro (High)")
    ("gemini-3.1-pro-low"        . "Gemini 3.1 Pro (Low)")
    ("claude-sonnet-4-6"         . "Claude Sonnet 4.6 (Thinking)")
    ("claude-opus-4-6-thinking"  . "Claude Opus 4.6 (Thinking)")
    ("gpt-oss-120b-medium"       . "GPT-OSS 120B (Medium)"))
  "Lista de respaldo de modelos para cuando `agy models` falle o no responda.")

(defvar my/antigravity--cached-models nil
  "Caché en memoria de modelos disponibles en formato alist (ID . DISPLAY-NAME).")

(defvar my/antigravity--models-cache-time 0
  "Marca temporal (epoch) de la última consulta a `agy models`.")

(defun my/antigravity-get-models (&optional refresh)
  "Obtiene dinámicamente los modelos llamando a `agy models`.
Usa caché en memoria durante 300 segundos a menos que REFRESH sea no-nil."
  (let ((now (float-time)))
    (if (and my/antigravity--cached-models
             (not refresh)
             (< (- now my/antigravity--models-cache-time) 300))
        my/antigravity--cached-models
      (let ((output (ignore-errors
                      (with-temp-buffer
                        (call-process my/antigravity-executable nil t nil "models")
                        (buffer-string))))
            (models nil))
        (if (and output (not (string-empty-p output)))
            (dolist (line (split-string output "\n" t))
              (let ((clean (string-trim line)))
                (unless (or (string-empty-p clean)
                            (string-prefix-p "Fetching" clean))
                  (if (string-match "^\\([a-zA-Z0-9._-]+\\)[ \t]+\\(.*\\)$" clean)
                      (push (cons (match-string 1 clean) (string-trim (match-string 2 clean))) models)
                    (push (cons clean clean) models)))))
          (setq models my/antigravity-fallback-models))
        (setq my/antigravity--cached-models (if models (nreverse models) my/antigravity-fallback-models))
        (setq my/antigravity--models-cache-time now)
        my/antigravity--cached-models))))

(defvar my/antigravity-available-models
  (mapcar #'car my/antigravity-fallback-models)
  "Lista de IDs de modelos soportados por Antigravity CLI.")

(defvar my/antigravity-effort "high"
  "Nivel de razonamiento (effort): 'low', 'medium', o 'high'.")

(defvar my/antigravity-auto-approve nil
  "Si es t, añade `--dangerously-skip-permissions` para auto-aprobar acciones.")

(defvar my/antigravity-sandbox nil
  "Si es t, ejecuta Antigravity en modo `--sandbox`.")

(defvar my/antigravity-last-process nil
  "Proceso asíncrono actual en ejecución de Antigravity.")

;; ====================================================================
;; --- 2. GENERADOR DE COMANDOS Y PROYECTOS ---
;; ====================================================================

(defun my/antigravity-project-root ()
  "Obtiene la raíz del proyecto activo (vía Projectile o default-directory)."
  (or (and (bound-and-true-p projectile-mode)
           (fboundp 'projectile-project-p)
           (projectile-project-p)
           (projectile-project-root))
      (and (fboundp 'project-current)
           (project-current)
           (project-root (project-current)))
      default-directory))

(defun my/antigravity--build-args (&optional extra-flags mode)
  "Construye la lista de argumentos para `agy` según la configuración actual.
Garantiza que las banderas (--model, --effort, etc.) precedan a los comandos posicionales."
  (let ((args nil))
    (when my/antigravity-model
      (setq args (append args (list "--model" my/antigravity-model))))
    (when my/antigravity-effort
      (setq args (append args (list "--effort" my/antigravity-effort))))
    (when my/antigravity-auto-approve
      (setq args (append args (list "--dangerously-skip-permissions"))))
    (when my/antigravity-sandbox
      (setq args (append args (list "--sandbox"))))
    (when mode
      (setq args (append args (list "--mode" mode))))
    (when extra-flags
      (setq args (append args extra-flags)))
    args))

(defun my/antigravity--build-command-string (&optional extra-args mode)
  "Genera la cadena de texto completa para invocar `agy` en la shell."
  (let ((args (my/antigravity--build-args extra-args mode)))
    (mapconcat #'shell-quote-argument
               (cons my/antigravity-executable args)
               " ")))

;; ====================================================================
;; --- 3. SESIONES INTERACTIVAS DEL AGENTE (VTERM REPL) ---
;; ====================================================================

(defun my/antigravity--get-or-create-vterm-buffer (buf-name &optional cmd)
  "Crea o enfoca el búfer BUF-NAME de vterm ejecutando CMD en el proyecto raíz."
  (let* ((proj-dir (my/antigravity-project-root))
         (buf (get-buffer buf-name)))
    (if (and buf (buffer-live-p buf))
        (progn
          (pop-to-buffer buf)
          ;; Solo enviar comando si el proceso en el búfer ya no está vivo
          (when (and cmd
                     (fboundp 'vterm-send-string)
                     (let ((proc (get-buffer-process buf)))
                       (or (null proc) (not (process-live-p proc)))))
            (vterm-send-string (concat cmd "\n"))))
      (let ((default-directory proj-dir))
        (setq buf (vterm (generate-new-buffer-name buf-name)))
        (pop-to-buffer buf)
        (when cmd
          ;; Esperar un instante para que vterm inicialice el shell
          (run-at-time 0.2 nil
                       (lambda (b c)
                         (when (buffer-live-p b)
                           (with-current-buffer b
                             (vterm-send-string (concat c "\n")))))
                       buf cmd))))
    buf))

;;;###autoload
(defun my/antigravity-cli ()
  "Inicia o enfoca la sesión interactiva del agente Antigravity en vterm."
  (interactive)
  (let ((cmd (my/antigravity--build-command-string)))
    (my/antigravity--get-or-create-vterm-buffer "*Antigravity-CLI*" cmd)
    (message "🚀 Sesión interactiva de Antigravity iniciada en %s" (my/antigravity-project-root))))

;;;###autoload
(defun my/antigravity-continue ()
  "Reanuda la conversación más reciente de Antigravity (`agy -c`)."
  (interactive)
  (let ((cmd (my/antigravity--build-command-string '("-c"))))
    (my/antigravity--get-or-create-vterm-buffer "*Antigravity-CLI*" cmd)
    (message "🔄 Reanudando última sesión de Antigravity...")))

;;;###autoload
(defun my/antigravity-plan ()
  "Inicia Antigravity en modo de Planificación Interactiva (`agy --mode plan`)."
  (interactive)
  (let ((cmd (my/antigravity--build-command-string nil "plan")))
    (my/antigravity--get-or-create-vterm-buffer "*Antigravity-Plan*" cmd)
    (message "📋 Modo Plan de Antigravity iniciado.")))

;;;###autoload
(defun my/antigravity-accept-edits ()
  "Inicia Antigravity en modo de Aceptación Rápida (`agy --mode accept-edits`)."
  (interactive)
  (let ((cmd (my/antigravity--build-command-string nil "accept-edits")))
    (my/antigravity--get-or-create-vterm-buffer "*Antigravity-CLI*" cmd)
    (message "⚡ Antigravity iniciado en modo Auto-Edición.")))

(defun my/antigravity--list-recent-conversations (&optional limit)
  "Retorna una lista de conversaciones recientes con metadatos.
Cada elemento es (DISPLAY-STRING . CONV-ID)."
  (let ((limit (or limit 25))
        (dirs (list (expand-file-name ".gemini/antigravity-cli/brain" (getenv "HOME"))
                    (expand-file-name ".gemini/antigravity-ide/brain" (getenv "HOME"))))
        (convs nil))
    (dolist (brain-dir dirs)
      (when (file-directory-p brain-dir)
        (dolist (f (directory-files brain-dir t "^[0-9a-f]\\{8\\}-"))
          (when (file-directory-p f)
            (let* ((conv-id (file-name-nondirectory f))
                   (mtime (file-attribute-modification-time (file-attributes f)))
                   (log-file (expand-file-name ".system_generated/logs/transcript.jsonl" f))
                   (preview ""))
              (when (file-exists-p log-file)
                (with-temp-buffer
                  (ignore-errors
                    (insert-file-contents log-file nil 0 600)
                    (when (re-search-forward "\"content\":[ \t]*\"\\(?:<USER_REQUEST>\\\\n\\)?\\([^\"\\]+\\)" nil t)
                      (setq preview (replace-regexp-in-string "\\\\n\\|[\n\r]" " " (match-string 1)))
                      (when (> (length preview) 50)
                        (setq preview (concat (substring preview 0 47) "...")))))))
              (push (list mtime conv-id preview) convs))))))
    (let* ((unique-convs (cl-remove-duplicates convs :key #'cadr :test #'string=))
           (sorted (sort unique-convs (lambda (a b) (time-less-p (car b) (car a))))))
      (cl-loop for (_mtime id prev) in (seq-take sorted limit)
               collect (cons (format "%s [%s] %s"
                                     (format-time-string "%Y-%m-%d %H:%M" _mtime)
                                     (substring id 0 8)
                                     (if (string-empty-p prev) "(sin preview)" prev))
                             id)))))

;;;###autoload
(defun my/antigravity-resume-conversation (&optional conv-id)
  "Reanuda una conversación de Antigravity seleccionándola interactivamente de la lista reciente."
  (interactive)
  (let* ((recent-convs (my/antigravity--list-recent-conversations))
         (id (or conv-id
                 (if recent-convs
                     (let ((choice (completing-read "Reanudar conversación: "
                                                   (mapcar #'car recent-convs)
                                                   nil nil)))
                       (or (cdr (assoc choice recent-convs)) choice))
                   (read-string "ID de conversación de Antigravity: ")))))
    (when (and id (not (string-empty-p id)))
      (let ((cmd (my/antigravity--build-command-string (list "--conversation" id))))
        (my/antigravity--get-or-create-vterm-buffer (format "*Antigravity-%s*" (substring id 0 (min (length id) 8))) cmd)
        (message "🔄 Reanudando conversación %s..." id)))))

;;;###autoload
(defun my/antigravity-new-session ()
  "Inicia una sesión completamente nueva y limpia (`agy --new-project`)."
  (interactive)
  (let ((cmd (my/antigravity--build-command-string '("--new-project"))))
    (my/antigravity--get-or-create-vterm-buffer "*Antigravity-CLI*" cmd)
    (message "✨ Nueva sesión limpia de Antigravity iniciada.")))

;;;###autoload
(defun my/antigravity-send-region (start end)
  "Envía la región seleccionada directamente a la sesión activa de Antigravity CLI."
  (interactive "r")
  (let ((text (buffer-substring-no-properties start end))
        (term-buf (get-buffer "*Antigravity-CLI*")))
    (if (and term-buf (buffer-live-p term-buf))
        (progn
          (with-current-buffer term-buf
            (vterm-send-string text)
            (vterm-send-string "\n"))
          (message "📤 Región enviada a Antigravity CLI."))
      (message "⚠️ No hay ninguna sesión *Antigravity-CLI* activa. Abre una primero con `; a c`."))))

;;;###autoload
(defun my/antigravity-send-file ()
  "Envía la referencia del archivo actual (@archivo) a Antigravity CLI."
  (interactive)
  (if buffer-file-name
      (let* ((rel-path (file-relative-name buffer-file-name (my/antigravity-project-root)))
             (mention (format "@%s " rel-path))
             (term-buf (get-buffer "*Antigravity-CLI*")))
        (if (and term-buf (buffer-live-p term-buf))
            (progn
              (with-current-buffer term-buf
                (vterm-send-string mention))
              (message "📎 Archivo %s enviado a Antigravity." mention))
          (message "⚠️ No hay ninguna sesión *Antigravity-CLI* activa.")))
    (message "⚠️ El búfer actual no visita ningún archivo.")))

(defun my/antigravity--list-available-skills ()
  "Encuentra las skills disponibles en el proyecto o globalmente."
  (let ((dirs (list (expand-file-name ".agents/skills" (my/antigravity-project-root))
                    (expand-file-name ".gemini/config/skills" (getenv "HOME"))
                    (expand-file-name ".gemini/antigravity-cli/builtin/skills" (getenv "HOME"))))
        (skills nil))
    (dolist (dir dirs)
      (when (file-directory-p dir)
        (dolist (f (directory-files dir t "^[^.]"))
          (when (file-directory-p f)
            (let ((skill-name (file-name-nondirectory f))
                  (skill-md (expand-file-name "SKILL.md" f)))
              (when (file-exists-p skill-md)
                (let ((desc ""))
                  (with-temp-buffer
                    (ignore-errors
                      (insert-file-contents skill-md nil 0 600)
                      (when (re-search-forward "^description:[ \t]*>?-?[ \t]*\\(.*\\)$" nil t)
                        (setq desc (string-trim (match-string 1))))))
                  (push (cons (concat "/" skill-name) (if (string-empty-p desc) "Skill personalizada" desc)) skills))))))))
    (delete-dups skills)))

;;;###autoload
(defun my/antigravity-send-slash-command ()
  "Muestra una paleta interactiva de Slash Commands y Skills de Antigravity y la envía al REPL."
  (interactive)
  (let* ((builtin-commands '(("/plan" . "Iniciar modo planificación interactivo")
                             ("/goal" . "Ejecución continua orientada a objetivo sin detenerse")
                             ("/schedule" . "Programar tareas periódicas o temporizadores")
                             ("/learn" . "Guardar aprendizaje o regla persistente")
                             ("/grill-me" . "Entrevista interactiva para afinar diseño")
                             ("/boost" . "Razonamiento profundo y verificación exhaustiva")
                             ("/teamwork-preview" . "Coordinación con subagentes paralelos")
                             ("/browser" . "Navegación y pruebas web automatizadas")
                             ("/status" . "Estado de tareas y procesos en ejecución")
                             ("/clear" . "Limpiar el contexto actual del chat")
                             ("/help" . "Mostrar ayuda de comandos Antigravity")
                             ("/exit" . "Finalizar sesión de Antigravity")))
         (skills (my/antigravity--list-available-skills))
         (all-commands (append builtin-commands skills))
         (candidates (mapcar (lambda (c) (format "%-20s — %s" (car c) (cdr c))) all-commands))
         (choice (completing-read "Slash Command / Skill de Antigravity: " candidates nil t))
         (command (car (split-string choice " " t)))
         (term-buf (get-buffer "*Antigravity-CLI*")))
    (if (and term-buf (buffer-live-p term-buf))
        (progn
          (pop-to-buffer term-buf)
          (vterm-send-string (concat command "\n")))
      (my/antigravity-cli)
      (run-at-time 0.4 nil
                   (lambda (c)
                     (let ((tb (get-buffer "*Antigravity-CLI*")))
                       (when (and tb (buffer-live-p tb))
                         (with-current-buffer tb
                           (vterm-send-string (concat c "\n"))))))
                   command))))

;; ====================================================================
;; --- 4. EJECUCIÓN ASÍNCRONA NO BLOQUEANTE (PRINT / CHAT / ACTIONS) ---
;; ====================================================================

(defvar my/antigravity-response-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") #'quit-window)
    (define-key map (kbd "y") #'my/antigravity--copy-response)
    (define-key map (kbd "i") #'my/antigravity--insert-response-at-origin)
    (define-key map (kbd "c") #'my/antigravity-cli)
    map)
  "Keymap para el búfer de respuestas de Antigravity.")

(define-derived-mode my/antigravity-response-mode markdown-mode "Antigravity-Output"
  "Modo para visualizar respuestas estructuradas de Antigravity."
  (setq-local truncate-lines nil)
  (setq-local word-wrap t))

(defvar-local my/antigravity--origin-buffer nil)
(defvar-local my/antigravity--origin-point nil)

(defun my/antigravity--copy-response ()
  "Copia todo el contenido de la respuesta de Antigravity al kill-ring."
  (interactive)
  (kill-new (buffer-substring-no-properties (point-min) (point-max)))
  (message "📋 Respuesta de Antigravity copiada al portapapeles."))

(defun my/antigravity--insert-response-at-origin ()
  "Inserta la respuesta en el búfer y posición de origen."
  (interactive)
  (let ((text (buffer-substring-no-properties (point-min) (point-max)))
        (orig-buf my/antigravity--origin-buffer)
        (orig-pt my/antigravity--origin-point))
    (if (and orig-buf (buffer-live-p orig-buf))
        (progn
          (with-current-buffer orig-buf
            (save-excursion
              (when orig-pt (goto-char orig-pt))
              (insert text)))
          (pop-to-buffer orig-buf)
          (message "✅ Respuesta insertada con éxito."))
      (message "⚠️ El búfer de origen ya no existe."))))

(defun my/antigravity--run-async (prompt &optional buf-title custom-args on-complete)
  "Ejecuta `agy --print` de forma asíncrona enviando PROMPT y transmitiendo en tiempo real."
  (let* ((orig-buf (current-buffer))
         (orig-pt (point))
         (buf-name (or buf-title "*Antigravity-Response*"))
         (buf (get-buffer-create buf-name))
         (proj-dir (my/antigravity-project-root))
         (args (my/antigravity--build-args (append '("--print") (or custom-args nil) (list prompt)))))
    (with-current-buffer buf
      (my/antigravity-response-mode)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (format "# 🤖 Antigravity [%s | effort: %s]\n\n" my/antigravity-model my/antigravity-effort))
        (insert "> [!NOTE]\n> Procesando consulta de forma asíncrona...\n\n---\n\n"))
      (setq my/antigravity--origin-buffer orig-buf)
      (setq my/antigravity--origin-point orig-pt))
    
    (display-buffer buf)
    
    (let* ((default-directory proj-dir)
           (proc (make-process
                  :name "antigravity-async"
                  :buffer buf
                  :command (cons my/antigravity-executable args)
                  :filter (lambda (process output)
                            (when (buffer-live-p (process-buffer process))
                              (with-current-buffer (process-buffer process)
                                (let ((inhibit-read-only t)
                                      (moving (= (point) (point-max))))
                                  (save-excursion
                                    (goto-char (point-max))
                                    (insert output))
                                  (when moving
                                    (goto-char (point-max)))))))
                  :sentinel (lambda (process event)
                              (when (buffer-live-p (process-buffer process))
                                (with-current-buffer (process-buffer process)
                                  (let ((inhibit-read-only t))
                                    (goto-char (point-max))
                                    (insert (format "\n\n---\n*Proceso finalizado (%s)*\n*[Atajos: `q` cerrar, `y` copiar, `i` insertar en origen]*" (string-trim event))))
                                  (message "🚀 Antigravity ha completado la respuesta."))
                                (when on-complete
                                  (funcall on-complete process event)))))))
      (setq my/antigravity-last-process proc)
      (message "⏳ Antigravity procesando en segundo plano...")
      proc)))

;;;###autoload
(defun my/antigravity-ask (prompt)
  "Envía una consulta general PROMPT a Antigravity con el contexto del proyecto."
  (interactive "sPregunta a Antigravity: ")
  (let* ((ctx (if (use-region-p)
                  (format "\n\nContexto seleccionado:\n```\n%s\n```"
                          (buffer-substring-no-properties (region-beginning) (region-end)))
                (if buffer-file-name
                    (format "\n\nArchivo actual: %s" (file-relative-name buffer-file-name (my/antigravity-project-root)))
                  "")))
         (full-prompt (concat prompt ctx)))
    (my/antigravity--run-async full-prompt "*Antigravity-Consulta*")))

;;;###autoload
(defun my/antigravity-explain-region (start end)
  "Pide a Antigravity una explicación clara y estructurada de la región seleccionada."
  (interactive "r")
  (let* ((code (buffer-substring-no-properties start end))
         (lang (or (and (boundp 'major-mode) (symbol-name major-mode)) ""))
         (prompt (format "Explica de forma didáctica, clara y concisa el siguiente fragmento (%s):\n\n```%s\n%s\n```\nDetalla qué hace, su lógica paso a paso y posibles mejoras o consideraciones." lang lang code)))
    (my/antigravity--run-async prompt "*Antigravity-Explicación*")))

;;;###autoload
(defun my/antigravity-refactor-region (start end instruction)
  "Refactoriza la región seleccionada según INSTRUCTION manteniendo las buenas prácticas."
  (interactive "r\nsInstrucción de refactorización: ")
  (let* ((code (buffer-substring-no-properties start end))
         (lang (or (and (boundp 'major-mode) (symbol-name major-mode)) ""))
         (prompt (format "Refactoriza el siguiente código (%s) siguiendo esta instrucción: '%s'. Proporciona el código limpio y una breve explicación de los cambios:\n\n```%s\n%s\n```" lang instruction lang code)))
    (my/antigravity--run-async prompt "*Antigravity-Refactor*")))

;;;###autoload
(defun my/antigravity-generate-docstring ()
  "Genera documentación o docstring para el símbolo o función bajo el cursor."
  (interactive)
  (let* ((func-text (if (use-region-p)
                        (buffer-substring-no-properties (region-beginning) (region-end))
                      (save-excursion
                        (beginning-of-defun)
                        (let ((beg (point)))
                          (end-of-defun)
                          (buffer-substring-no-properties beg (point))))))
         (lang (symbol-name major-mode))
         (prompt (format "Genera el docstring / comentario estructurado estándar para esta función en %s:\n\n```%s\n%s\n```\nDevuelve únicamente el docstring o código listo para ser insertado." lang lang func-text)))
    (my/antigravity--run-async prompt "*Antigravity-Docstring*")))

;;;###autoload
(defun my/antigravity-write-tests ()
  "Genera pruebas unitarias para el búfer o función actual."
  (interactive)
  (let* ((code (if (use-region-p)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (buffer-substring-no-properties (point-min) (min (point-max) 4000))))
         (lang (symbol-name major-mode))
         (prompt (format "Genera una suite completa de pruebas unitarias idiomáticas para este código en %s:\n\n```%s\n%s\n```" lang lang code)))
    (my/antigravity--run-async prompt "*Antigravity-Tests*")))

;; ====================================================================
;; --- 5. MODO INSTRUCTIVO INLINE (EDICIÓN DIRECTA & DIFF PREVIEW) ---
;; ====================================================================

(defun my/antigravity--clean-code-blocks (text)
  "Elimina bloques envolventes de Markdown (```lang ... ```) si el modelo los incluyó."
  (let ((s (string-trim text)))
    (if (and (string-prefix-p "```" s)
             (string-suffix-p "```" s))
        (let* ((without-prefix (replace-regexp-in-string "\\````[a-zA-Z0-9_-]*\n?" "" s))
               (without-suffix (replace-regexp-in-string "\n?```\\'" "" without-prefix)))
          without-suffix)
      s)))

(defun my/antigravity--show-diff (old-text new-text)
  "Muestra un búfer con las diferencias unificadas entre OLD-TEXT y NEW-TEXT."
  (let ((diff-buf (get-buffer-create "*Antigravity-Diff*"))
        (old-file (make-temp-file "agy-old-"))
        (new-file (make-temp-file "agy-new-")))
    (unwind-protect
        (progn
          (with-temp-file old-file (insert old-text))
          (with-temp-file new-file (insert new-text))
          (with-current-buffer diff-buf
            (let ((inhibit-read-only t))
              (erase-buffer)
              (call-process "diff" nil t nil "-u" "--label" "Original" "--label" "Propuesto" old-file new-file)
              (diff-mode)
              (setq-local header-line-format " 🛸 Antigravity Diff: Original (-) vs Propuesto (+) | 'q' cerrar")))
          (pop-to-buffer diff-buf))
      (ignore-errors (delete-file old-file))
      (ignore-errors (delete-file new-file)))))

;;;###autoload
(defun my/antigravity-inline-edit (start end instruction)
  "Edita la región seleccionada según INSTRUCTION y genera un diff para revisión."
  (interactive "r\nsInstrucción de edición inline: ")
  (let* ((orig-buf (current-buffer))
         (beg-marker (copy-marker start))
         (end-marker (copy-marker end t))
         (orig-text (buffer-substring-no-properties start end))
         (lang (symbol-name major-mode))
         (prompt (format "Devuelve ÚNICAMENTE el código resultante modificado sin explicaciones, ni etiquetas markdown (sin ```), que reemplazará exactamente este bloque en %s según la siguiente instrucción: '%s'.\n\nCódigo original:\n%s" lang instruction orig-text)))
    (message "⚡ Antigravity procesando edición inline...")
    (let* ((output-buf (generate-new-buffer " *antigravity-inline-tmp*"))
           (args (my/antigravity--build-args (list "--print" prompt))))
      (make-process
       :name "antigravity-inline"
       :buffer output-buf
       :command (cons my/antigravity-executable args)
       :sentinel (lambda (proc _event)
                   (when (eq (process-status proc) 'exit)
                     (let ((new-text (with-current-buffer (process-buffer proc)
                                       (my/antigravity--clean-code-blocks (buffer-string)))))
                       (kill-buffer (process-buffer proc))
                       (if (string-empty-p new-text)
                           (message "⚠️ Antigravity no devolvió cambios.")
                         (my/antigravity--apply-inline-diff orig-buf beg-marker end-marker orig-text new-text)))))))))

(defun my/antigravity--apply-inline-diff (buf beg-marker end-marker old-text new-text)
  "Muestra el resultado de la edición inline y permite aplicarlo con confirmación."
  (with-current-buffer buf
    (let ((choice (read-char-choice "⚡ Antigravity: [a]plicar cambios, [d]iferencias (diff), [c]ancelar: " '(?a ?d ?c))))
      (cond
       ((eq choice ?a)
        (delete-region (marker-position beg-marker) (marker-position end-marker))
        (goto-char (marker-position beg-marker))
        (insert new-text)
        (set-marker beg-marker nil)
        (set-marker end-marker nil)
        (message "✅ Cambios aplicados con éxito."))
       ((eq choice ?d)
        (my/antigravity--show-diff old-text new-text)
        (when (y-or-n-p "Aplicar estos cambios al búfer de origen? ")
          (with-current-buffer buf
            (delete-region (marker-position beg-marker) (marker-position end-marker))
            (goto-char (marker-position beg-marker))
            (insert new-text)
            (set-marker beg-marker nil)
            (set-marker end-marker nil)
            (message "✅ Cambios aplicados con éxito."))))
       (t
        (set-marker beg-marker nil)
        (set-marker end-marker nil)
        (message "❌ Edición cancelada."))))))

;; ====================================================================
;; --- 6. DIAGNÓSTICO Y AUTO-REPARACIÓN DE ERRORES ---
;; ====================================================================

;;;###autoload
(defun my/antigravity-diagnose-terminal-error ()
  "Captura el log reciente de vterm y solicita a Antigravity un diagnóstico y solución."
  (interactive)
  (let ((term-buf (or (get-buffer "*vterm*")
                      (get-buffer "*Antigravity-CLI*")
                      (car (cl-remove-if-not (lambda (b) (string-prefix-p "*vterm" (buffer-name b))) (buffer-list))))))
    (if term-buf
        (let ((logs (with-current-buffer term-buf
                      (buffer-substring-no-properties (max (point-min) (- (point-max) 3500)) (point-max)))))
          (my/antigravity--run-async
           (format "Analiza este log de error de terminal y proporciona el diagnóstico exacto, la causa raíz y los comandos de terminal o código para solucionarlo:\n\n```text\n%s\n```" logs)
           "*Antigravity-Diagnóstico-Terminal*"))
      (message "⚠️ No hay ninguna ventana de terminal vterm activa."))))

;;;###autoload
(defun my/antigravity-diagnose-compilation-error ()
  "Captura el búfer de compilación (*compilation* o *TeX Help*) y diagnostica el fallo."
  (interactive)
  (let ((comp-buf (or (get-buffer "*compilation*")
                      (get-buffer "*TeX Help*")
                      (car (cl-remove-if-not (lambda (b) (string-match-p "compil\\|output\\|tex" (buffer-name b))) (buffer-list))))))
    (if comp-buf
        (let ((logs (with-current-buffer comp-buf
                      (buffer-substring-no-properties (max (point-min) (- (point-max) 3500)) (point-max)))))
          (my/antigravity--run-async
           (format "Analiza este error de compilación / build y proporciona el parche exacto para corregir los archivos afectados:\n\n```text\n%s\n```" logs)
           "*Antigravity-Diagnóstico-Compilación*"))
      (message "⚠️ No se encontró ningún búfer de compilación activo."))))

;; ====================================================================
;; --- 7. HERRAMIENTAS ACADÉMICAS Y LATEX ---
;; ====================================================================

(defun my/antigravity--get-latex-math-region ()
  "Devuelve cons (START . END) de la región activa o de la fórmula bajo el cursor."
  (if (use-region-p)
      (cons (region-beginning) (region-end))
    (save-excursion
      (cond
       ;; Si AUCTeX / texmathp está disponible y estamos dentro de matemática
       ((and (fboundp 'texmathp) (texmathp))
        (let ((entry (car texmathp-why))
              (beg (cdr texmathp-why)))
          (goto-char beg)
          (if (or (string= entry "$") (string= entry "$$"))
              (progn
                (forward-char (length entry))
                (re-search-forward (regexp-quote entry) nil t))
            (when (fboundp 'LaTeX-find-matching-end)
              (LaTeX-find-matching-end)))
          (cons beg (point))))
       ;; Fallback a párrafo si no se detectó fórmula específica
       (t
        (bounds-of-thing-at-point 'paragraph))))))

;;;###autoload
(defun my/antigravity-latex-fix-formula (&optional start end)
  "Corrige, alinea y optimiza la fórmula LaTeX bajo el cursor o seleccionada."
  (interactive
   (when (use-region-p)
     (list (region-beginning) (region-end))))
  (let* ((bounds (if (and start end)
                     (cons start end)
                   (my/antigravity--get-latex-math-region)))
         (formula (if bounds
                      (buffer-substring-no-properties (car bounds) (cdr bounds))
                    ""))
         (prompt (format "Optimiza y corrige esta fórmula / entorno matemático en LaTeX. Asegura que la sintaxis de amsmath sea impecable, la alineación sea elegante y no contenga errores de compilación:\n\n```latex\n%s\n```\nDevuelve el código LaTeX corregido listo para copiar." formula)))
    (if (string-empty-p (string-trim formula))
        (message "⚠️ No se detectó ninguna fórmula o región matemática.")
      (my/antigravity--run-async prompt "*Antigravity-LaTeX-Fórmula*"))))

;;;###autoload
(defun my/antigravity-latex-explain (&optional start end)
  "Explica detalladamente el significado matemático o físico de la fórmula LaTeX."
  (interactive
   (when (use-region-p)
     (list (region-beginning) (region-end))))
  (let* ((bounds (if (and start end)
                     (cons start end)
                   (my/antigravity--get-latex-math-region)))
         (formula (if bounds
                      (buffer-substring-no-properties (car bounds) (cdr bounds))
                    ""))
         (prompt (format "Explica rigurosa y didácticamente el significado, variables y contexto de esta fórmula o demostración en LaTeX:\n\n```latex\n%s\n```" formula)))
    (if (string-empty-p (string-trim formula))
        (message "⚠️ No se detectó ninguna fórmula o región matemática.")
      (my/antigravity--run-async prompt "*Antigravity-LaTeX-Explicación*"))))

;;;###autoload
(defun my/antigravity-latex-generate-tikz (description)
  "Genera código TikZ / PGFPlots a partir de una DESCRIPCIÓN en lenguaje natural."
  (interactive "sDescripción del diagrama o gráfica TikZ: ")
  (let ((prompt (format "Genera un gráfico o diagrama completo y autocontenido usando TikZ / PGFPlots en LaTeX para la siguiente descripción:\n'%s'\nUtiliza un diseño moderno, colores armónicos y código limpio y modular." description)))
    (my/antigravity--run-async prompt "*Antigravity-LaTeX-TikZ*")))

;;;###autoload
(defun my/antigravity-latex-proof-assist (start end)
  "Sugiere pasos intermedios, lemas o estructuración lógica para una demostración matemática."
  (interactive "r")
  (let* ((proof-text (buffer-substring-no-properties start end))
         (prompt (format "Analiza este enunciado o borrador de demostración matemática y proporciona sugerencias rigurosas de pasos intermedios, lemas auxiliares y estructura formal en LaTeX:\n\n```latex\n%s\n```" proof-text)))
    (my/antigravity--run-async prompt "*Antigravity-LaTeX-Demostración*")))

;; ====================================================================
;; --- 8. INTEGRACIÓN CON GIT Y DIRED ---
;; ====================================================================

;;;###autoload
(defun my/antigravity-git-commit-message ()
  "Genera un mensaje de commit semántico a partir del diff en staging.
Si se ejecuta dentro de un búfer de commit de Magit (`COMMIT_EDITMSG`), lo inserta directamente."
  (interactive)
  (let* ((proj-dir (my/antigravity-project-root))
         (default-directory proj-dir)
         (diff (shell-command-to-string "git diff --cached"))
         (in-commit-buf (or (string-match-p "COMMIT_EDITMSG" (buffer-name))
                            (derived-mode-p 'git-commit-mode))))
    (if (string-empty-p (string-trim diff))
        (message "⚠️ No hay cambios en staging (`git add`). Agrega archivos primero.")
      (let ((prompt (format "Genera un mensaje de commit claro y semántico siguiendo la convención 'Conventional Commits' (ej: feat, fix, refactor, docs) a partir de este diff de git:\n\n```diff\n%s\n```\nDevuelve únicamente el título del commit y viñetas descriptivas si son necesarias, sin texto de cortesía ni etiquetas de bloque markdown (```)." diff)))
        (if in-commit-buf
            (let ((target-buf (current-buffer)))
              (message "⏳ Generando mensaje de commit con Antigravity...")
              (make-process
               :name "antigravity-commit-msg"
               :buffer (generate-new-buffer " *antigravity-commit-tmp*")
               :command (cons my/antigravity-executable (my/antigravity--build-args (list "--print" prompt)))
               :sentinel (lambda (proc _ev)
                           (when (eq (process-status proc) 'exit)
                             (let ((msg (my/antigravity--clean-code-blocks
                                         (with-current-buffer (process-buffer proc)
                                           (string-trim (buffer-string))))))
                               (kill-buffer (process-buffer proc))
                               (when (buffer-live-p target-buf)
                                 (with-current-buffer target-buf
                                   (save-excursion
                                     (goto-char (point-min))
                                     (insert msg "\n\n")))
                                 (message "✅ Mensaje de commit insertado en Magit.")))))))
          (my/antigravity--run-async prompt "*Antigravity-Git-Commit*" nil
                                    (lambda (proc _ev)
                                      (when (eq (process-status proc) 'exit)
                                        (message "💡 Puedes copiar el mensaje con `y` e insertarlo en Magit.")))))))))

;;;###autoload
(defun my/antigravity-git-review-diff ()
  "Realiza una revisión de código detallada sobre los cambios locales pendientes de Git."
  (interactive)
  (let ((diff (shell-command-to-string "git diff HEAD")))
    (if (string-empty-p (string-trim diff))
        (message "⚠️ No hay cambios modificados en el repositorio de Git.")
      (let ((prompt (format "Realiza una revisión de código minuciosa sobre este diff de cambios locales. Señala posibles bugs, casos extremos, mejoras de rendimiento o legibilidad:\n\n```diff\n%s\n```" diff)))
        (my/antigravity--run-async prompt "*Antigravity-Git-Review*")))))

;;;###autoload
(defun my/antigravity-dired-send-marked ()
  "Envía los archivos o directorios marcados en Dired a una nueva sesión de Antigravity."
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (let* ((files (dired-get-marked-files))
             (flags (mapcan (lambda (f) (list "--add-dir" f)) files))
             (cmd (my/antigravity--build-command-string flags)))
        (my/antigravity--get-or-create-vterm-buffer "*Antigravity-CLI*" cmd)
        (message "📂 Iniciando Antigravity con %d elementos de Dired como contexto." (length files)))
    (message "⚠️ Este comando solo se puede usar dentro de un búfer Dired.")))

;; ====================================================================
;; --- 9. GESTIÓN DE PERSONALIZACIONES (SKILLS, RULES, MCP) ---
;; ====================================================================

;;;###autoload
(defun my/antigravity-find-rules ()
  "Busca o crea reglas de Antigravity en el proyecto activo o globalmente."
  (interactive)
  (let* ((proj-rules-dir (expand-file-name ".agents/rules" (my/antigravity-project-root)))
         (global-rules-dir (expand-file-name ".gemini/config/rules" (getenv "HOME")))
         (dir (if (file-directory-p proj-rules-dir) proj-rules-dir global-rules-dir)))
    (unless (file-directory-p dir)
      (make-directory dir t))
    (find-file dir)))

;;;###autoload
(defun my/antigravity-find-skills ()
  "Abre el directorio de Skills de Antigravity del proyecto activo o global."
  (interactive)
  (let* ((proj-skills-dir (expand-file-name ".agents/skills" (my/antigravity-project-root)))
         (global-skills-dir (expand-file-name ".gemini/config/skills" (getenv "HOME")))
         (dir (if (file-directory-p proj-skills-dir) proj-skills-dir global-skills-dir)))
    (unless (file-directory-p dir)
      (make-directory dir t))
    (find-file dir)))

;; ====================================================================
;; --- 10. CONMUTADORES DE CONFIGURACIÓN DINÁMICA ---
;; ====================================================================

;;;###autoload
(defun my/antigravity-switch-model (&optional refresh)
  "Selecciona interactivamente el modelo de Antigravity desde `agy models`.
Con argumento prefijo \\[universal-argument] fuerza la actualización de la lista."
  (interactive "P")
  (let* ((models-alist (my/antigravity-get-models refresh))
         (candidates (mapcar (lambda (pair)
                               (format "%-25s (%s)" (car pair) (cdr pair)))
                             models-alist))
         (default-cand (car (cl-remove-if-not
                             (lambda (c) (string-prefix-p my/antigravity-model c))
                             candidates)))
         (choice (completing-read
                  (format "Modelo Antigravity (actual: %s): " my/antigravity-model)
                  candidates nil nil nil nil default-cand))
         (selected-id (car (split-string choice " " t))))
    (when (and selected-id (not (string-empty-p selected-id)))
      (setq my/antigravity-model selected-id)
      ;; Sincronizar effort automáticamente si el ID del modelo termina en -high, -medium o -low
      (cond
       ((string-match-p "-high$" selected-id) (setq my/antigravity-effort "high"))
       ((string-match-p "-medium$" selected-id) (setq my/antigravity-effort "medium"))
       ((string-match-p "-low$" selected-id) (setq my/antigravity-effort "low")))
      (message "🚀 Modelo cambiado a: %s (Effort: %s)" my/antigravity-model my/antigravity-effort))))

;;;###autoload
(defun my/antigravity-switch-effort ()
  "Selecciona el nivel de razonamiento (effort)."
  (interactive)
  (let ((choice (completing-read "Nivel de razonamiento (effort): " '("low" "medium" "high") nil t nil nil my/antigravity-effort)))
    (setq my/antigravity-effort choice)
    (message "🧠 Reasoning Effort configurado en: %s" choice)))

;;;###autoload
(defun my/antigravity-toggle-auto-approve ()
  "Alterna la auto-aprobación de permisos (`--dangerously-skip-permissions`)."
  (interactive)
  (setq my/antigravity-auto-approve (not my/antigravity-auto-approve))
  (message "🛡️ Auto-aprobación de permisos: %s" (if my/antigravity-auto-approve "ACTIVADA (sin confirmaciones)" "DESACTIVADA (segura)")))

;;;###autoload
(defun my/antigravity-toggle-sandbox ()
  "Alterna la ejecución en entorno restringido (`--sandbox`)."
  (interactive)
  (setq my/antigravity-sandbox (not my/antigravity-sandbox))
  (message "📦 Modo Sandbox de Antigravity: %s" (if my/antigravity-sandbox "ACTIVADO" "DESACTIVADO")))

;; ====================================================================
;; --- 11. MENÚ TRANSIENT MAESTRO (ANTIGRAVITY TRANSIENT UI) ---
;; ====================================================================

(transient-define-prefix my/antigravity-menu ()
  "Menú interactivo maestro para todas las funciones de Google Antigravity en Emacs."
  [:description
   (lambda ()
     (format "🛸 Google Antigravity | Modelo: %s | Effort: %s | Permisos: %s | Sandbox: %s"
             (propertize my/antigravity-model 'face 'font-lock-keyword-face)
             (propertize my/antigravity-effort 'face 'font-lock-type-face)
             (if my/antigravity-auto-approve (propertize "Auto" 'face 'font-lock-warning-face) (propertize "Ask" 'face 'font-lock-doc-face))
             (if my/antigravity-sandbox (propertize "ON" 'face 'font-lock-builtin-face) (propertize "OFF" 'face 'font-lock-comment-face))))
   
   ["💬 Sesiones Agente (CLI)"
    ("c" "Terminal Interactiva (vterm)" my/antigravity-cli)
    ("C" "Reanudar Última Sesión (-c)" my/antigravity-continue)
    ("p" "Modo Planificación (plan)" my/antigravity-plan)
    ("A" "Modo Auto-Edición (accept-edits)" my/antigravity-accept-edits)
    ("n" "Nueva Sesión Limpia" my/antigravity-new-session)
    ("R" "Reanudar Sesión Reciente..." my/antigravity-resume-conversation)
    ("/" "Slash Commands & Skills..." my/antigravity-send-slash-command)]

   ["⚡ Acciones de Código"
    ("q" "Preguntar / Consultar" my/antigravity-ask)
    ("i" "Edición Inline (Diff)" my/antigravity-inline-edit)
    ("e" "Explicar Selección" my/antigravity-explain-region)
    ("r" "Refactorizar Región" my/antigravity-refactor-region)
    ("d" "Generar Docstring" my/antigravity-generate-docstring)
    ("t" "Generar Pruebas Unitarias" my/antigravity-write-tests)
    ("s" "Enviar Región al CLI" my/antigravity-send-region)
    ("f" "Enviar Archivo al CLI (@)" my/antigravity-send-file)]

   ["🛠️ Diagnóstico & Logs"
    ("L" "Salida de Terminal en Vivo (Tail)" my/antigravity-live-output)
    ("T" "Terminal vterm en Vivo" my/antigravity-live-vterm)
    ("E" "Diagnosticar Terminal vterm" my/antigravity-diagnose-terminal-error)
    ("B" "Diagnosticar Compilación" my/antigravity-diagnose-compilation-error)
    ("G" "Generar Commit Message" my/antigravity-git-commit-message)
    ("V" "Revisar Cambios Git Diff" my/antigravity-git-review-diff)
    ("D" "Enviar Marcados de Dired" my/antigravity-dired-send-marked)]

   ["🎓 LaTeX & Matemáticas"
    ("F" "Corregir Ecuación / Align" my/antigravity-latex-fix-formula)
    ("X" "Explicar Fórmula / Teorema" my/antigravity-latex-explain)
    ("Z" "Generar Diagrama TikZ" my/antigravity-latex-generate-tikz)
    ("P" "Asistente de Demostración" my/antigravity-latex-proof-assist)]

   ["⚙️ Ajustes & Reglas"
    ("m" "Cambiar Modelo (Dinámico)" my/antigravity-switch-model)
    ("x" "Nivel de Razonamiento (effort)" my/antigravity-switch-effort)
    ("!" "Alternar Auto-Aprobación" my/antigravity-toggle-auto-approve)
    ("b" "Alternar Sandbox" my/antigravity-toggle-sandbox)
    ("k" "Abrir Reglas (.agents/rules)" my/antigravity-find-rules)
    ("K" "Abrir Skills (.agents/skills)" my/antigravity-find-skills)]])

;; ====================================================================
;; --- 11.1 SEGUIMIENTO DE LOGS Y TAREAS EN TIEMPO REAL ---
;; ====================================================================

(defun my/antigravity-find-latest-task-log ()
  "Encuentra el archivo .log de la tarea más reciente de Antigravity (CLI o IDE)."
  (let* ((brain-dirs (list (expand-file-name ".gemini/antigravity-cli/brain" (getenv "HOME"))
                           (expand-file-name ".gemini/antigravity-ide/brain" (getenv "HOME"))))
         (all-logs nil))
    (dolist (brain-dir brain-dirs)
      (when (file-directory-p brain-dir)
        (dolist (conv (directory-files brain-dir t "^[0-9a-f]"))
          (when (file-directory-p conv)
            (let ((tasks-dir (expand-file-name ".system_generated/tasks" conv)))
              (when (file-directory-p tasks-dir)
                (dolist (log-file (directory-files tasks-dir t "\\.log$"))
                  (push (cons (file-attribute-modification-time (file-attributes log-file))
                              log-file)
                        all-logs))))))))
    (when all-logs
      (cdr (car (sort all-logs (lambda (a b) (time-less-p (car b) (car a)))))))))

;;;###autoload
(defun my/antigravity-live-output ()
  "Abre una ventana dedicada que muestra la salida de terminal en tiempo real de Antigravity."
  (interactive)
  (let ((log-path (my/antigravity-find-latest-task-log)))
    (if (not (and log-path (file-exists-p log-path)))
        (message "ℹ️ No hay tareas recientes de Antigravity en ejecución.")
      (let ((buf (get-buffer-create "*Antigravity-Live-Output*")))
        (with-current-buffer buf
          (read-only-mode -1)
          (erase-buffer)
          (insert-file-contents log-path)
          (goto-char (point-max))
          (view-mode 1)
          (setq-local auto-revert-tail-mode t)
          (setq-local auto-revert-interval 0.5)
          (auto-revert-mode 1)
          (setq-local revert-without-query '(".*"))
          (setq-local header-line-format
                      (format " 🛸 Antigravity Live Log: %s | (Presiona 'q' para ocultar)"
                               (file-name-nondirectory log-path))))
        (pop-to-buffer buf '(display-buffer-at-bottom
                             (window-height . 0.35)))
        (message "🛸 Mostrando log en vivo: %s" (file-name-nondirectory log-path))))))

;;;###autoload
(defun my/antigravity-live-vterm ()
  "Abre una terminal vterm ejecutando `tail -f` sobre la tarea más reciente de Antigravity."
  (interactive)
  (let ((log-path (my/antigravity-find-latest-task-log)))
    (if (not (and log-path (file-exists-p log-path)))
        (message "ℹ️ No hay tareas recientes de Antigravity.")
      (let* ((vterm-buffer-name "*Antigravity-Tail*")
             (buf (get-buffer vterm-buffer-name)))
        (if (and buf (buffer-live-p buf))
            (pop-to-buffer buf)
          (let ((new-buf (vterm vterm-buffer-name)))
            (with-current-buffer new-buf
              (vterm-send-string (format "tail -f %s\n" (shell-quote-argument log-path))))
            (pop-to-buffer new-buf)))))))

;; ====================================================================
;; --- 12. CONFIGURACIÓN COMPATIBLE DE GPTEL Y AIDERMACS ---
;; ====================================================================

(defconst my/gemini-models
  '("gemini-2.0-flash" "gemini-2.0-flash-lite" "gemini-1.5-pro" "gemini-1.5-flash")
  "Lista de modelos de Gemini actualizados para GPTel.")

(defun my/setup-gptel-backends ()
  "Inicializa los backends disponibles de IA para GPTel (DeepSeek y Gemini)."
  (when (fboundp 'gptel-make-openai)
    ;; Configurar DeepSeek si DEEPSEEK_API_KEY está configurada en el entorno
    (when-let ((deepseek-key (getenv "DEEPSEEK_API_KEY")))
      (let ((backend (gptel-make-openai "DeepSeek"
                       :host "api.deepseek.com"
                       :endpoint "/chat/completions"
                       :stream t
                       :key deepseek-key
                       :models '(deepseek-chat deepseek-reasoner))))
        (setq gptel-backend backend)
        (setq gptel-model 'deepseek-chat)
        (message "DeepSeek configurado como backend por defecto en GPTel."))))
  
  ;; Configurar Gemini si GEMINI_API_KEY está disponible
  (when-let ((gemini-key (or (getenv "GEMINI_API_KEY") (bound-and-true-p gptel-api-key))))
    (when (fboundp 'gptel-make-gemini)
      (let ((backend (gptel-make-gemini "Antigravity-Gemini"
                       :key gemini-key
                       :stream t
                       :models (mapcar #'intern my/gemini-models))))
        (unless (getenv "DEEPSEEK_API_KEY")
          (setq gptel-backend backend)
          (setq gptel-model (intern (car my/gemini-models))))
        (message "Antigravity/Gemini configurado en GPTel.")))))

(with-eval-after-load 'gptel
  (my/setup-gptel-backends))

(use-package aidermacs
  :ensure t
  :custom
  (aidermacs-default-model "deepseek/deepseek-chat")
  (aidermacs-use-helm nil)
  (aidermacs-default-chat-mode 'code)
  :config
  (setq aidermacs-extra-args '("--no-auto-commits" "--no-gitignore" "--yes")))

(provide 'my-ai)
;;; my-ai.el ends here
