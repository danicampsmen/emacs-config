%% tesis-uni.cls
%% Plantilla Académica de Investigación Matemática
%% Arquitectura Editorial: IHÉS (Bourbaki / EGA - Grothendieck Style)
%% Compilación exclusiva en LuaLaTeX - Versión 22.0 (Full IHES Edition)
%% ------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tesis-uni}[2026/02/16 v22.0 Clase Tesis - Pure IHES EGA Architecture]

% =========================================================
% 0. VERIFICACIÓN DEL MOTOR DE COMPILACIÓN
% =========================================================
\RequirePackage{iftex}
\ifluatex\else
  \ClassError{tesis-uni}{%
    Esta clase requiere el motor LuaLaTeX para cargar tipografias OpenType.\MessageBreak
    Cambia el compilador a LuaLaTeX en la configuracion de tu editor.%
  }{}
\fi

% =========================================================
% 1. OPCIONES DE CLASE
% =========================================================
\RequirePackage{etoolbox}

\newif\if@estiloihes\@estiloihestrue      % IHÉS activado por defecto
\newif\if@estilobonn\@estilobonnfalse
\newif\if@citaalphabetic\@citaalphabetictrue
\newif\if@citaieee\@citaieeefalse
\newif\if@citaapa\@citaapafalse
\newif\if@citanumeric\@citanumericfalse
\newif\if@langspanish\@langspanishtrue
\newif\if@langenglish\@langenglishfalse
\newif\if@langfrench\@langfrenchfalse
\newif\if@langgerman\@langgermanfalse

\DeclareOption{ihes}{\@estiloihestrue\@estilobonnfalse}
\DeclareOption{bonn}{\@estilobonntrue\@estiloihesfalse}
\DeclareOption{spanish}{\@langspanishtrue\@langenglishfalse\@langfrenchfalse\@langgermanfalse}
\DeclareOption{english}{\@langenglishtrue\@langspanishfalse\@langfrenchfalse\@langgermanfalse}
\DeclareOption{french}{\@langfrenchtrue\@langspanishfalse\@langenglishfalse\@langgermanfalse}
\DeclareOption{alphabetic}{\@citaalphabetictrue\@citaieeefalse\@citaapafalse\@citanumericfalse}
\DeclareOption{ieee}{\@citaieeetrue\@citaalphabeticfalse\@citaapafalse\@citanumericfalse}
\DeclareOption{apa}{\@citaapatrue\@citaalphabeticfalse\@citaieeefalse\@citanumericfalse}
\DeclareOption{numeric}{\@citanumerictrue\@citaalphabeticfalse\@citaieeefalse\@citaapafalse}

\def\@grado{Para obtener el Grado Académico de Bachiller en Ciencias con mención en Matemática}
\DeclareOption{bachiller}{\def\@grado{Para obtener el Grado Académico de Bachiller en Ciencias con mención en Matemática}}
\DeclareOption{titulo}{\def\@grado{Para obtener el Título Profesional de Licenciado en Matemática}}
\DeclareOption{maestria}{\def\@grado{Para obtener el Grado Académico de Maestro en Ciencias con mención en Matemática}}
\DeclareOption{doctorado}{\def\@grado{Para obtener el Grado Académico de Doctor en Matemática}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrbook}}
\ProcessOptions\relax
\LoadClass[a4paper,fontsize=11pt,twoside,openright,usegeometry]{scrbook}

% =========================================================
% 2. GEOMETRÍA Y MÁRGENES (Métricas Reales IHÉS / PMIHES)
% =========================================================
\RequirePackage{geometry}
\if@estiloihes
  % Métrica exacta IHÉS: Bloque de 14.5cm x 22.5cm centrado visualmente
  \geometry{
    a4paper,
    textwidth=14.5cm,
    textheight=22.5cm,
    heightrounded,
    left=3.5cm,            % Margen interior amplio para encuadernación/tesis
    marginparwidth=2.2cm,  % Espacio para el Virage Dangereux
    marginparsep=0.4cm,
    headheight=15pt,
    footskip=30pt
  }
\else
  % Estilo Bonn (A4 moderno)
  \geometry{
    top=2.80cm, bottom=3.00cm, inner=3.00cm, outer=2.50cm, headheight=24pt, footskip=30pt
  }
\fi
\setlength{\footheight}{20pt}

% =========================================================
% 3. TIPOGRAFÍA Y MICROTIPOGRAFÍA
% =========================================================
\RequirePackage[dvipsnames]{xcolor}
\definecolor{UniBlue}{HTML}{1d214e}
\definecolor{brightmaroon}{rgb}{0.76, 0.13, 0.28}
\definecolor{CiteBurgundy}{rgb}{0.76, 0.13, 0.28}
\definecolor{orcidlogocol}{HTML}{A6CE39}

\RequirePackage{mathtools}
\RequirePackage{amssymb}
\RequirePackage{mathrsfs}
\RequirePackage{fontspec}
\RequirePackage{marginnote}
\RequirePackage{xstring}

\RequirePackage{silence}
\WarningFilter{unicode-math}{Using \overbracket}
\WarningFilter{unicode-math}{I'm going to overwrite}
\RequirePackage{unicode-math}
\RequirePackage{setspace}

\providecommand{\blacksquare}{\mbox{\rule{1.2ex}{1.2ex}}}
\providecommand{\blackSquare}{\blacksquare}

% Tipografía Clásica IHÉS / Termes
\if@estiloihes
  \setmainfont{TeX Gyre Termes}[Ligatures=TeX]
  \setsansfont{TeX Gyre Heros}[Scale=MatchLowercase]
  \setmonofont{TeX Gyre Cursor}[Scale=MatchLowercase]
  \setmathfont{TeX Gyre Termes Math}
  \setstretch{1.12}
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{4pt plus 1.5pt minus 0.5pt}
\else
  \setmainfont{TeX Gyre Pagella}[Ligatures=TeX]
  \setsansfont{TeX Gyre Heros}[Scale=MatchLowercase]
  \setmonofont{TeX Gyre Cursor}[Scale=MatchLowercase]
  \setmathfont{TeX Gyre Pagella Math}
  \setstretch{1.20}
  \setlength{\parindent}{1.0cm}
  \setlength{\parskip}{0pt}
\fi

% =========================================================
% CONFIGURACIÓN EDITORIAL DE NOTAS AL PIE
% =========================================================

% 1. Penalidad estricta: Nunca partir una nota al pie en dos páginas
\interfootnotelinepenalty=10000

% 2. Separación elástica entre el texto principal y las notas al pie
% (1.5em de espacio base, expandible a 2em, reducible a 1.2em)
\setlength{\skip\footins}{1.5em plus 0.5em minus 0.3em}

% 3. Altura máxima permitida para notas en una sola página (la mitad de la hoja)
\setlength{\dimen\footins}{0.5\textheight}

% 4. Formato geométrico del párrafo de la nota al pie (Estilo IHÉS)
% \deffootnote[ancho_marca]{sangria}{sangria_parrafo}{definicion_marca}
\deffootnote[1.5em]{1.5em}{0em}{\textsuperscript{\thefootnotemark}\enskip}

% 5. Múltiples notas al pie consecutivas separadas por coma automáticamente (Ej. ^1,2)
\KOMAoptions{footnotes=multiple}

% 6. Tipografía de la nota al pie
\setkomafont{footnote}{\normalfont\footnotesize\setstretch{1.05}}

\clubpenalty=10000
\widowpenalty=10000
\displaywidowpenalty=10000
\raggedbottom

\RequirePackage[activate={true,nocompatibility}, final, factor=1100, stretch=10, shrink=10]{microtype}

\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt plus 2pt minus 1pt}
  \setlength{\belowdisplayskip}{4pt plus 2pt minus 1pt}
  \setlength{\abovedisplayshortskip}{2pt plus 1pt}
  \setlength{\belowdisplayshortskip}{2pt plus 1pt}
}

% =========================================================
% 4. HERRAMIENTAS, TABLAS E IDIOMAS
% =========================================================
\RequirePackage{luamplib}
\mplibforcehmode
\RequirePackage{tikz}
\usetikzlibrary{cd, graphs, graphdrawing, arrows.meta, calc, positioning, shapes.geometric, intersections, decorations.pathmorphing, svg.path}
\usegdlibrary{trees, layered, force}
\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}
\RequirePackage{etoc}
\RequirePackage{graphicx}
\RequirePackage{import}       
\RequirePackage{transparent}  
\RequirePackage{float}
\RequirePackage{booktabs}
\RequirePackage{tabularray}
\RequirePackage{varwidth}
\RequirePackage{multicol}
\RequirePackage{verbatim}     
\RequirePackage{siunitx}      
\RequirePackage{imakeidx}
\makeindex[intoc, title=Índice Alfabético]
\RequirePackage{pdfpages}
\RequirePackage{ragged2e}

% Elementos Clásicos Bourbaki / EGA
\newcommand{\viragedangereux}{\marginpar{\centering\tikz[scale=0.65,baseline=-0.5ex]{\draw[fill=black,draw=black,thick,rounded corners=1pt] (0,0) -- (0.35,0.65) -- (0.7,0) -- cycle;\node at (0.35,0.22) {\color{white}\bfseries\small !};}}}
\newcommand{\oldpage}[2][]{{\marginnote{\normalfont\footnotesize{\textbf{#1}~|~#2}}}\ignorespaces}
\newcommand{\egabreak}{\par\vspace{8pt}\centerline{\rmfamily\scshape * * *}\vspace{8pt}\par}
\let\sectionbreak\egabreak

\newcommand{\OrigHeight}{0.00390625}
\newlength{\Xheight}\setlength{\Xheight}{\fontcharht\font`X}
\newcommand{\orcidlogo}{\begin{tikzpicture}[yscale=-\OrigHeight*\Xheight,xscale=\OrigHeight*\Xheight,transform shape]\fill[orcidlogocol] svg{M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z};\fill[white] svg{M86.3,186.2H70.9V79.1h15.4v48.4V186.2z}svg{M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z} svg{M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z};\end{tikzpicture}}

\newcommand{\summaryname}{SUMARIO}
\if@langspanish
  \RequirePackage[spanish,es-nodecimaldot,es-sloppy]{babel}
  \RequirePackage[spanish]{datetime2}
  \addto\captionsspanish{
    \renewcommand{\tablename}{Tabla}
    \renewcommand{\listtablename}{Lista de Tablas}
    \renewcommand{\listfigurename}{Lista de Figuras}
    \renewcommand{\summaryname}{SUMARIO}
  }
\fi
\if@langfrench
  \RequirePackage[french]{babel}
  \addto\captionsfrench{
    \renewcommand{\summaryname}{SOMMAIRE}
  }
\fi

% =========================================================
% 5. ENCABEZADOS Y PIES (PMIHES Editorial Standard)
% =========================================================
\RequirePackage[automark]{scrlayer-scrpage}
\pagestyle{scrheadings}
\clearpairofpagestyles 
\automark[section]{chapter}
\KOMAoptions{headsepline=0.3pt}

\if@estiloihes
  \lehead{\small\rmfamily\textbf{\pagemark}\quad\textbar\quad\scshape\MakeLowercase{\headmark}}
  \rohead{\small\rmfamily\scshape\MakeLowercase{\headmark}\quad\textbar\quad\textbf{\pagemark}}
  \ofoot[\pagemark]{\pagemark}
\else
  \lehead{\small\sffamily\headmark}
  \rohead{\small\sffamily\headmark}
  \ofoot[\pagemark]{\pagemark}
\fi
\setkomafont{pageheadfoot}{\normalfont\small}
\setkomafont{pagenumber}{\normalfont\normalsize}

% =========================================================
% 6. FORMATO DE SECCIONES Y CAPÍTULOS
% =========================================================
\newif\if@enapendice\@enapendicefalse
\g@addto@macro\appendix{\@enapendicetrue}

\if@estiloihes
  \KOMAoptions{chapterprefix=true}
  \setkomafont{disposition}{\rmfamily\bfseries}   
  \setkomafont{chapterentry}{\rmfamily\bfseries} 
  \setkomafont{chapterprefix}{\fontsize{12pt}{16pt}\selectfont\rmfamily\scshape}
  \setkomafont{chapter}{\fontsize{16pt}{20pt}\selectfont\rmfamily\bfseries}
  \setkomafont{section}{\fontsize{12pt}{15pt}\selectfont\rmfamily\scshape}
  \setkomafont{subsection}{\fontsize{11pt}{14pt}\selectfont\rmfamily\bfseries\itshape}
  \setkomafont{subsubsection}{\fontsize{10.5pt}{13pt}\selectfont\rmfamily\bfseries}
  
  \renewcommand*{\raggedchapter}{\centering}
  \renewcommand*{\chapterformat}{\chaptername~\thechapter}
  \renewcommand*{\raggedsection}{\centering}
  \renewcommand*{\sectionformat}{§~\thesection.\enskip}
  \renewcommand*{\subsectionformat}{\thesubsection.\enskip}

  \renewcommand*{\chapterlineswithprefixformat}[3]{%
    \Ifstr{#2}{}{#3}{\centering{\fontsize{12pt}{16pt}\selectfont\rmfamily\scshape #2}\par\nobreak\vspace{0.3cm}{\fontsize{16pt}{20pt}\selectfont\rmfamily\bfseries #3}\par\nobreak\vspace{0.4cm}}%
  }
  
  \RedeclareSectionCommand[beforeskip=0pt, afterskip=20pt]{chapter}
  \RedeclareSectionCommand[beforeskip=18pt plus 4pt minus 2pt, afterskip=8pt plus 2pt]{section}
  \RedeclareSectionCommand[indent=2em, beforeskip=12pt plus 3pt, afterskip=4pt]{subsection}
  \RedeclareSectionCommand[indent=4em, beforeskip=6pt plus 2pt, afterskip=2pt]{subsubsection}
  
  \renewcommand*{\sectionlinesformat}[4]{%
    \Ifstr{#1}{subsection}{\raggedright\@hangfrom{\hskip #2#3}{#4}}{%
    \Ifstr{#1}{subsubsection}{\raggedright\@hangfrom{\hskip #2#3}{#4}}{%
    \@hangfrom{\hskip #2#3}{#4}}}%
}
% Métricas del Índice (TOC) estilo IHÉS
  \KOMAoptions{toc=chapterentrywithdots} % Puntos conductores incluso en capítulos
  \setkomafont{chapterentry}{\normalfont\scshape} % Capítulos en Versalitas
  \setkomafont{chapterentrypagenumber}{\normalfont\scshape}
  \RedeclareSectionCommand[tocnumwidth=2.5em]{chapter}
  \RedeclareSectionCommand[tocindent=2.5em, tocnumwidth=3.0em]{section}
  \RedeclareSectionCommand[tocindent=5.5em, tocnumwidth=3.5em]{subsection}
\else
  \KOMAoptions{chapterprefix=true}
  \setkomafont{disposition}{\sffamily\bfseries}
  \setkomafont{chapterprefix}{\fontsize{11pt}{14pt}\selectfont\bfseries\sffamily\color{black!70}}
  \setkomafont{chapter}{\fontsize{18pt}{22pt}\selectfont\bfseries\sffamily}
  \setkomafont{section}{\fontsize{14pt}{17pt}\selectfont\bfseries\sffamily}
  \setkomafont{subsection}{\fontsize{12pt}{15pt}\selectfont\bfseries\sffamily\itshape}
  \setkomafont{subsubsection}{\fontsize{11pt}{14pt}\selectfont\bfseries\sffamily}
  \renewcommand*{\raggedchapter}{\raggedright}
  \renewcommand*{\chapterformat}{\chaptername~\thechapter}
  \RedeclareSectionCommand[beforeskip=0pt, afterskip=20pt]{chapter}
  \RedeclareSectionCommand[beforeskip=18pt, afterskip=6pt]{section}
  \RedeclareSectionCommand[beforeskip=18pt, afterskip=6pt]{subsection}
  \RedeclareSectionCommand[beforeskip=12pt, afterskip=6pt]{subsubsection}
\fi

\newcommand{\chaptersummary}[1][\summaryname]{%
  \IfFileExists{\jobname.toc}{%
    \begingroup
    \etocsetnexttocdepth{section}%
    \setlength{\parskip}{0pt}% Elimina el parskip global dentro del sumario
    \setstretch{1.0}% Interlineado compacto
    \etocsettocstyle{%
      \par\vspace{0.4em}\begin{center}{\fontsize{10.5pt}{13pt}\selectfont\rmfamily\scshape #1}\end{center}\vspace{0.2em}%
    }{\vspace{1.0em}\par}%
    \etocsetstyle{section}{}{%
      \par\noindent\leftskip=1.8cm\rightskip=0.8cm\parindent=0pt
    }{%
      \makebox[3.0em][l]{\textcolor{brightmaroon}{\etoclink{§\etocnumber.}}}\etocname.\par\vspace{1.0pt}% <-- Espacio vertical entre secciones
    }{}%
    \localtableofcontents
    \endgroup
  }{}%
  }
  
\setkomafont{caption}{\fontsize{9pt}{11pt}\selectfont}
\setkomafont{captionlabel}{\fontsize{9pt}{11pt}\selectfont\bfseries}
\renewcommand*{\captionformat}{.\enskip}

% =========================================================
% 7. CAJAS Y AMBIENTES AUXILIARES
% =========================================================
\RequirePackage{tcolorbox}
\tcbuselibrary{listings, breakable, skins}
\RequirePackage{csquotes}     
\RequirePackage{algorithm}
\RequirePackage{algpseudocode}
\tolerance=1000           
\emergencystretch=3em     

\newcommand{\TODO}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{orange!15}{\textcolor{orange}{\sffamily\textbf{\scriptsize TODO}}}\ \textcolor{orange!70!black}{\small #1}\endgroup}
\newcommand{\FIXME}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{red!15}{\textcolor{red}{\sffamily\textbf{\scriptsize FIXME}}}\ \textcolor{red!85!black}{\small\textbf{#1}}\endgroup}

\newtcolorbox{convencionbox}[1][]{
  enhanced, breakable, arc=1pt, boxrule=0.4pt,
  colback=gray!3, colframe=black!70,
  title={\bfseries Convención fijada para este capítulo\ifx&#1&\else: #1\fi},
  left=3mm, right=3mm, top=2mm, bottom=2mm
}

% =========================================================
% 8. VARIABLES Y PORTADA
% =========================================================
\def\@facultad{}\newcommand{\facultad}[1]{\def\@facultad{#1}}
\def\@escuela{}\newcommand{\escuela}[1]{\def\@escuela{#1}}
\newcommand{\grado}[1]{\def\@grado{#1}}
\newcommand{\apellidos}[1]{\def\@apellidos{#1}}
\newcommand{\iniciales}[1]{\def\@iniciales{#1}}
\def\@tipodocumento{TESIS}\newcommand{\tipodocumento}[1]{\def\@tipodocumento{#1}}
\def\@codigo{}\newcommand{\codigo}[1]{\def\@codigo{#1}}
\def\@orcidautor{}\newcommand{\orcidautor}[1]{\def\@orcidautor{#1}}
\def\@asesor{}\newcommand{\asesor}[1]{\def\@asesor{#1}}
\def\@orcidasesor{}\newcommand{\orcidasesor}[1]{\def\@orcidasesor{#1}}
\def\@asesorexterno{}\newcommand{\asesorexterno}[1]{\def\@asesorexterno{#1}}
\def\@orcidasesorexterno{}\newcommand{\orcidasesorexterno}[1]{\def\@orcidasesorexterno{#1}}
\def\@tomo{TOMO I DE I}\newcommand{\tomo}[1]{\def\@tomo{#1}}
\def\@ciudad{LIMA -- PERÚ}\newcommand{\ciudad}[1]{\def\@ciudad{#1}}

\newcommand{\makeportada}{
    \begin{titlepage}
    \thispagestyle{empty}
    \begin{center}
        \begin{singlespace}
        {\fontsize{14pt}{18pt}\selectfont\bfseries UNIVERSIDAD NACIONAL DE INGENIERÍA\par}\vspace{0.3cm}
        {\fontsize{12pt}{16pt}\selectfont\bfseries \@facultad\par}
        \ifx\@escuela\empty\else\vspace{0.2cm}{\fontsize{11pt}{14pt}\selectfont \@escuela\par}\fi
        \end{singlespace}
        \vfill
        \includegraphics[width=4.5cm, keepaspectratio]{imagenes/uni.png} 
        \vfill 
        \begin{singlespace}
        {\fontsize{12pt}{16pt}\selectfont\bfseries \@tipodocumento\par}\vspace{0.4cm}
        {\fontsize{13pt}{17pt}\selectfont\bfseries \@title\par}\vspace{0.6cm}
        {\fontsize{11pt}{14pt}\selectfont \@grado\par}
        \end{singlespace}
        \vfill 
        \begin{singlespace}
        {\fontsize{11pt}{14pt}\selectfont
        \textbf{Elaborado por}\\[0.1cm] \@author\\[0.1cm]
        \ifx\@orcidautor\empty\else \orcidlogo\ \href{https://orcid.org/\@orcidautor}{\@orcidautor}\\[0.2cm] \fi
        \textbf{Asesor}\\[0.1cm] \@asesor\\[0.1cm]
        \ifx\@orcidasesor\empty\else \orcidlogo\ \href{https://orcid.org/\@orcidasesor}{\@orcidasesor}\\[0.2cm] \fi
        \ifx\@asesorexterno\empty\else 
            \textbf{Asesor externo}\\[0.1cm] \@asesorexterno\\[0.1cm]
            \ifx\@orcidasesorexterno\empty\else \orcidlogo\ \href{https://orcid.org/\@orcidasesorexterno}{\@orcidasesorexterno}\\[0.2cm] \fi
        \fi}
        \end{singlespace}
        \vfill 
        \begin{singlespace}
        {\fontsize{11pt}{14pt}\selectfont\bfseries \@tomo\\[0.2cm] \@ciudad\\[0.1cm] \@date}
        \end{singlespace}
    \end{center}
    \end{titlepage}
    \cleardoublepage
}

\newcommand{\makecitacion}{
    \thispagestyle{plain}
    \vspace*{1.5cm}
    \begin{singlespace}\frenchspacing\begingroup\def\\{ }\def\medskip{}
    \begin{tblr}{colspec = {Q[c,m,4.0cm] X[l,m]}, hline{1,Z} = {0.5pt, solid}, hline{2} = {1}{0.5pt, solid}, cell{2}{1} = {r=1, c=1}{c,m}}
        Citar/How to cite & \@apellidos~[1] \\
        {Referencia/Reference \\ \vspace{0.4cm} Estilo/Style: \\ IEEE} & {[1] \@iniciales~\@apellidos, ``\textit{\@title}'' [\@tipodocumento]. Lima (Perú): Universidad Nacional de Ingeniería, \@date.} \\
    \end{tblr}
    \vspace{1.5cm}
    \begin{tblr}{colspec = {Q[c,m,4.0cm] X[l,m]}, hline{1,Z} = {0.5pt, solid}, hline{2} = {1}{0.5pt, solid}, cell{2}{1} = {r=1, c=1}{c,m}}
        Citar/How to cite & (\@apellidos, \@date) \\
        {Referencia/Reference \\ \vspace{0.4cm} Estilo/Style: \\ APA (7ma ed.)} & {\@apellidos, \@iniciales~ (\@date). \textit{\@title}. [\@tipodocumento, Universidad Nacional de Ingeniería]. Repositorio Institucional UNI.} \\
    \end{tblr}
    \endgroup\end{singlespace}
    \vfill\cleardoublepage
}

\newcommand{\incluirlegajo}[1]{\cleardoublepage\pagestyle{empty}\phantomsection\addcontentsline{toc}{chapter}{Legajo Personal del Titulando}\includepdf[pages=-, pagecommand={\thispagestyle{empty}}]{#1}}

\newenvironment{dedicatoria}{\cleardoublepage\phantomsection\addcontentsline{toc}{chapter}{Dedicatoria}\thispagestyle{plain}\vspace*{0.2\textheight}\begin{flushright}{\fontsize{14pt}{18pt}\selectfont\bfseries\itshape Dedicatoria\par}\vspace{0.5cm}\itshape}{\end{flushright}}
\newenvironment{agradecimientos}{\cleardoublepage\phantomsection\addcontentsline{toc}{chapter}{Agradecimientos}\thispagestyle{plain}\vspace*{0.1\textheight}\begin{center}{\fontsize{14pt}{18pt}\selectfont\bfseries Agradecimientos}\end{center}\vspace{0.8cm}\begin{flushleft}}{\end{flushleft}}
\newenvironment{resumen}[1][]{\def\@resumenkw{#1}\cleardoublepage\phantomsection\addcontentsline{toc}{chapter}{Resumen}\thispagestyle{plain}\begin{center}{\fontsize{14pt}{18pt}\selectfont\bfseries Resumen\par}\end{center}\vspace{0.5cm}\begingroup\setlength{\parindent}{0pt}\par}{\par\ifx\@resumenkw\empty\else\vspace{0.8cm}\noindent\textbf{Palabras clave:} \@resumenkw.\fi\endgroup}
\newenvironment{abstracting}[1][]{\def\@abstractkw{#1}\cleardoublepage\phantomsection\addcontentsline{toc}{chapter}{Abstract}\thispagestyle{plain}\begin{center}{\fontsize{14pt}{18pt}\selectfont\bfseries Abstract\par}\end{center}\vspace{0.5cm}\begingroup\setlength{\parindent}{0pt}\par}{\par\ifx\@abstractkw\empty\else\vspace{0.8cm}\noindent\textbf{Keywords:} \@abstractkw.\fi\endgroup}

% =========================================================
% 8.5. CONFIGURACIÓN DE APÉNDICES (Estilo IHÉS / KOMA-Script)
% =========================================================
\newcommand{\iniciarapendices}{%
  \cleardoublepage
  \appendix
  \@enapendicetrue
  
  % 1. Formato del título en la página (Ej. "Apéndice A")
  \if@estiloihes
    \renewcommand*{\chapterformat}{\appendixname~\thechapter.\enskip}
  \else
    \renewcommand*{\chapterformat}{\appendixname~\thechapter}
  \fi

  % 2. Corrección tipográfica en el Índice General (TOC)
  % Evita que la palabra "Apéndice A" choque con el título del capítulo
  \DeclareTOCStyleEntry[
    numwidth=6.5em,
    entrynumberformat=\tocappendixprefix
  ]{chapter}{chapter}
  
  % 3. Si hay ecuaciones subordinadas a capítulos en modo Bonn, 
  % aseguramos que usen la letra del apéndice.
  \if@estilobonn
    \renewcommand{\theequation}{\thechapter.\arabic{equation}}
  \fi
}
\newcommand\tocappendixprefix[1]{\appendixname~#1}

% =========================================================
% 9. TEOREMAS, DEMOSTRACIONES Y LISTAS BOURBAKI
% =========================================================
\RequirePackage{amsthm}
\RequirePackage{mleftright}
\mleftright

\renewcommand{\qedsymbol}{\ensuremath{\blacksquare}}
\addto\captionsspanish{\renewcommand{\proofname}{Prueba}}
\addto\captionsenglish{\renewcommand{\proofname}{Proof}}
\addto\captionsfrench{\renewcommand{\proofname}{Démonstration}}

\newcounter{proofcount}[chapter]
\newcounter{claimcount}[chapter]
\def\theHproofcount{\theHchapter.\arabic{proofcount}}
\def\theHclaimcount{\theHchapter.\arabic{proofcount}.\arabic{claimcount}}

% Entorno de Demostración IHÉS
\if@estiloihes
  \renewenvironment{proof}[1][\proofname]{\par
    \stepcounter{proofcount}\setcounter{claimcount}{0}\pushQED{\qed}%
    \normalfont\small\setstretch{1.10}%
    \noindent\textit{#1.\ \textemdash}\enskip\ignorespaces
  }{%
    \popQED\par
    \vspace{6pt plus 2pt minus 1pt}%
  }
\else
  \renewenvironment{proof}[1][\proofname]{\par\pushQED{\qed}\normalfont\small\trivlist\item[] \textbf{\textit{#1.}}\hspace{0.5em}\ignorespaces}{\popQED\endtrivlist\@endpefalse}
\fi

% Párrafos numerados estilo EGA: (1.1.1) Texto...
\newcommand{\parag}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{\thetheorem.\ifx&#1&\else\ #1.\fi}\enskip\ignorespaces}
\newcommand{\numpar}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{(\thetheorem)}\ifx&#1&\else\ \textbf{\textit{#1.}}\fi\enskip\ignorespaces}

\RequirePackage[shortlabels]{enumitem}
\setlist[enumerate,1]{topsep=2pt plus 1pt minus 1pt, parsep=0pt, partopsep=0pt, itemsep=2pt plus 1pt, leftmargin=3em, label=\normalfont\arabic*.}
\setlist[itemize]{topsep=2pt plus 1pt minus 1pt, parsep=0pt, partopsep=0pt, itemsep=2pt plus 1pt, leftmargin=3em}

% Alinéas de EGA (a), b), c) en cursiva)
\newlist{egalist}{enumerate}{2}
\setlist[egalist,1]{label=\normalfont\textit{\alph*)}, ref=\normalfont\textit{\alph*)}, leftmargin=2em, labelsep=0.5em, topsep=3pt, itemsep=2pt, parsep=0pt}
\setlist[egalist,2]{label=\normalfont\textit{\roman*)}, ref=\normalfont\textit{\roman*)}, leftmargin=2em, labelsep=0.5em, topsep=1pt, itemsep=1pt}

% TFAEs (The following are equivalent) clásicos: (i), (ii), (iii)
\newlist{tfae}{enumerate}{1}
\setlist[tfae,1]{label=\normalfont(\roman*), leftmargin=2.5em, itemsep=2pt, topsep=3pt, parsep=0pt}

\newlist{proofcases}{enumerate}{2}
\setlist[proofcases,1]{label=\textit{Caso \arabic*:}, leftmargin=2.5em, align=left, labelwidth=*, labelindent=0pt, listparindent=2pt, itemsep=0.3em, topsep=0.3em, parsep=0pt}
\setlist[proofcases,2]{label=\textit{Subcaso \arabic{proofcasesi}.\arabic*:}, leftmargin=2.5em, align=left, labelwidth=*, labelindent=0pt, itemsep=0.2em}

% Afirmaciones anidadas
\if@estiloihes
  \newenvironment{claim}[1][]{\refstepcounter{claimcount}\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\textbf{Afirmación \arabic{claimcount}.\ \textemdash}}{\textbf{Afirmación \arabic{claimcount}\ (#1).\ \textemdash}}\enskip\itshape\ignorespaces}{\par\vspace{3pt plus 1pt minus 1pt}}
  \newenvironment{claim*}[1][]{\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\textbf{Afirmación.\ \textemdash}}{\textbf{Afirmación\ (#1).\ \textemdash}}\enskip\itshape\ignorespaces}{\par\vspace{3pt plus 1pt minus 1pt}}
  \newenvironment{claimproof}{\par\vspace{2pt plus 1pt minus 1pt}\noindent\textit{Prueba de la afirmación.}\enskip\ignorespaces}{\hfill$\circ$\par\vspace{3pt plus 1pt minus 1pt}}
\else
  \newenvironment{claim}[1][]{\refstepcounter{claimcount}\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\textbf{\textit{Afirmación \arabic{claimcount}:}}}{\textbf{\textit{Afirmación \arabic{claimcount}\ (#1):}}}\enskip\itshape\ignorespaces}{\par\vspace{4pt plus 1pt minus 1pt}}
  \newenvironment{claim*}[1][]{\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\textbf{\textit{Afirmación:}}}{\textbf{\textit{Afirmación\ (#1):}}}\enskip\itshape\ignorespaces}{\par\vspace{4pt plus 1pt minus 1pt}}
  \newenvironment{claimproof}{\par\noindent\textit{Prueba de la afirmación.}\ \small\ignorespaces}{\hfill$\square$\par\vspace{4pt plus 1pt minus 1pt}}
\fi

\newcommand{\directstep}{\par\vspace{2pt}\noindent(\(\Rightarrow\))\enskip\ignorespaces}
\newcommand{\reversestep}{\par\vspace{2pt}\noindent(\(\Leftarrow\))\enskip\ignorespaces}
\newcommand{\containedstep}{\par\vspace{2pt}\noindent(\(\subseteq\))\enskip\ignorespaces}
\newcommand{\inversecontainedstep}{\par\vspace{2pt}\noindent(\(\supseteq\))\enskip\ignorespaces}

% =========================================================
% 10. SUITE MATEMÁTICA Y GEOMETRÍA ALGEBRAICA (EGA / SGA)
% =========================================================

% ---------------------------------------------------------
% 10.1 CONSTANTES, CONJUNTOS NUMÉRICOS Y CONECTORES
% ---------------------------------------------------------
\newcommand{\diff}{\mathop{}\!\symup{d}} 
\newcommand{\E}{\symup{e}}               
\newcommand{\Imath}{\symup{i}}           
\newcommand{\N}{\symbb{N}}
\newcommand{\Z}{\symbb{Z}}
\newcommand{\Q}{\symbb{Q}}
\newcommand{\I}{\symbb{I}}
\newcommand{\R}{\symbb{R}}
\newcommand{\C}{\symbb{C}}
\newcommand{\F}{\symbb{F}}
\newcommand{\K}{\symbb{K}}
\providecommand{\D}{\symbb{D}}
\newcommand{\Cn}{\symbb{C}^{n}}
\newcommand{\PP}{\symbb{P}} 
\providecommand{\A}{\symbb{A}}
\newcommand{\Lr}{\mathcal{L}}

\providecommand{\ie}{\textit{i.e.}\,}
\providecommand{\tq}{\text{ t.q. }}
\newcommand{\syss}{\,si y solo si\,}

% ---------------------------------------------------------
% 10.2 DELIMITADORES Y VECTORES
% ---------------------------------------------------------
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\absolute}{\lvert}{\rvert}
\DeclarePairedDelimiter{\inner}{\langle}{\rangle}

\providecommand{\mat}[1]{\mathbf{#1}}
\providecommand{\vect}[1]{\mathbf{#1}}
\providecommand{\glie}[1]{\mathfrak{gl}(#1)}
\providecommand{\evec}[2]{\mathbf{Vec}_{#1}(#2)} % Corregido a \mathbf

% ---------------------------------------------------------
% 10.3 HACES Y GAVILLAS (Sheaves)
% ---------------------------------------------------------
\newcommand{\Ox}{\symcal{O}_X}
\newcommand{\Oy}{\symcal{O}_Y}
\newcommand{\Oz}{\symcal{O}_Z}
\newcommand{\Oxp}{\symcal{O}_{X,x}}
\newcommand{\Oyp}{\symcal{O}_{Y,y}}

\newcommand{\Fsh}{\symcal{F}}
\newcommand{\Gsh}{\symcal{G}}
\newcommand{\Esh}{\symcal{E}}
\renewcommand{\Lsh}{\symcal{L}}
\newcommand{\Ish}{\symcal{I}}
\newcommand{\Jsh}{\symcal{J}}
\newcommand{\Msh}{\symcal{M}}
\newcommand{\Nsh}{\symcal{N}}
\newcommand{\Ksh}{\symcal{K}}

% Funtores de haces (kerning ajustado estilo IHÉS)
\newcommand{\shHom}{\mathop{\symcal{H}\mkern-2.5mu om}\nolimits}
\newcommand{\shExt}{\mathop{\symcal{E}\mkern-2.5mu xt}\nolimits}
\newcommand{\shTor}{\mathop{\symcal{T}\mkern-2.5mu or}\nolimits}
\newcommand{\shDer}{\mathop{\symcal{D}\mkern-1.5mu er}\nolimits}
\newcommand{\shEnd}{\mathop{\symcal{E}\mkern-2.5mu nd}\nolimits}
\newcommand{\shAut}{\mathop{\symcal{A}\mkern-2.5mu ut}\nolimits}
\newcommand{\shProj}{\mathop{\symcal{P}\mkern-2.5mu roj}\nolimits}
\newcommand{\shSpec}{\mathop{\symcal{S}\mkern-2.5mu pec}\nolimits}
\newcommand{\shSym}{\mathop{\symcal{S}\mkern-2.5mu ym}\nolimits}
\newcommand{\shDiff}{\mathop{\symcal{D}\mkern-1.5mu if{}f}\nolimits}

% ---------------------------------------------------------
% 10.4 CATEGORÍAS (Bourbaki: Siempre en \mathbf, NUNCA en \operatorname)
% ---------------------------------------------------------
\newcommand{\Set}{\mathbf{Set}}
\newcommand{\ETop}{\mathbf{Top}}
\newcommand{\HTop}{\mathbf{hTop}}
\newcommand{\Grp}{\mathbf{Grp}}
\newcommand{\Ab}{\mathbf{Ab}}
\newcommand{\Rng}{\mathbf{Rng}}
\newcommand{\CRing}{\mathbf{CRing}}
\newcommand{\Mod}{\mathbf{Mod}}
\newcommand{\Ev}{\mathbf{Vect}}
\newcommand{\Evn}{\mathbf{Norm}}
\newcommand{\EBan}{\mathbf{Ban}}
\newcommand{\EHil}{\mathbf{Hilb}}
\newcommand{\Sch}{\mathbf{Sch}}
\newcommand{\AffSch}{\mathbf{AffSch}}
\newcommand{\QCoh}{\mathbf{QCoh}}
\newcommand{\Coh}{\mathbf{Coh}}
\newcommand{\Posets}{\mathbf{Posets}}
\newcommand{\MCom}{\mathbf{Met}_{\mathrm{comp}}} % Simplificado el subíndice

\newcommand{\Db}{\symbfup{D}^{\mathrm{b}}}
\newcommand{\Rder}{\symbfup{R}}
\newcommand{\Lder}{\symbfup{L}}
\newcommand{\Cls}{\symcal{C}} % Si referías a una clase/categoría abstracta C

% ---------------------------------------------------------
% 10.5 OPERADORES ALGEBRAICOS Y GEOMÉTRICOS
% ---------------------------------------------------------
\DeclareMathOperator{\id}{id}        % EGA: id en minúscula
\DeclareMathOperator{\rg}{rg}        % EGA: rg (rango/rang) en lugar de rk
\DeclareMathOperator{\Hom}{Hom}
\DeclareMathOperator{\End}{End}
\DeclareMathOperator{\Aut}{Aut}
\DeclareMathOperator{\Ext}{Ext}
\DeclareMathOperator{\Tor}{Tor}
\DeclareMathOperator{\Ker}{Ker}
\DeclareMathOperator{\im}{Im}        % Reemplaza \Image para evitar redundancias
\DeclareMathOperator{\Coker}{Coker}
\DeclareMathOperator{\Coim}{Coim}
\DeclareMathOperator{\Codim}{Codim}
\DeclareMathOperator{\Ind}{Ind}      % Capitalizado
\DeclareMathOperator{\GL}{GL}        % Capitalizado
\DeclareMathOperator{\SL}{SL}
\DeclareMathOperator{\Tr}{Tr}
\DeclareMathOperator{\Span}{Span}
\DeclareMathOperator{\mcd}{mcd}
\DeclareMathOperator{\Nat}{Nat}

\DeclareMathOperator{\Spec}{Spec}
\DeclareMathOperator{\Proj}{Proj}
\DeclareMathOperator{\Supp}{Supp}
\DeclareMathOperator{\Ann}{Ann}      % Capitalizado
\DeclareMathOperator{\Frac}{Frac}
\DeclareMathOperator{\Sym}{Sym}
\DeclareMathOperator{\Rad}{Rad}
\DeclareMathOperator{\nil}{nil}
\DeclareMathOperator{\Der}{Der}
\DeclareMathOperator{\Tan}{Tan}

% Límites categóricos estilo Bourbaki
\newcommand{\dirlim}{\varinjlim}
\newcommand{\invlim}{\varprojlim}
\newcommand{\morf}[3]{\Hom_{#1}(#2, #3)}

% ---------------------------------------------------------
% 10.6 OPERADORES DE ANÁLISIS Y OPTIMIZACIÓN (Con subíndices)
% ---------------------------------------------------------
\DeclareMathOperator{\sen}{sen}
\DeclareMathOperator{\arcsen}{arcsen}
\DeclareMathOperator{\Dom}{Dom}
\DeclareMathOperator{\dir}{dir}
\DeclareMathOperator{\gph}{gph}
\DeclareMathOperator{\ctp}{Ctp.}
\DeclareMathOperator{\con}{con}
\DeclareMathOperator{\pos}{pos}
\DeclareMathOperator{\bdry}{bdry}
\DeclareMathOperator{\Dif}{Dif}
\DeclareMathOperator{\rel}{rel}

% Operadores con asterisco (los subíndices van DEBAJO, ej. \conv_{i \in I})
\DeclareMathOperator*{\conv}{conv}
\DeclareMathOperator*{\osc}{osc}
\DeclareMathOperator*{\rint}{rint}

% ---------------------------------------------------------
% 10.7 REFERENCIAS INTELIGENTES CUSTOMIZADAS (sref + cleveref)
% ---------------------------------------------------------
\newcommand{\@srefcontent}[1]{%
  \IfSubStr{#1}{.}{\StrBehind{#1}{.}}{\ref{#1}}%
}

% 1. \sref[Tomo]{label}[ítem] -> (1.1.2) o (1.1.2, a) o (I, 1.1.2, a)
\NewDocumentCommand{\sref}{o m o}{%
  \IfNoValueTF{#1}{%
    \IfNoValueTF{#3}{%
      \hyperref[#2]{\normalfont{(\@srefcontent{#2})}}%
    }{%
      \hyperref[#2]{\normalfont{(\@srefcontent{#2},~{#3})}}%
    }%
  }{%
    \IfNoValueTF{#3}{%
      \hyperref[#2]{\normalfont{(\textbf{#1},~\@srefcontent{#2})}}%
    }{%
      \hyperref[#2]{\normalfont{(\textbf{#1},~\@srefcontent{#2},~{#3})}}%
    }%
  }%
}

\newcommand{\eref}[1]{\hyperref[#1]{\normalfont{(\@srefcontent{#1})}}}

% 2. \csref[Tomo]{label}[ítem] -> Detecta automáticamente el tipo de entorno con cleveref
%    \csref{label}[a]  -> Proposición (1.1.2, a)
%    \csref*{label}[a] -> proposición (1.1.2, a) (en minúscula)
\NewDocumentCommand{\csref}{s o m o}{%
  \IfBooleanTF{#1}{% Con asterisco: minúscula (ej. "proposición")
    \namecref{#3}~%
  }{% Sin asterisco: Mayúscula (ej. "Proposición")
    \nameCref{#3}~%
  }%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
  }
  
% Macro moderna para definir funciones como objetos formales (Dominio y Regla)
\NewDocumentCommand{\Fobj}{ m m m m m }{%
  % #1: Nombre de la función (ej. f+g)
  % #2: Dominio (ej. M)
  % #3: Codominio (ej. N)
  % #4: Elemento (ej. x)
  % #5: Regla de correspondencia (ej. f(x)+g(x))
  #1 \coloneq
  \left\{
    \begin{aligned}
      #2 &\longrightarrow #3 \\
      #4 &\longmapsto #5
    \end{aligned}
  \right.
  }

% ---------------------------------------------------------
% 10.8 COMANDOS DE CITACIÓN NOMBRADA (namedsref y variaciones)
% ---------------------------------------------------------

% 1. \namedsref* [Tomo] {label} {Nombre} [ítem]
%    Ej: \namedsref{prop:zariski}{Propiedades de $V(E)$}[a]
%    -> Proposición (1.1.2, a) (Propiedades de V(E))
\NewDocumentCommand{\namedsref}{s o m m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#5}{\sref{#3}}{\sref{#3}[#5]}%
  }{%
    \IfNoValueTF{#5}{\sref[#2]{#3}}{\sref[#2]{#3}[#5]}%
  }%
  \nobreakspace\textit{(#4)}%
}

% 2. \titref [Tomo] {label} {Título} [ítem]
%    Ej: \titref{thm:hilbert}{Teorema de la Base de Hilbert}[a]
%    -> Teorema de la Base de Hilbert (1.1.2, a)
\NewDocumentCommand{\titref}{o m m o}{%
  \hyperref[#2]{#3}%
  \nobreakspace
  \IfNoValueTF{#1}{%
    \IfNoValueTF{#4}{\sref{#2}}{\sref{#2}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#1]{#2}}{\sref[#1]{#2}[#4]}%
  }%
}

% 3. \autonamedsref* [Tomo] {label} [ítem]
%    Extrae AUTOMÁTICAMENTE el título del [opcional] del teorema/proposición
%    Ej: \autonamedsref{prop:propiedades_zariski}[a]
%    -> Proposición (1.1.2, a) (Propiedades algebraicas de V(E))
\NewDocumentCommand{\autonamedsref}{s o m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
  \nobreakspace\textit{(\nameref*{#3})}%
}

% 4. \srefname [Tomo] {label} {Nombre Breve} [ítem]
%    Estilo Puro Bourbaki (Título dentro del paréntesis)
%    Ej: \srefname{prop:propiedades_zariski}{Propiedades}[a]
%    -> (1.1.2, a, Propiedades)
\NewDocumentCommand{\srefname}{o m m o}{%
  \IfNoValueTF{#1}{%
    \IfNoValueTF{#4}{%
      \hyperref[#2]{\normalfont{(\@srefcontent{#2},~\textit{#3})}}%
    }{%
      \hyperref[#2]{\normalfont{(\@srefcontent{#2},~{#4},~\textit{#3})}}%
    }%
  }{%
    \IfNoValueTF{#4}{%
      \hyperref[#2]{\normalfont{(\textbf{#1},~\@srefcontent{#2},~\textit{#3})}}%
    }{%
      \hyperref[#2]{\normalfont{(\textbf{#1},~\@srefcontent{#2},~{#4},~\textit{#3})}}%
    }%
  }%
  }

 % \namesref* [Tomo] {label} [ítem]
% Extrae automáticamente el tipo, el número y el título (si existe)
\NewDocumentCommand{\namesref}{s o m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
  % Si el teorema tiene un título registrado con nameref, lo añade en cursiva:
  \IfBlankF{\nameref*{#3}}{\nobreakspace\textit{(\nameref*{#3})}}%
}

% =========================================================
% 11. BIBLIOGRAFÍA DINÁMICA CON BACKREF
% =========================================================
\if@citaalphabetic
  \RequirePackage[backend=biber, style=alphabetic, sorting=anyt, backref=true]{biblatex}
\fi
\if@citaieee
  \RequirePackage[backend=biber, style=ieee, sorting=none, backref=true]{biblatex}
\fi
\if@citaapa
  \RequirePackage[backend=biber, style=apa, sorting=nyt, backref=true]{biblatex}
\fi
\if@citanumeric
  \RequirePackage[backend=biber, style=numeric, sorting=none, backref=true]{biblatex}
\fi

\RequirePackage[colorlinks=true, linkcolor=brightmaroon, citecolor=brightmaroon, urlcolor=brightmaroon, plainpages=false, pdfpagelabels=true]{hyperref}
\RequirePackage{bookmark} 

\if@langspanish
  \RequirePackage[spanish,noabbrev]{cleveref}
  \crefname{equation}{ecuación}{ecuaciones}
  \Crefname{equation}{Ecuación}{Ecuaciones}
  \crefname{theorem}{teorema}{teoremas}
  \Crefname{theorem}{Teorema}{Teoremas}
  \crefname{proposition}{proposición}{proposiciones}
  \Crefname{proposition}{Proposición}{Proposiciones}
  \crefname{lemma}{lema}{lemas}
  \Crefname{lemma}{Lema}{Lemas}
  \crefname{corollary}{corolario}{corolarios}
  \Crefname{corollary}{Corolario}{Corolarios}
  \crefname{definition}{definición}{definiciones}
  \Crefname{definition}{Definición}{Definiciones}
  \crefname{example}{ejemplo}{ejemplos}
  \Crefname{example}{Ejemplo}{Ejemplos}
  \crefname{exercise}{ejercicio}{ejercicios}
  \Crefname{exercise}{Ejercicio}{Ejercicios}
  \crefname{solution}{solución}{soluciones}
  \Crefname{solution}{Solución}{Soluciones}
  \crefname{remark}{observación}{observaciones}
  \Crefname{remark}{Observación}{Observaciones}
  \crefname{commentary}{comentario}{comentarios}
  \Crefname{commentary}{Comentario}{Comentarios}
  \crefname{notation}{notación}{notaciones}
  \Crefname{notation}{Notación}{Notaciones}
\fi
\crefformat{equation}{Ecuación~#2#1#3}
\Crefformat{equation}{Ecuación~#2#1#3}
\pdfstringdefDisableCommands{\def\\{}\def\medskip{}}

\AtBeginDocument{
  \hypersetup{pdftitle={\texorpdfstring{\@title}{\@title}}, pdfauthor={\texorpdfstring{\@author}{\@author}}}
}

% =========================================================
% 12. ESTILOS DE TEOREMAS AMSTHM (Pure EGA Architecture)
% =========================================================
\if@estiloihes
  % --- EGA: Formato (1.1.1) Teorema. --- 
  \newtheoremstyle{ihes-plain}%
    {6pt plus 2pt minus 1pt}%
    {6pt plus 2pt minus 1pt}%
    {\itshape}%
    {0pt}%
    {\bfseries}%
    {.\ \textemdash}%
    {0.4em}%
    {\thmnumber{(#2)}\enskip\thmname{#1}\thmnote{ (#3)}}

  \newtheoremstyle{ihes-def}%
    {6pt plus 2pt minus 1pt}%
    {6pt plus 2pt minus 1pt}%
    {\normalfont}%
    {0pt}%
    {\bfseries}%
    {.\ \textemdash}%
    {0.4em}%
    {\thmnumber{(#2)}\enskip\thmname{#1}\thmnote{ (#3)}}

  \newtheoremstyle{ihes-remark}%
    {5pt plus 2pt minus 1pt}%
    {5pt plus 2pt minus 1pt}%
    {\normalfont}%
    {0pt}%
    {\bfseries}%
    {.\ \textemdash}%
    {0.4em}%
    {\thmnumber{(#2)}\enskip\itshape\thmname{#1}\thmnote{ (#3)}}

  \theoremstyle{ihes-plain}
  \newtheorem{theorem}{Teorema}[section]
  \newtheorem{proposition}[theorem]{Proposición}
  \newtheorem{lemma}[theorem]{Lema}
  \newtheorem{corollary}[theorem]{Corolario}

  \theoremstyle{ihes-def}
  \newtheorem{definition}[theorem]{Definición}
  \newtheorem{example}[theorem]{Ejemplo}

  \theoremstyle{ihes-remark}
  \newtheorem{remark}[theorem]{Observación}
  \newtheorem{commentary}[theorem]{Comentario}
  \newtheorem{notation}[theorem]{Notación}
\else
  \newtheoremstyle{bonn-plain}{6pt}{6pt}{\itshape}{0pt}{\bfseries}{.}{5pt}{}
  \newtheoremstyle{bonn-def}{6pt}{6pt}{\normalfont}{0pt}{\bfseries}{.}{5pt}{}
  \newtheoremstyle{bonn-remark}{6pt}{6pt}{\normalfont}{0pt}{\scshape}{.}{5pt}{}

  \theoremstyle{bonn-plain}
  \newtheorem{theorem}{Teorema}[chapter]
  \newtheorem{proposition}[theorem]{Proposición}
  \newtheorem{lemma}[theorem]{Lema}
  \newtheorem{corollary}[theorem]{Corolario}

  \theoremstyle{bonn-def}
  \newtheorem{definition}[theorem]{Definición}
  \newtheorem{example}[theorem]{Ejemplo}

  \theoremstyle{bonn-remark}
  \newtheorem{remark}[theorem]{Observación}
  \newtheorem{commentary}[theorem]{Comentario}
  \newtheorem{notation}[theorem]{Notación}
\fi

% =========================================================
% ALIAS DE CLEVEREF PARA ENTORNOS CON CONTADOR COMPARTIDO
% =========================================================
\AtBeginEnvironment{theorem}{\crefalias{theorem}{theorem}}
\AtBeginEnvironment{proposition}{\crefalias{theorem}{proposition}}
\AtBeginEnvironment{lemma}{\crefalias{theorem}{lemma}}
\AtBeginEnvironment{corollary}{\crefalias{theorem}{corollary}}
\AtBeginEnvironment{definition}{\crefalias{theorem}{definition}}
\AtBeginEnvironment{example}{\crefalias{theorem}{example}}
\AtBeginEnvironment{remark}{\crefalias{theorem}{remark}}
\AtBeginEnvironment{commentary}{\crefalias{theorem}{commentary}}
\AtBeginEnvironment{notation}{\crefalias{theorem}{notation}}

\def\theHtheorem{\theHsection.\arabic{theorem}}
\if@estiloihes
  \RequirePackage{chngcntr}
  \numberwithin{equation}{theorem} % Ecuaciones tipo (1.1.1.1)
  \renewcommand{\theequation}{\thetheorem.\arabic{equation}}
\else
  \numberwithin{equation}{chapter} % Estilo estándar tipo (1.1)
\fi

\endinput
