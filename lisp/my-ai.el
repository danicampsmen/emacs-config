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

(defcustom my/antigravity-default-model "gemini-3.7-flash"
  "Modelo por defecto para las sesiones de Antigravity."
  :type 'string
  :group 'my-antigravity)

(defvar my/antigravity-model "gemini-3.7-flash"
  "Modelo activo actualmente para Antigravity.")

(defvar my/antigravity-available-models
  '("gemini-3.7-flash"
    "gemini-3.6-flash-high"
    "gemini-3.6-flash-medium"
    "gemini-3.6-flash-low"
    "gemini-3.5-flash-high"
    "gemini-3.1-pro-high"
    "claude-sonnet-4-6"
    "claude-opus-4-6-thinking"
    "gpt-oss-120b-medium")
  "Lista de modelos soportados por Antigravity CLI.")

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
  "Construye la lista de argumentos para `agy` según la configuración actual."
  (let ((args (copy-sequence extra-flags)))
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
          (when (and cmd (fboundp 'vterm-send-string))
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

;;;###autoload
(defun my/antigravity-resume-conversation (conv-id)
  "Reanuda una conversación específica de Antigravity por su CONV-ID."
  (interactive "sID de conversación de Antigravity: ")
  (let ((cmd (my/antigravity--build-command-string (list "--conversation" conv-id))))
    (my/antigravity--get-or-create-vterm-buffer (format "*Antigravity-%s*" conv-id) cmd)))

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

;;;###autoload
(defun my/antigravity-send-slash-command ()
  "Muestra una paleta interactiva de Slash Commands de Antigravity y la envía al REPL."
  (interactive)
  (let* ((commands '(("/plan" . "Iniciar modo planificación interactivo")
                     ("/goal" . "Ejecución continua orientada a objetivo sin detenerse")
                     ("/schedule" . "Programar tareas periódicas o temporizadores")
                     ("/learn" . "Guardar aprendizaje o regla persistente")
                     ("/grill-me" . "Entrevista interactiva para afinar diseño")
                     ("/clear" . "Limpiar el contexto actual del chat")
                     ("/help" . "Mostrar ayuda de comandos Antigravity")
                     ("/exit" . "Finalizar sesión de Antigravity")))
         (choice (completing-read "Slash Command de Antigravity: " (mapcar #'car commands) nil t))
         (term-buf (get-buffer "*Antigravity-CLI*")))
    (if (and term-buf (buffer-live-p term-buf))
        (progn
          (pop-to-buffer term-buf)
          (vterm-send-string (concat choice "\n")))
      (my/antigravity-cli)
      (run-at-time 0.3 nil
                   (lambda (c)
                     (let ((tb (get-buffer "*Antigravity-CLI*")))
                       (when (and tb (buffer-live-p tb))
                         (with-current-buffer tb
                           (vterm-send-string (concat c "\n"))))))
                   choice))))

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

;;;###autoload
(defun my/antigravity-inline-edit (start end instruction)
  "Edita la región seleccionada según INSTRUCTION y genera un diff para revisión."
  (interactive "r\nsInstrucción de edición inline: ")
  (let* ((orig-text (buffer-substring-no-properties start end))
         (orig-buf (current-buffer))
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
                                       (string-trim (buffer-string)))))
                       (kill-buffer (process-buffer proc))
                       (if (string-empty-p new-text)
                           (message "⚠️ Antigravity no devolvió cambios.")
                         (my/antigravity--apply-inline-diff orig-buf start end orig-text new-text)))))))))

(defun my/antigravity--apply-inline-diff (buf start end _old-text new-text)
  "Muestra el resultado de la edición inline y permite aplicarlo con confirmación."
  (with-current-buffer buf
    (let ((choice (read-char-choice "⚡ Antigravity: [a]plicar cambios, [d]iferencias en búfer, [c]ancelar: " '(?a ?d ?c))))
      (cond
       ((eq choice ?a)
        (delete-region start end)
        (goto-char start)
        (insert new-text)
        (message "✅ Cambios aplicados con éxito."))
       ((eq choice ?d)
        (let ((diff-buf (get-buffer-create "*Antigravity-Diff*")))
          (with-current-buffer diff-buf
            (let ((inhibit-read-only t))
              (erase-buffer)
              (insert (format "=== Código Propuesto por Antigravity ===\n\n%s" new-text))
              (diff-mode)))
          (pop-to-buffer diff-buf)))
       (t
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

;;;###autoload
(defun my/antigravity-latex-fix-formula (start end)
  "Corrige, alinea y optimiza la fórmula o entorno LaTeX seleccionado."
  (interactive "r")
  (let* ((formula (buffer-substring-no-properties start end))
         (prompt (format "Optimiza y corrige esta fórmula / entorno matemático en LaTeX. Asegura que la sintaxis de amsmath sea impecable, la alineación sea elegante y no contenga errores de compilación:\n\n```latex\n%s\n```\nDevuelve el código LaTeX corregido listo para copiar." formula)))
    (my/antigravity--run-async prompt "*Antigravity-LaTeX-Fórmula*")))

;;;###autoload
(defun my/antigravity-latex-explain (start end)
  "Explica detalladamente el significado matemático o físico de la fórmula LaTeX."
  (interactive "r")
  (let* ((formula (buffer-substring-no-properties start end))
         (prompt (format "Explica rigurosa y didácticamente el significado, variables y contexto de esta fórmula o demostración en LaTeX:\n\n```latex\n%s\n```" formula)))
    (my/antigravity--run-async prompt "*Antigravity-LaTeX-Explicación*")))

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
  "Genera un mensaje de commit semántico (Conventional Commits) a partir del diff en staging."
  (interactive)
  (let ((diff (shell-command-to-string "git diff --cached")))
    (if (string-empty-p (string-trim diff))
        (message "⚠️ No hay cambios en staging (`git add`). Agrega archivos primero.")
      (let ((prompt (format "Genera un mensaje de commit claro y semántico siguiendo la convención 'Conventional Commits' (ej: feat, fix, refactor, docs) a partir de este diff de git:\n\n```diff\n%s\n```\nDevuelve únicamente el título del commit y viñetas descriptivas si son necesarias." diff)))
        (my/antigravity--run-async prompt "*Antigravity-Git-Commit*" nil
                                  (lambda (proc _ev)
                                    (when (eq (process-status proc) 'exit)
                                      (message "💡 Puedes copiar el mensaje con `y` e insertarlo en Magit."))))))))

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
(defun my/antigravity-switch-model ()
  "Selecciona interactivamente el modelo de Antigravity."
  (interactive)
  (let ((choice (completing-read "Modelo de Antigravity: " my/antigravity-available-models nil t nil nil my/antigravity-model)))
    (setq my/antigravity-model choice)
    (message "🚀 Modelo de Antigravity cambiado a: %s" choice)))

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
  (message "🛡️ Auto-aprobación de permisos: %s" (if my/antigravity-auto-approve "ACTIVADA (sin confirmaciones)" "DESACTIVADA (seguro)")))

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
    ("R" "Reanudar por ID..." my/antigravity-resume-conversation)
    ("/" "Slash Commands..." my/antigravity-send-slash-command)]

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
    ("m" "Cambiar Modelo" my/antigravity-switch-model)
    ("x" "Nivel de Razonamiento (effort)" my/antigravity-switch-effort)
    ("!" "Alternar Auto-Aprobación" my/antigravity-toggle-auto-approve)
    ("b" "Alternar Sandbox" my/antigravity-toggle-sandbox)
    ("k" "Abrir Reglas (.agents/rules)" my/antigravity-find-rules)
    ("K" "Abrir Skills (.agents/skills)" my/antigravity-find-skills)]])

;; ====================================================================
;; --- 11.1 SEGUIMIENTO DE LOGS Y TAREAS EN TIEMPO REAL ---
;; ====================================================================

(defun my/antigravity-find-latest-task-log ()
  "Encuentra el archivo .log de la tarea más reciente de Antigravity."
  (let* ((brain-dir (expand-file-name ".gemini/antigravity-ide/brain" (getenv "HOME")))
         (all-logs nil))
    (when (file-directory-p brain-dir)
      (dolist (conv (directory-files brain-dir t "^[^.]"))
        (let ((tasks-dir (expand-file-name ".system_generated/tasks" conv)))
          (when (file-directory-p tasks-dir)
            (dolist (log-file (directory-files tasks-dir t "\\.log$"))
              (push (cons (file-attribute-modification-time (file-attributes log-file))
                          log-file)
                    all-logs))))))
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
  '("gemini-2.5-flash" "gemini-2.5-pro" "gemini-1.5-pro-latest" "gemini-1.5-flash-latest")
  "Lista de modelos de Gemini para GPTel.")

(defun my/setup-gptel-gemini ()
  "Inicializa el backend oficial de Gemini en GPTel."
  (let ((key (or (getenv "GEMINI_API_KEY")
                 (bound-and-true-p gptel-api-key))))
    (when (and key (fboundp 'gptel-make-gemini))
      (setq gptel-api-key key)
      (let ((backend (gptel-make-gemini "Antigravity-Gemini"
                       :key key
                       :stream t
                       :models (mapcar #'intern my/gemini-models))))
        (setq gptel-backend backend)
        (setq gptel-model (intern (car my/gemini-models)))
        (message "Antigravity/Gemini configurado en GPTel.")))))

(with-eval-after-load 'gptel
  (my/setup-gptel-gemini))

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