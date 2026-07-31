;;; gdrive-sync.el --- Sincronización Inteligente, Persistente y Rápida -*- lexical-binding: t; -*-

;; Author: Fayfer
;; Version: 9.1 (Estrategia de Salida Configurable y Sin Cuellos de Botella)
;; Package-Requires: ((emacs "29.1") (projectile "2.0") (consult "0.1"))

;;; Commentary:
;; Sincronización optimizada para Google Drive usando rclone bisync,
;; caché persistente en SQLite vía multisession, montaje FUSE asíncrono y centinelas.

;;; Code:

(require 'projectile)
(require 'consult)
(require 'multisession)
(require 'subr-x)

(defgroup gdrive-sync nil
  "Configuración de sincronización con Google Drive."
  :group 'tools
  :prefix "gdrive-sync-")

;; ==================================================================
;; --- 1. CONFIGURACIÓN Y PERSISTENCIA DE CACHÉ ---
;; ==================================================================

(defcustom gdrive-sync-remote-name "GoogleDrive-Documentos_Ubuntu_Fayfer"
  "Nombre exacto del remote en rclone."
  :type 'string
  :group 'gdrive-sync)

(defcustom gdrive-sync-local-dir (expand-file-name "~/Documentos/")
  "Directorio local raíz."
  :type 'directory
  :group 'gdrive-sync)

(defcustom gdrive-sync-remote-dir "Documentos-Ubuntu-Fayfer"
  "Carpeta destino dentro del remote."
  :type 'string
  :group 'gdrive-sync)

(defcustom gdrive-sync-filter-file (expand-file-name "~/.config/rclone/rclone-filters.txt")
  "Archivo de filtros para ignorar archivos basura (.elc, .git, etc.)."
  :type 'file
  :group 'gdrive-sync)

(defcustom gdrive-sync-on-exit-strategy 'prompt
  "Estrategia de sincronización al salir de Emacs.
Valores posibles:
  'prompt - Pregunta (y/n) si deseas sincronizar solo cuando hay cambios (Evita esperas).
  'async  - Lanza rclone en segundo plano desacoplado (nohup) y cierra Emacs al instante.
  'fast   - Subida quirúrgica rápida únicamente de los archivos editados en la sesión.
  nil     - Desactivar completamente la sincronización al salir."
  :type '(choice (const :tag "Preguntar confirmación (y/n)" prompt)
                 (const :tag "Segundo plano desacoplado (nohup)" async)
                 (const :tag "Subida rápida quirúrgica de archivos editados" fast)
                 (const :tag "Desactivar al salir" nil))
  :group 'gdrive-sync)

;; Caché Persistente respaldada por SQLite entre sesiones
(define-multisession-variable gdrive-sync-remote-folders-cache '("/")
  "Caché persistente de carpetas de GDrive respaldada por la base de datos multisession de Emacs."
  :synchronized t)

;; ==================================================================
;; --- 2. MOTOR DE SINCRONIZACIÓN ASÍNCRONO ---
;; ==================================================================

(defun gdrive-sync--get-full-remote (remote-path)
  "Resuelve la ruta remota de forma segura y consistente."
  (cond
   ((string-match-p ":" remote-path)
    remote-path)
   ((or (string-empty-p remote-path) (string= remote-path gdrive-sync-remote-name))
    (concat gdrive-sync-remote-name ":"))
   (t
    (format "%s:%s" gdrive-sync-remote-name remote-path))))

(defun gdrive-sync--execute (command-type local-path remote-path flags &optional silent)
  "Ejecuta un comando rclone de forma asíncrona redirigiendo las rutas según su tipo."
  (let* ((full-remote-path (gdrive-sync--get-full-remote remote-path))
         (base-flags "--progress -v --drive-acknowledge-abuse --fast-list --tpslimit 8")
         (sync-flags (concat base-flags " --transfers 8 --checkers 16 --track-renames"))
         (use-filter (not (member command-type '("cleanup" "about" "dedupe" "lsf" "tree"))))
         (filter-flag (if (and use-filter (file-exists-p gdrive-sync-filter-file))
                          (format "--filter-from %s" (shell-quote-argument gdrive-sync-filter-file))
                        ""))
         (safe-local-path (unless (or (null local-path) (string-empty-p local-path))
                            (if (string-match-p ":" local-path)
                                local-path
                              (expand-file-name local-path))))
         (command (cond
                   ((member command-type '("cleanup" "about"))
                    (format "rclone %s %s %s"
                            command-type base-flags
                            (shell-quote-argument full-remote-path)))
                   ((member command-type '("lsf" "tree"))
                    (format "rclone %s %s %s %s"
                            command-type base-flags flags
                            (shell-quote-argument full-remote-path)))
                   ((string= command-type "dedupe")
                    (format "rclone dedupe %s %s %s"
                            flags base-flags
                            (shell-quote-argument full-remote-path)))
                   ((string= command-type "copyto")
                    (format "rclone copyto %s %s %s %s %s"
                            sync-flags filter-flag flags
                            (shell-quote-argument safe-local-path)
                            (shell-quote-argument full-remote-path)))
                   (t
                    (format "rclone %s %s %s %s %s %s"
                            command-type sync-flags filter-flag flags
                            (shell-quote-argument safe-local-path)
                            (shell-quote-argument full-remote-path)))))
         (output-buffer (generate-new-buffer (format "*gdrive-%s-output*" command-type))))
    (unless silent
      (display-buffer output-buffer))
    (message "Iniciando proceso rclone (%s)..." command-type)
    (set-process-sentinel
     (start-process-shell-command "gdrive-sync" output-buffer command)
     (lambda (proc event)
       (cond
        ((string= event "finished\n")
         (message "✅ ¡Operación rclone (%s) completada con éxito!" command-type)
         (when (and silent (buffer-live-p output-buffer))
           (kill-buffer output-buffer)))
        ((string-match-p "exited abnormally" event)
         (message "❌ Error en rclone (%s). Consulta el búfer %s para detalles."
                  command-type (buffer-name output-buffer))
         (when silent
           (display-buffer output-buffer))
         (when (string= command-type "bisync")
           (message "Sugerencia: Si hay bloqueos (.lck), ejecuta ;dL (Unlock) o ;dI (Resync)."))))))))

;; ==================================================================
;; --- 3. CACHÉ PERSISTENTE Y MONTAJE FUSE OPTIMIZADO ---
;; ==================================================================

;;;###autoload
(defun gdrive-sync-refresh-folder-cache ()
  "Actualiza asíncronamente las subcarpetas de Google Drive y actualiza la caché persistente."
  (interactive)
  (message "Actualizando caché persistente de carpetas de Google Drive...")
  (let* ((remote-full (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir))
         (cmd (format "rclone lsf %s --dirs-only --recursive" (shell-quote-argument remote-full)))
         (output-buffer (generate-new-buffer " *gdrive-folders-temp* ")))
    (set-process-sentinel
     (start-process-shell-command "gdrive-cache-refresh" output-buffer cmd)
     (lambda (proc event)
       (when (string= event "finished\n")
         (with-current-buffer (process-buffer proc)
           (let ((folders (split-string (buffer-string) "\n" t)))
             (setf (multisession-value gdrive-sync-remote-folders-cache) (cons "/" folders))
             (message "✅ Caché persistente de carpetas de Google Drive actualizada.")))
         (when (buffer-live-p (process-buffer proc))
           (kill-buffer (process-buffer proc))))))))

(defun gdrive-sync--wait-and-open (dir attempts)
  "Espera de forma no bloqueante a que el montaje FUSE esté disponible o aborta tras ATTEMPTS."
  (if (and (file-directory-p dir) (not (directory-empty-p dir)))
      (progn
        (dired dir)
        (message "✅ Google Drive montado de forma fluida."))
    (if (> attempts 0)
        (run-at-time "0.5 sec" nil #'gdrive-sync--wait-and-open dir (1- attempts))
      (message "❌ Error: El montaje FUSE de Google Drive excedió el tiempo límite."))))

;;;###autoload
(defun gdrive-browse-mount ()
  "Monta Google Drive asíncronamente vía FUSE optimizado para 90 GB."
  (interactive)
  (let* ((mount-dir (expand-file-name "~/Drive-Virtual/"))
         (remote-target (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir))
         (already-mounted (and (file-directory-p mount-dir)
                               (not (directory-empty-p mount-dir)))))
    (unless (file-directory-p mount-dir)
      (make-directory mount-dir t))
    (if already-mounted
        (progn
          (message "Google Drive ya está montado localmente. Abriendo Dired...")
          (dired mount-dir))
      (message "Montando Google Drive (90 GB) en segundo plano...")
      (start-process "gdrive-mount-process" nil
                     "rclone" "mount"
                     remote-target mount-dir
                     "--vfs-cache-mode" "full"
                     "--vfs-cache-max-age" "168h"
                     "--vfs-cache-max-size" "20G"
                     "--dir-cache-time" "1000h"
                     "--attr-timeout" "1000h"
                     "--poll-interval" "15s"
                     "--vfs-read-chunk-size" "32M"
                     "--vfs-read-chunk-size-limit" "1G"
                     "--tpslimit" "8")
      (gdrive-sync--wait-and-open mount-dir 10))))

;; ==================================================================
;; --- 4. COMANDOS DE SINCRONIZACIÓN Y DESCARGA ---
;; ==================================================================

;;;###autoload
(defun gdrive-bisync-now (&optional silent)
  "Realiza una sincronización bidireccional rápida."
  (interactive)
  (gdrive-sync--execute "bisync" gdrive-sync-local-dir gdrive-sync-remote-dir "" silent))

;;;###autoload
(defun gdrive-pull-remote-folder (remote-folder-relative)
  "Descarga una carpeta remota elegida de la caché persistente hacia ~/Documentos/."
  (interactive
   (let* ((cached-folders (multisession-value gdrive-sync-remote-folders-cache))
          (_ (when (or (null cached-folders) (equal cached-folders '("/")))
               (gdrive-sync-refresh-folder-cache)))
          (choices (or (multisession-value gdrive-sync-remote-folders-cache) '()))
          (clean-choices (delete "/" (copy-sequence choices)))
          (selection (completing-read "Selecciona la carpeta remota a descargar: "
                                      clean-choices nil t)))
     (list selection)))
  (let* ((clean-folder (replace-regexp-in-string "^/\\|/$" "" remote-folder-relative))
         (local-path (expand-file-name clean-folder gdrive-sync-local-dir))
         (remote-path (concat gdrive-sync-remote-dir "/" clean-folder)))
    (unless (file-exists-p local-path)
      (make-directory local-path t))
    (message "Descargando carpeta remota '%s'..." clean-folder)
    (gdrive-sync--execute "copy" local-path remote-path "")))

;;;###autoload
(defun gdrive-sync-project ()
  "Sincroniza el proyecto actual de Projectile (Local -> Nube)."
  (interactive)
  (if-let ((project-root (projectile-project-root)))
      (if (string-prefix-p (expand-file-name gdrive-sync-local-dir) (expand-file-name project-root))
          (let* ((relative-path (file-relative-name project-root gdrive-sync-local-dir))
                 (remote-project-path (concat gdrive-sync-remote-dir "/" relative-path)))
            (gdrive-sync--execute "sync" project-root remote-project-path ""))
        (user-error "El proyecto no está dentro de ~/Documentos/."))
    (user-error "No estás en un proyecto de Projectile.")))

;;;###autoload
(defun gdrive-bisync-dry-run ()
  "Simula la sincronización sin realizar cambios."
  (interactive)
  (gdrive-sync--execute "bisync" gdrive-sync-local-dir gdrive-sync-remote-dir "--dry-run"))

;;;###autoload
(defun gdrive-sync-specific-folder (folder direction)
  "Sincroniza una carpeta en una dirección específica (Subir o Descargar)."
  (interactive
   (list
    (read-directory-name "Carpeta local a sincronizar: " gdrive-sync-local-dir nil t)
    (completing-read "Dirección: " '("Subir (Local -> Nube)" "Descargar (Nube -> Local)") nil t)))
  (let* ((relative-path (file-relative-name (expand-file-name folder) (expand-file-name gdrive-sync-local-dir)))
         (remote-path (concat gdrive-sync-remote-dir "/" relative-path)))
    (if (string-prefix-p ".." relative-path)
        (user-error "La carpeta seleccionada debe estar dentro de %s" gdrive-sync-local-dir)
      (if (string= direction "Subir (Local -> Nube)")
          (gdrive-sync--execute "sync" folder remote-path "")
        (gdrive-sync--execute "sync" (gdrive-sync--get-full-remote remote-path) folder "")))))

;;;###autoload
(defun gdrive-upload-any-file (file target-folder)
  "Sube un archivo individual libremente a la subcarpeta remota seleccionada."
  (interactive
   (let* ((file-to-upload (read-file-name "Selecciona el archivo a subir: "))
          (cached-folders (multisession-value gdrive-sync-remote-folders-cache))
          (_ (when (or (null cached-folders) (equal cached-folders '("/")))
               (gdrive-sync-refresh-folder-cache)))
          (choices (or (multisession-value gdrive-sync-remote-folders-cache) '("/")))
          (chosen-folder (completing-read "Subcarpeta destino: " choices nil nil)))
     (list file-to-upload chosen-folder)))
  (let* ((clean-target (if (string= target-folder "/") "" (replace-regexp-in-string "^/\\|/$" "" target-folder)))
         (remote-path (if (string= clean-target "")
                          (concat gdrive-sync-remote-dir "/" (file-name-nondirectory file))
                        (concat gdrive-sync-remote-dir "/" clean-target "/" (file-name-nondirectory file))))
         (full-remote-path (gdrive-sync--get-full-remote remote-path))
         (cmd (format "rclone copyto %s %s --progress -v --tpslimit 8"
                      (shell-quote-argument (expand-file-name file))
                      (shell-quote-argument full-remote-path))))
    (message "Subiendo '%s' a '%s'..." (file-name-nondirectory file) remote-path)
    (async-shell-command cmd "*gdrive-upload*")))

;;;###autoload
(defun gdrive-upload-current-file ()
  "Sube individualmente el archivo del buffer actual a la nube."
  (interactive)
  (if-let ((current-file (buffer-file-name)))
      (if (string-prefix-p (expand-file-name gdrive-sync-local-dir) (expand-file-name current-file))
          (let* ((relative-path (file-relative-name current-file gdrive-sync-local-dir))
                 (remote-file-path (concat gdrive-sync-remote-dir "/" relative-path))
                 (full-remote-path (gdrive-sync--get-full-remote remote-file-path))
                 (cmd (format "rclone copyto %s %s --progress -v --tpslimit 8"
                              (shell-quote-argument (expand-file-name current-file))
                              (shell-quote-argument full-remote-path))))
            (message "Subiendo archivo actual a la nube...")
            (async-shell-command cmd "*gdrive-upload*"))
        (user-error "El archivo no está en ~/Documentos/."))
    (user-error "El buffer no está asociado a un archivo.")))

;;;###autoload
(defun gdrive-list-remote ()
  "Muestra los elementos del directorio remoto raíz de forma segura."
  (interactive)
  (gdrive-sync--execute "lsf" "" (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir) "--dir-slash"))

;;;###autoload
(defun gdrive-show-tree ()
  "Genera un árbol visual estructurado de las carpetas de Google Drive."
  (interactive)
  (let ((remote-full (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir)))
    (gdrive-sync--execute "tree" "" remote-full "--dirs-only --max-depth 3")))

;;;###autoload
(defun gdrive-about-quota ()
  "Muestra el espacio total y utilizado en Google Drive."
  (interactive)
  (gdrive-sync--execute "about" "" gdrive-sync-remote-name ""))

;;;###autoload
(defun gdrive-empty-trash ()
  "Vacía la papelera de reciclaje de Google Drive."
  (interactive)
  (when (yes-or-no-p "⚠️ ¿Deseas vaciar la papelera de Google Drive de manera definitiva? ")
    (gdrive-sync--execute "cleanup" "" gdrive-sync-remote-name "")))

;;;###autoload
(defun gdrive-dedupe ()
  "Resuelve interactivamente los duplicados en la nube."
  (interactive)
  (when (y-or-n-p "⚠️ ¿Iniciar proceso de deduplicación (rename)? ")
    (gdrive-sync--execute "dedupe" "" (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir) "rename")))

;; ==================================================================
;; --- 5. MANTENIMIENTO Y EMERGENCIA ---
;; ==================================================================

;;;###autoload
(defun gdrive-bisync-resync-global ()
  "Forzar la inicialización/reparación de la base de datos (--resync)."
  (interactive)
  (if (y-or-n-p "⚠️ ¿Inicializar/Reparar la base de datos de bisync? (--resync) ")
      (gdrive-sync--execute "bisync" gdrive-sync-local-dir gdrive-sync-remote-dir "--resync")
    (message "Operación cancelada.")))

;;;###autoload
(defun gdrive-bisync-resync-project ()
  "Regenera la base de datos de rclone para el proyecto actual."
  (interactive)
  (if-let ((project-root (projectile-project-root)))
      (if (y-or-n-p (format "⚠️ ¿Re-inicializar base de datos (--resync) para %s?"
                            (file-name-nondirectory (directory-file-name project-root))))
          (if (string-prefix-p (expand-file-name gdrive-sync-local-dir) (expand-file-name project-root))
              (let* ((relative-path (file-relative-name project-root gdrive-sync-local-dir))
                     (remote-project-path (concat gdrive-sync-remote-dir "/" relative-path)))
                (gdrive-sync--execute "bisync" project-root remote-project-path "--resync"))
            (user-error "El proyecto no está dentro de ~/Documentos/."))
        (message "Cancelado."))
    (user-error "No estás en un proyecto de Projectile.")))

;;;###autoload
(defun gdrive-force-push-mirror ()
  "Fuerza un espejo Local -> Nube de manera unidireccional."
  (interactive)
  (if (yes-or-no-p "⚠️ PELIGRO: Esto modificará la nube para hacerla idéntica a tu PC local. ¿Continuar? ")
      (gdrive-sync--execute "sync" gdrive-sync-local-dir gdrive-sync-remote-dir "")
    (message "Operación cancelada.")))

;;;###autoload
(defun gdrive-force-pull-mirror ()
  "Fuerza un espejo Nube -> Local de manera unidireccional."
  (interactive)
  (if (yes-or-no-p "⚠️ PELIGRO: Esto modificará tu PC local para hacerla idéntica a la nube. ¿Continuar? ")
      (gdrive-sync--execute "sync" (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir) gdrive-sync-local-dir "")
    (message "Operación cancelada.")))

;;;###autoload
(defun gdrive-bisync-force-unlock ()
  "Elimina a la fuerza los archivos de bloqueo (.lck) activos."
  (interactive)
  (let* ((possible-dirs (list (expand-file-name "~/.cache/rclone/bisync/")
                              (expand-file-name "~/.config/rclone/bisync/")))
         (lock-files nil))
    (dolist (dir possible-dirs)
      (when (file-directory-p dir)
        (dolist (file (directory-files dir t "\\.lck$"))
          (push file lock-files))))
    (if (null lock-files)
        (message "No se encontraron candados (.lck) activos.")
      (dolist (lock lock-files)
        (delete-file lock)
        (message "✅ Candado %s eliminado." (file-name-nondirectory lock))))))

;;;###autoload
(defun gdrive-check-status ()
  "Chequeo no destructivo mediante `rclone check`."
  (interactive)
  (gdrive-sync--execute "check" gdrive-sync-local-dir gdrive-sync-remote-dir ""))

;;;###autoload
(defun gdrive-resolve-conflicts ()
  "Busca archivos con extensión `.conflict` generados por rclone y los procesa vía Ediff."
  (interactive)
  (let ((conflict-files (directory-files-recursively gdrive-sync-local-dir "\\.conflict\\|conflict_")))
    (if (null conflict-files)
        (message "No se encontraron archivos de conflicto en el directorio local.")
      (let* ((file-to-resolve (completing-read "Conflicto a resolver: " conflict-files nil t))
             (original-file (replace-regexp-in-string "\\.conflict.*$\\|_conflict.*$" "" file-to-resolve)))
        (if (file-exists-p original-file)
            (ediff-files original-file file-to-resolve)
          (message "No se encontró el archivo original correspondiente: %s" original-file))))))

;;;###autoload
(defun gdrive-purge-latex-aux ()
  "Purga los archivos auxiliares de LaTeX locales para optimizar los tiempos de transferencia."
  (interactive)
  (if (y-or-n-p "🧹 ¿Purgar todos los archivos auxiliares de LaTeX en tu directorio local? ")
      (let ((count 0)
            (aux-regex "\\.\\(aux\\|log\\|toc\\|lof\\|lot\\|fls\\|fdb_latexmk\\|synctex\\.gz\\|bbl\\|bcf\\|blg\\|out\\|run\\.xml\\|idx\\|ind\\|ilg\\)$"))
        (dolist (file (directory-files-recursively gdrive-sync-local-dir aux-regex))
          (delete-file file)
          (setq count (1+ count)))
        (message "✅ Purgado completado: %d archivos auxiliares eliminados." count))
    (message "Operación de purgado cancelada.")))

;; ==================================================================
;; --- 6. DISPARADORES AUTOMÁTICOS Y BLINDAJE INTELIGENTE DE SALIDA ---
;; ==================================================================

(defvar gdrive-sync--local-dirty nil
  "Bandera local que indica si hay archivos modificados pendientes de subir.")

(defvar gdrive-sync--modified-files-list nil
  "Lista de archivos modificados durante la sesión actual para subida rápida.")

(defun gdrive-sync--mark-local-dirty ()
  "Marca el estado como modificado localmente y registra el archivo editado."
  (when-let ((file (buffer-file-name)))
    (when (string-prefix-p (expand-file-name gdrive-sync-local-dir)
                           (expand-file-name file))
      (setq gdrive-sync--local-dirty t)
      (add-to-list 'gdrive-sync--modified-files-list file))))

(add-hook 'after-save-hook #'gdrive-sync--mark-local-dirty)

(defcustom gdrive-sync-auto-interval 180
  "Intervalo en segundos para comprobar disparadores automáticos."
  :type 'integer
  :group 'gdrive-sync)

(defun gdrive-sync-online-p ()
  "Comprueba si hay conectividad activa a la red (no bloqueante)."
  (with-timeout (2 nil)
    (zerop (call-process "ping" nil nil nil "-c" "1" "-W" "1" "1.1.1.1"))))

;;;###autoload
(defun gdrive-sync-smart-trigger (&optional quiet)
  "Evalúa cambios locales y remotos dinámicamente antes de sincronizar."
  (interactive)
  (when (gdrive-sync-online-p)
    (cond
     (gdrive-sync--local-dirty
      (message "🔄 GDrive: Disparador local activado. Sincronizando de fondo...")
      (setq gdrive-sync--local-dirty nil)
      (setq gdrive-sync--modified-files-list nil)
      (gdrive-bisync-now t))
     (t
      (let* ((interval-mins (ceiling (/ gdrive-sync-auto-interval 60.0)))
             (remote-full (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir))
             (cmd (format "rclone lsf %s --max-age %dm --recursive"
                          (shell-quote-argument remote-full)
                          interval-mins))
             (output-buffer (generate-new-buffer " *gdrive-check-remote* ")))
        (set-process-sentinel
         (start-process-shell-command "gdrive-check-remote" output-buffer cmd)
         (lambda (proc event)
           (when (string= event "finished\n")
             (with-current-buffer (process-buffer proc)
               (let ((has-remote-changes (not (string-empty-p (string-trim (buffer-string))))))
                 (if has-remote-changes
                     (progn
                       (message "☁️ GDrive: Disparador remoto activado. Sincronizando...")
                       (gdrive-bisync-now t))
                   (unless quiet
                     (message "💤 GDrive: Sin cambios. Bisincronización omitida."))))))
           (when (buffer-live-p (process-buffer proc))
             (kill-buffer (process-buffer proc))))))))))

(defvar gdrive-sync-auto-timer nil)

;;;###autoload
(define-minor-mode gdrive-sync-auto-mode
  "Modo global para sincronización automática mediante disparadores dinámicos."
  :global t
  :init-value nil
  (if gdrive-sync-auto-mode
      (progn
        (when gdrive-sync-auto-timer
          (cancel-timer gdrive-sync-auto-timer))
        (setq gdrive-sync-auto-timer
              (run-at-time 60 gdrive-sync-auto-interval
                           (lambda () (gdrive-sync-smart-trigger t))))
        (message "🤖 GDrive: Sincronización automática de fondo activada."))
    (when gdrive-sync-auto-timer
      (cancel-timer gdrive-sync-auto-timer)
      (setq gdrive-sync-auto-timer nil))
    (message "🤖 GDrive: Sincronización automática desactivada.")))

;; --- CONTROL INTELIGENTE AL SALIR DE EMACS ---
(add-hook 'kill-emacs-hook
          (lambda ()
            (when (and (bound-and-true-p gdrive-sync--local-dirty)
                       (executable-find "rclone"))
              (pcase gdrive-sync-on-exit-strategy
                ('prompt
                 (when (y-or-n-p "🔄 GDrive: Tienes cambios locales pendientes. ¿Sincronizar antes de salir? ")
                   (message "⏳ Sincronizando antes de salir...")
                   (call-process "rclone" nil nil nil "bisync"
                                 (expand-file-name gdrive-sync-local-dir)
                                 (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir))))
                ('async
                 (message "🚀 GDrive: Sincronización lanzada en segundo plano...")
                 (call-process-shell-command
                  (format "nohup rclone bisync %s %s >/dev/null 2>&1 &"
                          (shell-quote-argument (expand-file-name gdrive-sync-local-dir))
                          (shell-quote-argument (format "%s:%s" gdrive-sync-remote-name gdrive-sync-remote-dir)))))
                ('fast
                 (message "⚡ GDrive: Subiendo únicamente archivos editados...")
                 (dolist (file gdrive-sync--modified-files-list)
                   (when (file-exists-p file)
                     (let* ((rel (file-relative-name file gdrive-sync-local-dir))
                            (remote (format "%s:%s/%s" gdrive-sync-remote-name gdrive-sync-remote-dir rel)))
                       (call-process "rclone" nil nil nil "copyto" (expand-file-name file) remote)))))
                (_ nil)))))

(provide 'gdrive-sync)
;;; gdrive-sync.el ends here