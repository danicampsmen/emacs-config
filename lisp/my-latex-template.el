;;; my-latex-template.el --- Template dinámico para apuntes-scr.cls -*- lexical-binding: t; -*-

;; =========================================================
;; Módulo: Template interactivo para la clase apuntes-scr.cls
;; Arquitectura: Bourbaki / IHÉS / EGA — LuaLaTeX
;; =========================================================

(require 'transient)
(require 'cl-lib)

;; ------------------------------------------------------------------
;; 1. ESTADO INTERNO DEL TEMPLATE
;; ------------------------------------------------------------------

(defvar my/template-state nil
  "Plist con el estado actual del template apuntes-scr que se está construyendo.")

(defun my/template-reset-state ()
  "Reinicia el estado interno del template a los valores por defecto de apuntes-scr."
  (setq my/template-state
        (list
         ;; === CLASE Y OPCIONES CORE ===
         :doc-type        "book"      ; "book" | "article"
         :estilo          "bourbaki"  ; "bourbaki" | "ihes" | "ega" | "bonn"
         :idioma          "spanish"   ; "spanish" | "english" | "french" | "german"
         :citas           "alphabetic"; "alphabetic" | "ieee" | "apa" | "numeric"
         :fast-mode       nil         ; t | nil

         ;; === METADATOS DEL DOCUMENTO ===
         :title           ""
         :short-title     ""         ; Título corto para encabezados
         :author          ""
         :short-author    ""         ; Autor corto para PDF metadata
         :date            "\\today"
         :email           ""
         :orcid           ""
         :version         ""

         ;; === CONTEXTO ACADÉMICO ===
         :universidad     ""
         :facultad        ""
         :curso           ""
         :codigo          ""         ; Código del curso
         :semestre        ""
         :profesor        ""
         :asistente       ""         ; Jefe de Prácticas
         :lugar           ""

         ;; === CONTENIDO Y REFERENCIAS ===
         :referencias     ""         ; Bibliografía principal (portada)
         :logo            ""         ; Ruta al logo (.pdf, .png)
         :bib-file        ""         ; Archivo .bib

         ;; === ESTRUCTURA DEL DOCUMENTO ===
         :with-toc        t          ; Tabla de contenidos
         :with-index      nil        ; Índice analítico
         :with-bibliography t        ; Bibliografía al final
         :toc-depth       2          ; Profundidad de la ToC

         ;; === CONTENIDO INICIAL ===
         :body-content    "intro"    ; "intro" | "chapter" | "section" | "blank"
         )))

;; ------------------------------------------------------------------
;; 2. ACCESORES DEL ESTADO
;; ------------------------------------------------------------------

(defun my/tpl-get (key)
  "Obtiene el valor de KEY en el estado del template."
  (plist-get my/template-state key))

(defun my/tpl-set (key value)
  "Establece VALUE para KEY en el estado del template."
  (setq my/template-state (plist-put my/template-state key value)))

(defun my/tpl-toggle (key)
  "Alterna el valor booleano de KEY en el estado del template."
  (my/tpl-set key (not (my/tpl-get key))))

;; ------------------------------------------------------------------
;; 3. FUNCIONES DE LECTURA INTERACTIVA
;; ------------------------------------------------------------------

(defun my/tpl-read-string (key prompt &optional default)
  "Lee un string para KEY con PROMPT. Usa DEFAULT como valor actual."
  (let* ((current (or (my/tpl-get key) default ""))
         (display-current (if (string-empty-p current) "vacío" current))
         (new-val (read-string
                   (format "%s [actual: %s]: " prompt display-current)
                   nil nil current)))
    (my/tpl-set key new-val)))

(defun my/tpl-read-choice (key prompt choices &optional default)
  "Lee una opción para KEY con PROMPT, mostrando CHOICES."
  (let* ((current (or (my/tpl-get key) default))
         (annotated-choices
          (mapcar (lambda (c)
                    (if (equal c current)
                        (concat c " ✓ [actual]")
                      c))
                  choices))
         (choice (completing-read
                  (format "%s: " prompt)
                  annotated-choices nil t nil nil current)))
    ;; Limpiar el sufijo " ✓ [actual]" si se seleccionó
    (my/tpl-set key (car (split-string choice " ✓")))))

;; ------------------------------------------------------------------
;; 4. FUNCIONES INTERACTIVAS POR SECCIÓN
;; ------------------------------------------------------------------

;; --- 4.1 Tipo de documento y estilo ---

(defun my/template-set-doc-type ()
  "Selecciona el tipo de documento (book / article)."
  (interactive)
  (my/tpl-read-choice :doc-type "Tipo de documento"
                      '("book" "article"))
  (message "Tipo: %s" (my/tpl-get :doc-type)))

(defun my/template-set-estilo ()
  "Selecciona el estilo editorial."
  (interactive)
  (my/tpl-read-choice :estilo "Estilo editorial"
                      '("bourbaki" "ihes" "ega" "bonn"))
  (message "Estilo: %s" (my/tpl-get :estilo)))

(defun my/template-set-idioma ()
  "Selecciona el idioma del documento."
  (interactive)
  (my/tpl-read-choice :idioma "Idioma"
                      '("spanish" "english" "french" "german"))
  (message "Idioma: %s" (my/tpl-get :idioma)))

(defun my/template-set-citas ()
  "Selecciona el estilo de citas bibliográficas."
  (interactive)
  (my/tpl-read-choice :citas "Estilo de citas (biblatex)"
                      '("alphabetic" "ieee" "apa" "numeric"))
  (message "Citas: %s" (my/tpl-get :citas)))

(defun my/template-toggle-fast ()
  "Activa/desactiva el modo rápido (fast/draft)."
  (interactive)
  (my/tpl-toggle :fast-mode)
  (message "Fast mode: %s" (if (my/tpl-get :fast-mode) "ON" "OFF")))

;; --- 4.2 Metadatos del documento ---

(defun my/template-set-title ()
  "Establece el título del documento."
  (interactive)
  (my/tpl-read-string :title "Título principal"))

(defun my/template-set-short-title ()
  "Establece el subtítulo / título corto (encabezados)."
  (interactive)
  (my/tpl-read-string :short-title "Subtítulo / título corto"))

(defun my/template-set-author ()
  "Establece el nombre del autor."
  (interactive)
  (my/tpl-read-string :author "Autor(es)"))

(defun my/template-set-date ()
  "Establece la fecha del documento."
  (interactive)
  (my/tpl-read-string :date "Fecha" "\\today"))

(defun my/template-set-email ()
  "Establece el correo electrónico del autor."
  (interactive)
  (my/tpl-read-string :email "Correo electrónico"))

(defun my/template-set-orcid ()
  "Establece el ORCID del autor."
  (interactive)
  (my/tpl-read-string :orcid "ORCID (sin URL, ej: 0000-0001-2345-6789)"))

(defun my/template-set-version ()
  "Establece el número de versión."
  (interactive)
  (my/tpl-read-string :version "Versión (ej: 1.0, 2026-09)"))

;; --- 4.3 Contexto académico ---

(defun my/template-set-universidad ()
  "Establece la universidad / institución."
  (interactive)
  (my/tpl-read-string :universidad "Universidad / Institución"))

(defun my/template-set-facultad ()
  "Establece la facultad / departamento."
  (interactive)
  (my/tpl-read-string :facultad "Facultad / Departamento"))

(defun my/template-set-curso ()
  "Establece el nombre del curso."
  (interactive)
  (my/tpl-read-string :curso "Nombre del curso"))

(defun my/template-set-codigo ()
  "Establece el código del curso."
  (interactive)
  (my/tpl-read-string :codigo "Código del curso (ej: MA-123)"))

(defun my/template-set-semestre ()
  "Establece el semestre académico."
  (interactive)
  (my/tpl-read-string :semestre "Semestre (ej: 2026-II)"))

(defun my/template-set-profesor ()
  "Establece el nombre del profesor."
  (interactive)
  (my/tpl-read-string :profesor "Profesor"))

(defun my/template-set-asistente ()
  "Establece el Jefe de Prácticas / Asistente."
  (interactive)
  (my/tpl-read-string :asistente "Jefe de Prácticas / Asistente"))

(defun my/template-set-lugar ()
  "Establece el lugar (ciudad)."
  (interactive)
  (my/tpl-read-string :lugar "Lugar / Ciudad (ej: Lima, Perú)"))

;; --- 4.4 Referencias y estructura ---

(defun my/template-set-referencias ()
  "Establece las referencias principales (mostradas en portada)."
  (interactive)
  (my/tpl-read-string :referencias "Referencias principales (portada)"))

(defun my/template-set-logo ()
  "Establece la ruta al archivo de logo."
  (interactive)
  (let ((logo-path (read-file-name "Logo (ruta, vacío = sin logo): " nil "" t)))
    (if (or (string-empty-p logo-path) (not (file-exists-p logo-path)))
        (my/tpl-set :logo "")
      (my/tpl-set :logo logo-path))))

(defun my/template-set-bib ()
  "Establece el archivo .bib para la bibliografía."
  (interactive)
  (my/tpl-read-string :bib-file "Archivo .bib (sin extensión, ej: referencias)"))

;; --- 4.5 Opciones de estructura ---

(defun my/template-toggle-toc ()
  "Activa/desactiva la tabla de contenidos."
  (interactive)
  (my/tpl-toggle :with-toc)
  (message "Tabla de contenidos: %s" (if (my/tpl-get :with-toc) "SÍ" "NO")))

(defun my/template-toggle-index ()
  "Activa/desactiva el índice analítico."
  (interactive)
  (my/tpl-toggle :with-index)
  (message "Índice analítico: %s" (if (my/tpl-get :with-index) "SÍ" "NO")))

(defun my/template-toggle-bibliography ()
  "Activa/desactiva la sección de bibliografía al final."
  (interactive)
  (my/tpl-toggle :with-bibliography)
  (message "Bibliografía final: %s" (if (my/tpl-get :with-bibliography) "SÍ" "NO")))

(defun my/template-set-body ()
  "Selecciona el tipo de contenido inicial del cuerpo."
  (interactive)
  (my/tpl-read-choice :body-content "Contenido inicial del cuerpo"
                      '("intro"    ; Introducción + primer capítulo/sección
                        "chapter"  ; Solo estructura de capítulo (modo book)
                        "section"  ; Solo estructura de sección (modo article)
                        "blank"    ; Cuerpo vacío
                        ))
  (message "Contenido inicial: %s" (my/tpl-get :body-content)))

;; ------------------------------------------------------------------
;; 5. GENERADOR DEL TEMPLATE
;; ------------------------------------------------------------------

(defun my/template--opt-str (key prefix &optional suffix)
  "Si KEY no está vacío, retorna PREFIX + valor + SUFFIX (con salto de línea)."
  (let ((val (my/tpl-get key)))
    (if (and val (not (string-empty-p val)))
        (concat prefix val (or suffix "") "\n")
      "")))

(defun my/template--bool-opt (key prefix &optional suffix)
  "Si KEY es verdadero, retorna PREFIX + SUFFIX."
  (if (my/tpl-get key)
      (concat prefix (or suffix "") "\n")
    ""))

(defun my/template-generate ()
  "Genera el string del template LaTeX basado en el estado actual."
  (let* ((doc-type  (my/tpl-get :doc-type))
         (estilo    (my/tpl-get :estilo))
         (idioma    (my/tpl-get :idioma))
         (citas     (my/tpl-get :citas))
         (fast      (my/tpl-get :fast-mode))

         (title     (my/tpl-get :title))
         (stitle    (my/tpl-get :short-title))
         (author    (my/tpl-get :author))
         (sauthor   (my/tpl-get :short-author))
         (date      (my/tpl-get :date))
         (email     (my/tpl-get :email))
         (orcid     (my/tpl-get :orcid))
         (version   (my/tpl-get :version))

         (univ      (my/tpl-get :universidad))
         (facultad  (my/tpl-get :facultad))
         (curso     (my/tpl-get :curso))
         (codigo    (my/tpl-get :codigo))
         (semestre  (my/tpl-get :semestre))
         (profesor  (my/tpl-get :profesor))
         (asistente (my/tpl-get :asistente))
         (lugar     (my/tpl-get :lugar))

         (refs      (my/tpl-get :referencias))
         (logo      (my/tpl-get :logo))
         (bib-file  (my/tpl-get :bib-file))

         (with-toc  (my/tpl-get :with-toc))
         (with-idx  (my/tpl-get :with-index))
         (with-bib  (my/tpl-get :with-bibliography))
         (body-type (my/tpl-get :body-content))
         (is-book   (equal doc-type "book"))

         ;; --- Construcción de opciones de clase ---
         (class-opts
          (mapconcat #'identity
                     (delq nil
                           (list doc-type estilo idioma citas
                                 (when fast "fast")))
                     ", "))

         ;; --- Preamble de metadata ---
         (preamble-meta
          (concat
           (if (and title (not (string-empty-p title)))
               (if (and stitle (not (string-empty-p stitle)))
                   (format "\\title[%s]{%s}\n" stitle title)
                 (format "\\title{%s}\n" title))
             "% \\title{Título del Documento}\n")
           (if (and author (not (string-empty-p author)))
               (if (and sauthor (not (string-empty-p sauthor)))
                   (format "\\author[%s]{%s}\n" sauthor author)
                 (format "\\author{%s}\n" author))
             "% \\author{Nombre del Autor}\n")
           (format "\\date{%s}\n" (if (and date (not (string-empty-p date))) date "\\today"))
           (my/template--opt-str :email     "\\email{" "}")
           (my/template--opt-str :orcid     "\\orcid{" "}")
           (my/template--opt-str :version   "\\version{" "}")))

         ;; --- Preamble de contexto académico ---
         (preamble-acad
          (concat
           (my/template--opt-str :universidad "\\universidad{" "}")
           (my/template--opt-str :facultad    "\\facultad{" "}")
           (my/template--opt-str :curso       "\\curso{" "}")
           (my/template--opt-str :codigo      "\\codigo{" "}")
           (my/template--opt-str :semestre    "\\semestre{" "}")
           (my/template--opt-str :profesor    "\\profesor{" "}")
           (my/template--opt-str :asistente   "\\asistente{" "}")
           (my/template--opt-str :lugar       "\\lugar{" "}")))

         ;; --- Preamble de logo y referencias ---
         (preamble-extras
          (concat
           (my/template--opt-str :logo       "\\logo{" "}")
           (my/template--opt-str :referencias "\\referencias{" "}")
           (if (and bib-file (not (string-empty-p bib-file)))
               (format "\\addbibresource{%s.bib}\n" bib-file)
             "% \\addbibresource{referencias.bib}\n")))

         ;; --- Cuerpo del documento según tipo ---
         (body-content
          (pcase body-type
            ("intro"
             (if is-book
                 (concat
                  "\n% =========================================================\n"
                  "% MATERIA DEL DOCUMENTO\n"
                  "% =========================================================\n"
                  "\\maketitle\n"
                  (if with-toc "\\tableofcontents\n\\cleardoublepage\n" "")
                  "\n\\chapter{Introducción}\n"
                  "\\chaptersummary\n\n"
                  "% Escribe aquí el contenido de la introducción.\n\n"
                  "\\section{Motivación y Panorama}\n\n"
                  "\\section{Preliminares}\n\n")
               (concat
                "\n\\maketitle\n"
                (if with-toc "\\tableofcontents\n\n" "")
                "\n\\section{Introducción}\n\n"
                "% Escribe aquí el contenido.\n\n"
                "\\section{Desarrollo}\n\n")))
            ("chapter"
             (concat
              "\n\\maketitle\n"
              (if with-toc "\\tableofcontents\n\\cleardoublepage\n" "")
              "\n\\chapter{Primer Capítulo}\n"
              "\\chaptersummary\n\n"
              "\\section{Primera Sección}\n\n"
              "% Contenido aquí.\n\n"))
            ("section"
             (concat
              "\n\\maketitle\n"
              (if with-toc "\\tableofcontents\n\n" "")
              "\n\\section{Primera Sección}\n\n"
              "% Contenido aquí.\n\n"))
            ("blank"
             "\n\\maketitle\n\n% Contenido aquí.\n\n")
            (_ "\n\\maketitle\n\n")))

         ;; --- Final del documento ---
         (doc-end
          (concat
           (when with-idx
             "\n% =========================================================\n"
             "% ÍNDICE ANALÍTICO\n"
             "% =========================================================\n"
             "\\printindex\n")
           (when (and with-bib bib-file (not (string-empty-p bib-file)))
             (concat
              "\n% =========================================================\n"
              "% BIBLIOGRAFÍA\n"
              "% =========================================================\n"
              "\\printbibliography\n"))
           "\n\\end{document}\n")))

    ;; ---------------------------------------------------------------
    ;; ENSAMBLAJE FINAL DEL TEMPLATE
    ;; ---------------------------------------------------------------
    (concat
     "%% Documento generado con apuntes-scr.cls v6.5 (Bourbaki Edition)\n"
     "%% Compilar con: lualatex --shell-escape <archivo.tex>\n"
     "%% ============================================================\n\n"
     (format "\\documentclass[%s]{apuntes-scr}\n\n" class-opts)

     ;; Separador de metadata
     "% ============================================================\n"
     "% METADATOS DEL DOCUMENTO\n"
     "% ============================================================\n"
     preamble-meta
     "\n"

     ;; Separador de contexto académico (solo si hay algo)
     (if (not (string-empty-p preamble-acad))
         (concat
          "% ============================================================\n"
          "% CONTEXTO ACADÉMICO\n"
          "% ============================================================\n"
          preamble-acad
          "\n")
       "")

     ;; Separador de extras (logo, referencias, bib)
     "% ============================================================\n"
     "% BIBLIOGRAFÍA Y RECURSOS\n"
     "% ============================================================\n"
     preamble-extras
     "\n"

     ;; Inicio del documento
     "% ============================================================\n"
     "% CUERPO DEL DOCUMENTO\n"
     "% ============================================================\n"
     "\\begin{document}\n"
     body-content
     doc-end)))

;; ------------------------------------------------------------------
;; 6. VISTA PREVIA DEL ESTADO ACTUAL
;; ------------------------------------------------------------------

(defun my/template--bool-display (key)
  "Retorna '✓ Sí' o '✗ No' para un KEY booleano."
  (if (my/tpl-get key)
      (propertize "✓ Sí" 'face 'success)
    (propertize "✗ No" 'face 'shadow)))

(defun my/template--val-display (key &optional fallback)
  "Muestra el valor de KEY o FALLBACK si está vacío."
  (let ((val (my/tpl-get key)))
    (if (and val (not (string-empty-p val)))
        (propertize val 'face 'font-lock-string-face)
      (propertize (or fallback "(vacío)") 'face 'shadow))))

(defun my/template-show-preview ()
  "Muestra un buffer de resumen del estado actual del template."
  (interactive)
  (let ((buf (get-buffer-create "*apuntes-scr: Vista Previa*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (propertize "═══ Vista Previa del Template apuntes-scr.cls ═══\n\n"
                            'face '(:weight bold :height 1.2)))

        ;; Clase y opciones
        (insert (propertize "▸ CLASE Y OPCIONES\n" 'face 'bold))
        (insert (format "  Tipo de doc  : %s\n" (my/template--val-display :doc-type)))
        (insert (format "  Estilo       : %s\n" (my/template--val-display :estilo)))
        (insert (format "  Idioma       : %s\n" (my/template--val-display :idioma)))
        (insert (format "  Citas        : %s\n" (my/template--val-display :citas)))
        (insert (format "  Modo rápido  : %s\n" (my/template--bool-display :fast-mode)))
        (insert "\n")

        ;; Metadatos
        (insert (propertize "▸ METADATOS\n" 'face 'bold))
        (insert (format "  Título       : %s\n" (my/template--val-display :title)))
        (insert (format "  Subtítulo    : %s\n" (my/template--val-display :short-title)))
        (insert (format "  Autor        : %s\n" (my/template--val-display :author)))
        (insert (format "  Fecha        : %s\n" (my/template--val-display :date "\\today")))
        (insert (format "  Email        : %s\n" (my/template--val-display :email)))
        (insert (format "  ORCID        : %s\n" (my/template--val-display :orcid)))
        (insert (format "  Versión      : %s\n" (my/template--val-display :version)))
        (insert "\n")

        ;; Contexto académico
        (insert (propertize "▸ CONTEXTO ACADÉMICO\n" 'face 'bold))
        (insert (format "  Universidad  : %s\n" (my/template--val-display :universidad)))
        (insert (format "  Facultad     : %s\n" (my/template--val-display :facultad)))
        (insert (format "  Curso        : %s\n" (my/template--val-display :curso)))
        (insert (format "  Código       : %s\n" (my/template--val-display :codigo)))
        (insert (format "  Semestre     : %s\n" (my/template--val-display :semestre)))
        (insert (format "  Profesor     : %s\n" (my/template--val-display :profesor)))
        (insert (format "  Asistente    : %s\n" (my/template--val-display :asistente)))
        (insert (format "  Lugar        : %s\n" (my/template--val-display :lugar)))
        (insert "\n")

        ;; Recursos y estructura
        (insert (propertize "▸ RECURSOS Y ESTRUCTURA\n" 'face 'bold))
        (insert (format "  Logo         : %s\n" (my/template--val-display :logo)))
        (insert (format "  Referencias  : %s\n" (my/template--val-display :referencias)))
        (insert (format "  Archivo .bib : %s\n" (my/template--val-display :bib-file)))
        (insert (format "  Tabla cont.  : %s\n" (my/template--bool-display :with-toc)))
        (insert (format "  Índice anal. : %s\n" (my/template--bool-display :with-index)))
        (insert (format "  Bibliografía : %s\n" (my/template--bool-display :with-bibliography)))
        (insert (format "  Cuerpo inic. : %s\n" (my/template--val-display :body-content)))
        (insert "\n")

        ;; Preview del template generado
        (insert (propertize "▸ PREÁMBULO GENERADO (preview)\n" 'face 'bold))
        (insert (propertize
                 (let ((preview (my/template-generate)))
                   (if (> (length preview) 1200)
                       (concat (substring preview 0 1200) "\n… [truncado]\n")
                     preview))
                 'face 'font-lock-comment-face))
        (insert "\n")
        (insert (propertize
                 "Presiona 'q' para cerrar. Usa el menú Transient para editar opciones.\n"
                 'face 'shadow)))
      (special-mode)
      (local-set-key (kbd "q") #'kill-buffer-and-window))
    (display-buffer buf '(display-buffer-below-selected . ((window-height . 0.45))))))

;; ------------------------------------------------------------------
;; 7. INSERCIÓN DEL TEMPLATE EN EL BUFFER
;; ------------------------------------------------------------------

(defun my/template-insert ()
  "Inserta el template generado en el buffer actual (al inicio si está vacío, sino pregunta)."
  (interactive)
  (let ((template (my/template-generate)))
    (if (buffer-modified-p)
        (when (yes-or-no-p "El buffer tiene contenido. ¿Insertar template aquí de todos modos? ")
          (insert template)
          (message "✅ Template apuntes-scr insertado."))
      ;; Buffer limpio: ir al inicio e insertar
      (goto-char (point-min))
      (insert template)
      (goto-char (point-min))
      (message "✅ Template apuntes-scr insertado en el buffer."))))

(defun my/template-insert-new-file ()
  "Crea un nuevo archivo .tex con el template generado."
  (interactive)
  (let* ((default-dir (or (and (buffer-file-name)
                               (file-name-directory (buffer-file-name)))
                          default-directory))
         (fname (read-file-name "Nombre del nuevo archivo .tex: " default-dir nil nil
                                (concat (my/tpl-get :title)
                                        (unless (string-empty-p (my/tpl-get :title)) "-")
                                        "main.tex")))
         (template (my/template-generate)))
    (unless (string-suffix-p ".tex" fname)
      (setq fname (concat fname ".tex")))
    (find-file fname)
    (insert template)
    (save-buffer)
    (goto-char (point-min))
    (message "✅ Archivo creado: %s" fname)))

;; ------------------------------------------------------------------
;; 8. MENÚ TRANSIENT PRINCIPAL
;; ------------------------------------------------------------------

(transient-define-prefix my/template-menu ()
  "Menú interactivo para construir un template apuntes-scr.cls."
  [:description
   (lambda ()
     (format "  apuntes-scr.cls  ─  %s  [%s, %s, %s]"
             (let ((t-val (my/tpl-get :title)))
               (if (and t-val (not (string-empty-p t-val)))
                   (propertize t-val 'face 'bold)
                 (propertize "Sin título" 'face 'shadow)))
             (propertize (or (my/tpl-get :doc-type) "?") 'face 'font-lock-keyword-face)
             (propertize (or (my/tpl-get :estilo)   "?") 'face 'font-lock-type-face)
             (propertize (or (my/tpl-get :idioma)   "?") 'face 'font-lock-string-face)))

   ;; Grupo A: Tipo, estilo e idioma
   ["Clase y Opciones"
    ("d" (lambda () (format "Tipo de doc   [%s]" (my/tpl-get :doc-type)))
     my/template-set-doc-type :transient t)
    ("e" (lambda () (format "Estilo edit.  [%s]" (my/tpl-get :estilo)))
     my/template-set-estilo :transient t)
    ("i" (lambda () (format "Idioma        [%s]" (my/tpl-get :idioma)))
     my/template-set-idioma :transient t)
    ("c" (lambda () (format "Citas bibl.   [%s]" (my/tpl-get :citas)))
     my/template-set-citas :transient t)
    ("F" (lambda () (format "Fast/draft    [%s]" (if (my/tpl-get :fast-mode) "ON" "off")))
     my/template-toggle-fast :transient t)]

   ;; Grupo B: Metadatos
   ["Metadatos"
    ("t" (lambda () (format "Título        [%s]" (my/template--val-display :title "…")))
     my/template-set-title :transient t)
    ("s" (lambda () (format "Subtítulo     [%s]" (my/template--val-display :short-title "…")))
     my/template-set-short-title :transient t)
    ("a" (lambda () (format "Autor(es)     [%s]" (my/template--val-display :author "…")))
     my/template-set-author :transient t)
    ("D" (lambda () (format "Fecha         [%s]" (my/tpl-get :date)))
     my/template-set-date :transient t)
    ("m" (lambda () (format "Email         [%s]" (my/template--val-display :email "…")))
     my/template-set-email :transient t)
    ("o" (lambda () (format "ORCID         [%s]" (my/template--val-display :orcid "…")))
     my/template-set-orcid :transient t)
    ("V" (lambda () (format "Versión       [%s]" (my/template--val-display :version "…")))
     my/template-set-version :transient t)]

   ;; Grupo C: Contexto académico
   ["Contexto Académico"
    ("u" (lambda () (format "Universidad   [%s]" (my/template--val-display :universidad "…")))
     my/template-set-universidad :transient t)
    ("f" (lambda () (format "Facultad      [%s]" (my/template--val-display :facultad "…")))
     my/template-set-facultad :transient t)
    ("k" (lambda () (format "Curso         [%s]" (my/template--val-display :curso "…")))
     my/template-set-curso :transient t)
    ("K" (lambda () (format "Código curso  [%s]" (my/template--val-display :codigo "…")))
     my/template-set-codigo :transient t)
    ("S" (lambda () (format "Semestre      [%s]" (my/template--val-display :semestre "…")))
     my/template-set-semestre :transient t)
    ("p" (lambda () (format "Profesor      [%s]" (my/template--val-display :profesor "…")))
     my/template-set-profesor :transient t)
    ("A" (lambda () (format "Asistente     [%s]" (my/template--val-display :asistente "…")))
     my/template-set-asistente :transient t)
    ("L" (lambda () (format "Lugar         [%s]" (my/template--val-display :lugar "…")))
     my/template-set-lugar :transient t)]

   ;; Grupo D: Recursos, estructura y acciones
   ["Recursos y Estructura"
    ("l" (lambda () (format "Logo          [%s]" (my/template--val-display :logo "…")))
     my/template-set-logo :transient t)
    ("r" (lambda () (format "Referencias   [%s]" (my/template--val-display :referencias "…")))
     my/template-set-referencias :transient t)
    ("b" (lambda () (format "Archivo .bib  [%s]" (my/template--val-display :bib-file "…")))
     my/template-set-bib :transient t)
    ("T" (lambda () (format "Tabla cont.   [%s]" (if (my/tpl-get :with-toc) "✓" "✗")))
     my/template-toggle-toc :transient t)
    ("I" (lambda () (format "Índice anal.  [%s]" (if (my/tpl-get :with-index) "✓" "✗")))
     my/template-toggle-index :transient t)
    ("B" (lambda () (format "Bibliografía  [%s]" (if (my/tpl-get :with-bibliography) "✓" "✗")))
     my/template-toggle-bibliography :transient t)
    ("y" (lambda () (format "Cuerpo inic.  [%s]" (my/tpl-get :body-content)))
     my/template-set-body :transient t)]

   ;; Grupo E: Acciones finales
   ["Acciones"
    ("P" "Vista previa"         my/template-show-preview)
    ("RET" "Insertar aquí"      my/template-insert)
    ("N" "Crear nuevo archivo"  my/template-insert-new-file)
    ("R" "Reiniciar (reset)"    my/template-reset-and-refresh :transient t)
    ("q" "Cancelar"             transient-quit-all)]])

(defun my/template-reset-and-refresh ()
  "Reinicia el estado y actualiza el menú."
  (interactive)
  (when (yes-or-no-p "¿Reiniciar todas las opciones del template? ")
    (my/template-reset-state)
    (message "Estado reiniciado a valores por defecto.")))

;; ------------------------------------------------------------------
;; 9. PUNTO DE ENTRADA PRINCIPAL
;; ------------------------------------------------------------------

;;;###autoload
(defun my/insert-apuntes-scr-template ()
  "Punto de entrada: abre el menú interactivo para insertar un template apuntes-scr.cls.
Reinicia el estado antes de abrir si se llama con prefijo universal (C-u)."
  (interactive)
  (when (or current-prefix-arg (null my/template-state))
    (my/template-reset-state))
  (my/template-menu))

(provide 'my-latex-template)
;;; my-latex-template.el ends here
