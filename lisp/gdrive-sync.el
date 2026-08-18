;;; gdrive-sync.el --- Sincronización Inteligente, Persistente y Rápida -*- lexical-binding: t; -*-

(require 'projectile)
(require 'consult)
(require 'multisession)
(require 'subr-x)

(defgroup gdrive-sync nil
  "Configuración de sincronización con Google Drive."
  :group 'tools
  :prefix "gdrive-sync/")

;; ==================================================================
;; --- 1. CONFIGURACIÓN Y PERSISTENCIA DE CACHÉ ---
;; ==================================================================

(defcustom gdrive-sync/remote-name "GoogleDrive-Documentos_Ubuntu_Fayfer"
  "Nombre exacto del remote en rclone."
  :type 'string
  :group 'gdrive-sync)

(defcustom gdrive-sync/local-dir (expand-file-name "~/Documentos/")
  "Directorio local raíz."
  :type 'directory
  :group 'gdrive-sync)

(defcustom gdrive-sync/remote-dir "Documentos-Ubuntu-Fayfer"
  "Carpeta destino dentro del remote."
  :type 'string
  :group 'gdrive-sync)

(defcustom gdrive-sync/filter-file (expand-file-name "~/.config/rclone/rclone-filters.txt")
  "Archivo de filtros para ignorar archivos basura (.elc, .git, etc.)."
  :type 'file
  :group 'gdrive-sync)

(defcustom gdrive-sync/on-exit-strategy 'prompt
  "Estrategia de sincronización al salir de Emacs."
  :type '(choice (const :tag "Preguntar si hay cambios" prompt)
                 (const :tag "Segundo plano (nohup)" async)
                 (const :tag "Subida rápida de editados" fast)
                 (const :tag "Desactivar" nil))
  :group 'gdrive-sync)

(define-multisession-variable gdrive-sync--remote-folders-cache '("/")
  "Caché persistente de carpetas de GDrive."
  :synchronized t)

(defvar gdrive-sync--modified-files-in-session nil
  "Lista de archivos modificados en la sesión actual que están dentro del directorio de sincronización.")

(defun gdrive-sync--get-full-remote (path)
  "Construye la ruta remota completa para rclone (ej. Remote:Ruta)."
  (format "%s:%s" gdrive-sync/remote-name path))

(defun gdrive-sync--track-modified-file ()
  "Añade el archivo actual a la lista de modificados si está en el dir de sync."
  (when (and buffer-file-name
             (string-prefix-p (expand-file-name gdrive-sync/local-dir)
                              (expand-file-name buffer-file-name)))
    (add-to-list 'gdrive-sync--modified-files-in-session buffer-file-name)))

(add-hook 'after-save-hook #'gdrive-sync--track-modified-file)

;; ==================================================================
;; --- 2. MOTOR DE SINCRONIZACIÓN SEGURO Y ASÍNCRONO ---
;; ==================================================================

(defun gdrive-sync--execute (command-type args &optional silent)
  "Ejecuta un comando rclone de forma segura y asíncrona usando una lista de argumentos."
  (unless (executable-find "rclone")
    (user-error "El comando 'rclone' no se encuentra en tu sistema."))

  (let* ((base-flags '("--progress" "-v" "--drive-acknowledge-abuse" "--fast-list" "--tpslimit" "8"))
         (sync-flags '("--transfers" "8" "--checkers" "16" "--track-renames"))
         (use-filter (not (member command-type '("cleanup" "about" "dedupe" "lsf" "tree"))))
         (filter-flags (when (and use-filter (file-exists-p gdrive-sync/filter-file))
                         (list "--filter-from" gdrive-sync/filter-file)))
         (remote-full (gdrive-sync--get-full-remote gdrive-sync/remote-dir))
         
         ;; Utilizamos 'append' y strings puros para evitar errores de tipo en make-process
         (command-args (pcase command-type
                         ("bisync" (append (list "bisync" gdrive-sync/local-dir remote-full)
                                           sync-flags base-flags filter-flags args))
                         ("cleanup" (append (list "cleanup" remote-full) base-flags args))
                         ((or "sync" "copy" "copyto") (append (list command-type) args sync-flags base-flags filter-flags))
                         (_ (append (list command-type) args))))
                         
         (output-buffer (generate-new-buffer (format "*gdrive-%s-output*" command-type))))

    (unless silent
      (display-buffer output-buffer))
    (message "Iniciando rclone %s..." command-type)

    (let ((process (make-process
                    :name (format "gdrive-%s" command-type)
                    :buffer output-buffer
                    :command (cons (executable-find "rclone") command-args)
                    :sentinel
                    (lambda (proc event)
                      (cond
                       ((string= event "finished\n")
                        (message "✅ rclone %s: completado." command-type)
                        (when (and silent (buffer-live-p output-buffer))
                          (kill-buffer output-buffer)))
                       ((string-match-p "exited abnormally" event)
                        (message "❌ rclone %s: error. Revisa el buffer %s" command-type (buffer-name output-buffer))
                        (unless silent (display-buffer output-buffer))))))))
      process)))


;; ==================================================================
;; --- 3. CACHÉ PERSISTENTE Y MONTAJE FUSE ---
;; ==================================================================

(defcustom gdrive-sync/mount-dir (expand-file-name "~/GoogleDrive/")
  "Directorio local de montaje FUSE para Google Drive."
  :type 'directory
  :group 'gdrive-sync)

;;;###autoload
(defun gdrive-sync/browse-remote (&optional remote-subpath)
  "Abre Dired directamente en Google Drive usando TRAMP (método rclone)."
  (interactive
   (let* ((cached-folders (when (boundp 'gdrive-sync--remote-folders-cache)
                            (multisession-value gdrive-sync--remote-folders-cache)))
          (rsub (completing-read "Navegar a carpeta en Google Drive: "
                                 (or cached-folders '("/"))
                                 nil nil nil nil "/")))
     (list rsub)))
  (let* ((clean-sub (string-trim (or remote-subpath "") "/" "/"))
         (tramp-path (format "/rclone:%s:%s"
                             gdrive-sync/remote-name
                             (if (string-empty-p clean-sub) "" clean-sub))))
    (message "📂 Abriendo Dired en %s..." tramp-path)
    (dired tramp-path)))

;;;###autoload
(defun gdrive-sync/navigate-remote ()
  "Navega paso a paso por la jerarquía de carpetas de Google Drive."
  (interactive)
  (let ((current-path "")
        (done nil))
    (while (not done)
      (let* ((remote-full (gdrive-sync--get-full-remote current-path))
             (prompt (format "GDrive [%s/]: " (if (string-empty-p current-path) "Raíz" current-path)))
             (subdirs (condition-case nil
                          (process-lines (executable-find "rclone") "lsf" remote-full "--dirs-only")
                        (error nil)))
             (actions '("[📂 Abrir en Dired aquí]"
                        "[📥 Sincronizar esta carpeta hacia Local]"
                        "[📤 Sincronizar Local hacia esta carpeta]"
                        "[⬆️ Subir un nivel]"))
             (candidates (append actions subdirs))
             (choice (completing-read prompt candidates nil t)))
        (cond
         ((string= choice "[📂 Abrir en Dired aquí]")
          (gdrive-sync/browse-remote current-path)
          (setq done t))
         ((string= choice "[📥 Sincronizar esta carpeta hacia Local]")
          (gdrive-sync/sync-remote-to-local current-path)
          (setq done t))
         ((string= choice "[📤 Sincronizar Local hacia esta carpeta]")
          (gdrive-sync/sync-local-to-remote nil current-path)
          (setq done t))
         ((string= choice "[⬆️ Subir un nivel]")
          (setq current-path (file-name-directory (directory-file-name current-path)))
          (when (or (null current-path) (string= current-path "./"))
            (setq current-path "")))
         (t
          (setq current-path (concat current-path choice))))))))

;;;###autoload
(defun gdrive-sync/mount-remote ()
  "Monta Google Drive en `gdrive-sync/mount-dir` vía FUSE y abre Dired."
  (interactive)
  (unless (executable-find "rclone")
    (user-error "rclone no está instalado"))
  (unless (file-directory-p gdrive-sync/mount-dir)
    (make-directory gdrive-sync/mount-dir t))
  (let ((remote-full (format "%s:" gdrive-sync/remote-name)))
    (if (and (file-directory-p gdrive-sync/mount-dir)
             (directory-files gdrive-sync/mount-dir nil "^[^.]"))
        (progn
          (message "✅ Google Drive ya está montado en %s" gdrive-sync/mount-dir)
          (dired gdrive-sync/mount-dir))
      (message "🚀 Montando Google Drive (%s ➔ %s)..." remote-full gdrive-sync/mount-dir)
      (make-process
       :name "gdrive-mount"
       :buffer "*gdrive-mount-output*"
       :command (list (executable-find "rclone") "mount" remote-full gdrive-sync/mount-dir
                      "--vfs-cache-mode" "full"
                      "--vfs-cache-max-age" "24h"
                      "--daemon")
       :sentinel
       (lambda (_proc event)
         (when (string-match-p "finished" event)
           (message "✅ Google Drive montado con éxito en %s" gdrive-sync/mount-dir)
           (dired gdrive-sync/mount-dir)))))))

;;;###autoload
(defun gdrive-sync/unmount-remote ()
  "Desmonta Google Drive del directorio local."
  (interactive)
  (if (executable-find "fusermount")
      (progn
        (call-process "fusermount" nil nil nil "-u" (expand-file-name gdrive-sync/mount-dir))
        (message "✅ Google Drive desmontado de %s" gdrive-sync/mount-dir))
    (user-error "El comando 'fusermount' no está disponible en tu sistema")))

;;;###autoload
(defun gdrive-sync--fetch-remote-folders-sync (&optional from-root)
  "Obtiene de forma síncrona la lista de carpetas en Google Drive y actualiza la caché."
  (let* ((target-dir (if from-root "" gdrive-sync/remote-dir))
         (remote-full (gdrive-sync--get-full-remote target-dir))
         (args (list "lsf" remote-full "--dirs-only" "--recursive" "--fast-list")))
    (message "🔍 Escaneando carpetas en Google Drive (%s)..." remote-full)
    (condition-case err
        (let ((output (apply #'process-lines (executable-find "rclone") args)))
          (setf (multisession-value gdrive-sync--remote-folders-cache) (cons "/" output))
          (message "✅ %d carpetas obtenidas de Google Drive." (length output))
          (cons "/" output))
      (error
       (message "❌ Error al obtener carpetas: %s" (error-message-string err))
       '("/")))))

;;;###autoload
(defun gdrive-sync/refresh-folder-cache (&optional root-remote)
  "Actualiza asíncronamente la caché de carpetas de Google Drive.
Con prefijo C-u (ROOT-REMOTE non-nil), escanea desde la raíz del remote en lugar de `gdrive-sync/remote-dir`."
  (interactive "P")
  (message "Actualizando caché de carpetas de Google Drive...")
  (let* ((target-dir (if root-remote "" gdrive-sync/remote-dir))
         (remote-full (gdrive-sync--get-full-remote target-dir))
         (process (gdrive-sync--execute "lsf" (list remote-full "--dirs-only" "--recursive" "--fast-list") t))
         (output-buffer (process-buffer process)))
    (set-process-sentinel
     process
     (lambda (proc event)
       (when (string= event "finished\n")
         (with-current-buffer output-buffer
           (let ((folders (split-string (buffer-string) "\n" t)))
             (setf (multisession-value gdrive-sync--remote-folders-cache) (cons "/" folders))
             (message "✅ Caché de carpetas actualizada (%d carpetas encontradas)." (length folders))))
         (kill-buffer output-buffer))))))

;; ==================================================================
;; --- 4. COMANDOS DE SINCRONIZACIÓN PRINCIPALES ---
;; ==================================================================

;;;###autoload
(defun gdrive-sync/bisync-now (&optional silent)
  "Ejecuta la sincronización bidireccional (bisync) inmediatamente."
  (interactive)
  (gdrive-sync--execute "bisync" nil silent))

;;;###autoload
(defun gdrive-sync/upload-modified ()
  "Sube únicamente los archivos modificados en la sesión actual."
  (interactive)
  (if-let (modified-files (seq-uniq gdrive-sync--modified-files-in-session))
      (progn
        (message "Subiendo %d archivos modificados..." (length modified-files))
        (dolist (file modified-files)
          (let* ((relative-path (file-relative-name file gdrive-sync/local-dir))
                 (remote-path (concat gdrive-sync/remote-dir "/" relative-path)))
            (gdrive-sync--execute "copyto" (list file (gdrive-sync--get-full-remote remote-path)) t)))
        (setq gdrive-sync--modified-files-in-session nil))
    (message "No hay archivos modificados para subir.")))

;;;###autoload
(defun gdrive-sync/sync-local-to-remote (&optional local-dir remote-subpath copy-only)
  "Sincroniza una carpeta local hacia Google Drive (Local ➔ Remoto).
Si COPY-ONLY es no-nil (o con prefijo C-u), usa `rclone copy` en lugar de `rclone sync`."
  (interactive
   (let* ((default-dir (or (and buffer-file-name (file-name-directory buffer-file-name))
                           gdrive-sync/local-dir))
          (ldir (read-directory-name "Carpeta local a sincronizar: " default-dir default-dir t))
          (rel (file-relative-name (expand-file-name ldir) (expand-file-name gdrive-sync/local-dir)))
          (default-remote-sub (if (string-prefix-p ".." rel)
                                  ""
                                (string-trim-right rel "/")))
          (rsub (read-string (format "Ruta relativa en remoto (dentro de '%s'): " gdrive-sync/remote-dir)
                             default-remote-sub))
          (copy (or current-prefix-arg
                    (not (y-or-n-p "⚠️ ¿Usar `sync` (hacer espejo exacto borrando lo sobrante en remoto)? ('n' usará `copy`): ")))))
     (list ldir rsub copy)))
  (let* ((local-path (expand-file-name local-dir))
         (clean-rsub (string-trim (or remote-subpath "") "/" "/"))
         (remote-rel (if (string-empty-p clean-rsub)
                         gdrive-sync/remote-dir
                       (concat (string-trim-right gdrive-sync/remote-dir "/") "/" clean-rsub)))
         (remote-full (gdrive-sync--get-full-remote remote-rel))
         (cmd-type (if copy-only "copy" "sync")))
    (when (y-or-n-p (format "¿Ejecutar rclone %s de [%s] ➔ [%s]? " cmd-type local-path remote-full))
      (gdrive-sync--execute cmd-type (list local-path remote-full)))))

;;;###autoload
(defun gdrive-sync/sync-remote-to-local (&optional remote-subpath local-dir copy-only)
  "Sincroniza o descarga una carpeta desde Google Drive hacia local (Remoto ➔ Local).
Muestra todas las carpetas disponibles en Google Drive.
Si la caché está vacía o se usa C-u (prefijo), escanea las carpetas en remoto antes de seleccionar."
  (interactive
   (let* ((force-refresh current-prefix-arg)
          (cached-raw (unless force-refresh
                        (when (boundp 'gdrive-sync--remote-folders-cache)
                          (multisession-value gdrive-sync--remote-folders-cache))))
          ;; Si la caché está vacía o solo tiene "/", escanear remoto síncronamente desde la raíz
          (folders (if (or force-refresh (null cached-raw) (equal cached-raw '("/")) (equal cached-raw '("")))
                       (gdrive-sync--fetch-remote-folders-sync t)
                     cached-raw))
          (root-opt "[ / ] (Toda la raíz de Google Drive)")
          (main-opt (format "[ %s/ ] (Carpeta principal)" gdrive-sync/remote-dir))
          (refresh-opt "[🔄 Refrescar lista de carpetas desde GDrive]")
          (candidates (append (list root-opt main-opt refresh-opt)
                              (delete-dups (copy-sequence folders))))
          (selected-rsub (completing-read "Selecciona carpeta en Google Drive: "
                                          candidates nil nil nil nil nil)))
     
     ;; Si se seleccionó la opción de refrescar explícitamente
     (when (string= selected-rsub refresh-opt)
       (setq folders (gdrive-sync--fetch-remote-folders-sync t))
       (setq candidates (append (list root-opt main-opt refresh-opt)
                                (delete-dups (copy-sequence folders))))
       (setq selected-rsub (completing-read "Selecciona carpeta en Google Drive: "
                                            candidates nil nil nil nil nil)))

     (let* ((clean-rsub (cond
                         ((string= selected-rsub root-opt) "")
                         ((string= selected-rsub main-opt) gdrive-sync/remote-dir)
                         (t (string-trim selected-rsub "/" "/"))))
            ;; Calcular ruta local predeterminada inteligente
            (rel-local-sub (cond
                            ((string-empty-p clean-rsub) "")
                            ((string= clean-rsub gdrive-sync/remote-dir) "")
                            ((string-prefix-p (concat gdrive-sync/remote-dir "/") clean-rsub)
                             (substring clean-rsub (1+ (length gdrive-sync/remote-dir))))
                            (t clean-rsub)))
            (default-local (if (string-empty-p rel-local-sub)
                               gdrive-sync/local-dir
                             (expand-file-name rel-local-sub gdrive-sync/local-dir)))
            ;; Permitir libre navegación a carpetas padre
            (base-dir (file-name-directory (directory-file-name default-local)))
            (ldir (read-directory-name (format "Carpeta local destino [%s]: " (abbreviate-file-name default-local))
                                       (or base-dir "~/") default-local nil))
            (copy (not (y-or-n-p "⚠️ ¿Usar `sync` (hacer espejo exacto borrando lo sobrante en local)? ('n' usará `copy`): "))))
       (list clean-rsub ldir copy))))
  (let* ((clean-rsub (string-trim (or remote-subpath "") "/" "/"))
         (remote-rel (cond
                      ((string-empty-p clean-rsub)
                       gdrive-sync/remote-dir)
                      ((or (string= clean-rsub gdrive-sync/remote-dir)
                           (string-prefix-p (concat gdrive-sync/remote-dir "/") clean-rsub))
                       clean-rsub)
                      (t
                       (concat (string-trim-right gdrive-sync/remote-dir "/") "/" clean-rsub))))
         (remote-full (gdrive-sync--get-full-remote remote-rel))
         (local-path (expand-file-name local-dir))
         (cmd-type (if copy-only "copy" "sync")))
    (unless (file-exists-p local-path)
      (make-directory local-path t))
    (when (y-or-n-p (format "¿Ejecutar rclone %s de [%s] ➔ [%s]? " cmd-type remote-full local-path))
      (gdrive-sync--execute cmd-type (list remote-full local-path)))))

;;;###autoload
(defun gdrive-sync/upload-current-file ()
  "Sube el archivo del buffer actual a Google Drive (Local ➔ Remoto)."
  (interactive)
  (unless buffer-file-name
    (user-error "El buffer actual no está visitando ningún archivo"))
  (when (buffer-modified-p)
    (when (y-or-n-p "El buffer ha sido modificado. ¿Guardar antes de subir? ")
      (save-buffer)))
  (let* ((file buffer-file-name)
         (local-base (expand-file-name gdrive-sync/local-dir))
         (rel-path (if (string-prefix-p local-base (expand-file-name file))
                       (file-relative-name file local-base)
                     (file-name-nondirectory file)))
         (remote-path (concat (string-trim-right gdrive-sync/remote-dir "/") "/" rel-path))
         (remote-full (gdrive-sync--get-full-remote remote-path)))
    (when (y-or-n-p (format "¿Subir %s ➔ %s? " (file-name-nondirectory file) remote-full))
      (gdrive-sync--execute "copyto" (list file remote-full)))))

;;;###autoload
(defun gdrive-sync/download-remote-file (remote-file-path local-dest-path)
  "Descarga un archivo específico desde Google Drive hacia local (Remoto ➔ Local)."
  (interactive
   (let* ((rfile (read-string "Ruta relativa del archivo en remoto: "))
          (clean-rfile (string-trim-left rfile "/"))
          (default-local (expand-file-name clean-rfile gdrive-sync/local-dir))
          (ldest (read-file-name "Destino del archivo local: "
                                 (file-name-directory default-local)
                                 default-local nil
                                 (file-name-nondirectory default-local))))
     (list rfile ldest)))
  (let* ((clean-rfile (string-trim-left remote-file-path "/"))
         (remote-full (gdrive-sync--get-full-remote
                       (concat (string-trim-right gdrive-sync/remote-dir "/") "/" clean-rfile)))
         (local-full (expand-file-name local-dest-path)))
    (unless (file-exists-p (file-name-directory local-full))
      (make-directory (file-name-directory local-full) t))
    (when (y-or-n-p (format "¿Descargar %s ➔ %s? " remote-full local-full))
      (gdrive-sync--execute "copyto" (list remote-full local-full)))))


;; ==================================================================
;; --- 5. MANTENIMIENTO Y EMERGENCIA ---
;; ==================================================================

;;;###autoload
(defun gdrive-sync/bisync-resync-global ()
  "Forzar la inicialización/reparación de la base de datos (--resync)."
  (interactive)
  (when (yes-or-no-p "⚠️ ¿Inicializar/Reparar la base de datos de bisync? (--resync) ")
    (gdrive-sync--execute "bisync" (list "--resync"))))

;;;###autoload
(defun gdrive-sync/force-unlock ()
  "Elimina a la fuerza los archivos de bloqueo (.lck) activos."
  (interactive)
  (let* ((possible-dirs (list (expand-file-name "~/.cache/rclone/bisync/")
                              (expand-file-name "~/.config/rclone/bisync/")))
         (lock-files (cl-loop for dir in possible-dirs
                              when (file-directory-p dir)
                              append (directory-files dir t "\\.lck$"))))
    (if (null lock-files)
        (message "No se encontraron candados (.lck) activos.")
      (dolist (lock lock-files)
        (delete-file lock)
        (message "✅ Candado %s eliminado." (file-name-nondirectory lock))))))

;;;###autoload
(defun gdrive-sync/resolve-conflicts ()
  "Busca y resuelve archivos de conflicto generados por rclone vía Ediff."
  (interactive)
  (let ((conflict-files (directory-files-recursively gdrive-sync/local-dir "\\.conflict\\|conflict_")))
    (if (null conflict-files)
        (message "No se encontraron archivos de conflicto.")
      (let* ((file-to-resolve (completing-read "Conflicto a resolver: " conflict-files nil t))
             (original-file (replace-regexp-in-string "\\.conflict.*$\\|_conflict.*$" "" file-to-resolve)))
        (if (file-exists-p original-file)
            (ediff-files original-file file-to-resolve)
          (user-error "No se encontró el archivo original: %s" original-file))))))

;; ==================================================================
;; --- 6. GESTIÓN DE LA SESIÓN Y SALIDA DE EMACS ---
;; ==================================================================

(defun gdrive-sync--on-exit-handler ()
  "Maneja la sincronización al salir de Emacs según la estrategia configurada."
  (when (and (executable-find "rclone") gdrive-sync--modified-files-in-session)
    (pcase gdrive-sync/on-exit-strategy
      ('prompt
       (when (yes-or-no-p "Hay archivos modificados. ¿Sincronizar con Google Drive antes de salir? ")
         (gdrive-sync/bisync-now t)))
      ('async
       (message "Cerrando Emacs y lanzando sincronización en segundo plano...")
       (apply #'process-file (executable-find "rclone") nil nil nil
              (list "bisync" gdrive-sync/local-dir (gdrive-sync--get-full-remote gdrive-sync/remote-dir)
                    "--log-file=/tmp/rclone-exit.log")))
      ('fast (gdrive-sync/upload-modified)))))

(add-hook 'kill-emacs-hook #'gdrive-sync--on-exit-handler)

;; ==================================================================
;; --- 7. MENÚ INTERACTIVO (TRANSIENT) ---
;; ==================================================================

(defun gdrive-sync--transient-title ()
  "Genera un título dinámico y elegante para el menú Transient."
  (format "☁️  Google Drive Sync  |  Remote: %s  |  Local: %s"
          (propertize gdrive-sync/remote-name 'face 'font-lock-keyword-face)
          (propertize (abbreviate-file-name gdrive-sync/local-dir) 'face 'font-lock-string-face)))

;;;###autoload
(transient-define-prefix gdrive-sync-transient/body ()
  "Menú interactivo para gestionar la sincronización con Google Drive."
  [:description gdrive-sync--transient-title
   ["📁 Navegación & Exploración"
    ("n" "Navegar Google Drive (Dired TRAMP)" gdrive-sync/browse-remote)
    ("i" "Explorador Interactivo (Paso a Paso)" gdrive-sync/navigate-remote)
    ("m" "Montar Google Drive (FUSE)" gdrive-sync/mount-remote)
    ("M" "Desmontar Google Drive" gdrive-sync/unmount-remote)]
   ["🔄 Bidireccional (Global)"
    ("b" "Sincronizar Todo (bisync)" gdrive-sync/bisync-now)
    ("u" "Subir Editados en Sesión" gdrive-sync/upload-modified)]
   ["📤 Local ➔ Remoto"
    ("s" "Carpeta Local ➔ Remoto" gdrive-sync/sync-local-to-remote)
    ("f" "Subir Archivo Actual" gdrive-sync/upload-current-file)]
   ["📥 Remoto ➔ Local"
    ("d" "Carpeta Remota ➔ Local" gdrive-sync/sync-remote-to-local)
    ("D" "Descargar Archivo Remoto" gdrive-sync/download-remote-file)]]
  ["🛠️  Mantenimiento y Diagnóstico"
   ["🔧 Reparación & Candados"
    ("r" "Forzar Resincronización (--resync)" gdrive-sync/bisync-resync-global)
    ("l" "Eliminar Candados (.lck)" gdrive-sync/force-unlock)]
   ["⚡ Conflictos & Caché"
    ("c" "Resolver Conflictos (Ediff)" gdrive-sync/resolve-conflicts)
    ("R" "Refrescar Caché de Carpetas" gdrive-sync/refresh-folder-cache)]])

(defvar gdrive-sync-transient/body #'gdrive-sync-transient/body
  "Variable defensiva para gdrive-sync-transient/body.")

(provide 'gdrive-sync)
;;; gdrive-sync.el ends here