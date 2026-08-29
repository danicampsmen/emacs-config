%% apuntes-scr.cls
%% Clase Maestra para Apuntes Personales, Libros de Estudio y Artículos Académicos
%% Arquitectura Editorial: KOMA-Script + Estilo IHÉS / EGA Bourbaki
%% Compilación exclusiva en LuaLaTeX - Versión 5.0 (Full Enhanced Edition)
%% ------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{apuntes-scr}[2026/08/28 v5.0 Apuntes - LuaLaTeX IHES/Bourbaki Architecture]

% =========================================================
% 0. VERIFICACIÓN DEL MOTOR DE COMPILACIÓN
% =========================================================
\RequirePackage{iftex}
\ifluatex\else
  \ClassError{apuntes-scr}{%
    Esta clase requiere el motor LuaLaTeX para compilar correctamente.\MessageBreak
    Cambia el compilador a LuaLaTeX en la configuracion de tu editor (Emacs/AUCTeX).%
  }{}
\fi

% =========================================================
% 1. LÓGICA DE OPCIONES (TIPO, IDIOMA, MODO DRAFT Y CITAS)
% =========================================================
\RequirePackage{etoolbox}

\newif\if@isarticle     \@isarticlefalse 
\newif\if@isenglish     \@isenglishfalse
\newif\if@fastmode      \@fastmodefalse
\newif\if@citaalphabetic \@citaalphabetictrue
\newif\if@citaieee       \@citaieeefalse
\newif\if@citaapa        \@citaapafalse
\newif\if@citanumeric    \@citanumericfalse

% Opciones de tipo de documento
\DeclareOption{article}{\@isarticletrue}
\DeclareOption{book}{\@isarticlefalse}

% Opciones de idioma
\DeclareOption{english}{\@isenglishtrue}
\DeclareOption{spanish}{\@isenglishfalse}

% Opciones de citas
\DeclareOption{alphabetic}{\@citaalphabetictrue\@citaieeefalse\@citaapafalse\@citanumericfalse}
\DeclareOption{ieee}{\@citaieeetrue\@citaalphabeticfalse\@citaapafalse\@citanumericfalse}
\DeclareOption{apa}{\@citaapatrue\@citaalphabeticfalse\@citaieeefalse\@citanumericfalse}
\DeclareOption{numeric}{\@citanumerictrue\@citaalphabeticfalse\@citaieeefalse\@citaapafalse}

% Modo rápido / borrador
\DeclareOption{fast}{\@fastmodetrue}

% Pasar cualquier otra opción a la clase base KOMA-Script
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\if@isarticle scrartcl\else scrbook\fi}}

% Tamaño base por defecto (10.5pt para legibilidad matemática balanceada)
\PassOptionsToClass{10pt}{\if@isarticle scrartcl\else scrbook\fi}

\ProcessOptions\relax

% Modo Borrador (Acelera compilación desactivando minted y figuras pesadas)
\if@fastmode
  \PassOptionsToClass{draft}{\if@isarticle scrartcl\else scrbook\fi}
  \PassOptionsToPackage{draft}{minted}
\fi

% Carga dinámica de KOMA-Script
\if@isarticle
  \LoadClass[a4paper, twoside, bibliography=totoc, index=totoc, numbers=enddot, usegeometry]{scrartcl}
\else
  \LoadClass[a4paper, twoside, open=any, bibliography=totoc, index=totoc, numbers=enddot, usegeometry]{scrbook}
\fi

\setcounter{tocdepth}{2}

% =========================================================
% 2. GEOMETRÍA Y MÁRGENES
% =========================================================
\RequirePackage{geometry}
\if@isarticle
  \geometry{
    a4paper,
    twoside,
    textwidth=15.2cm,
    textheight=23.5cm,
    heightrounded,
    inner=22mm,
    outer=22mm,
    top=22mm,
    bottom=22mm,
    headheight=18pt,
    footskip=28pt
  }
\else
  \geometry{
    a4paper,
    twoside,
    textwidth=14.8cm,
    textheight=23.0cm,
    heightrounded,
    inner=25mm,
    outer=25mm,
    top=24mm,
    bottom=24mm,
    headheight=18pt,
    footskip=30pt
  }
\fi

% =========================================================
% 3. DICCIONARIO Y TRADUCCIONES AUTOMÁTICAS
% =========================================================
\if@isenglish
  \RequirePackage[english]{babel}
  \newcommand{\indexnamecustom}{Alphabetical Index}
  \newcommand{\thmnamecustom}{Theorem}
  \newcommand{\propnamecustom}{Proposition}
  \newcommand{\lemmanamecustom}{Lemma}
  \newcommand{\cornamecustom}{Corollary}
  \newcommand{\defnamecustom}{Definition}
  \newcommand{\exnamecustom}{Example}
  \newcommand{\exernamecustom}{Exercise}
  \newcommand{\solnamecustom}{Solution}
  \newcommand{\cexnamecustom}{Counterexample}
  \newcommand{\algnamecustom}{Algorithm}
  \newcommand{\obsnamecustom}{Remark}
  \newcommand{\comnamecustom}{Commentary}
  \newcommand{\casenamecustom}{Case}
  \newcommand{\condnamecustom}{Condition}
  \newcommand{\claimnamecustom}{Claim}
  \newcommand{\proofclaimnamecustom}{Proof of the claim.}
  \newcommand{\basecasenamecustom}{Base Case}
  \newcommand{\indstepnamecustom}{Inductive Step}
  \newcommand{\indhypnamecustom}{Induction Hypothesis (I.H.)}
  \newcommand{\noteboxnamecustom}{Note}
  \newcommand{\warnboxnamecustom}{Warning}
  \newcommand{\ctrlboxnamecustom}{Control Question}
  \newcommand{\coverrefname}{Main References}
  \newcommand{\summaryname}{SUMMARY}
  \addto\captionsenglish{%
    \renewcommand{\proofname}{Proof}%
    \renewcommand{\tablename}{Table}%
    \renewcommand{\listtablename}{List of Tables}%
    \renewcommand{\listfigurename}{List of Figures}%
  }
\else
  \RequirePackage[spanish,es-nodecimaldot,es-sloppy]{babel}
  \RequirePackage[spanish]{datetime2}
  \newcommand{\indexnamecustom}{Índice Alfabético}
  \newcommand{\thmnamecustom}{Teorema}
  \newcommand{\propnamecustom}{Proposición}
  \newcommand{\lemmanamecustom}{Lema}
  \newcommand{\cornamecustom}{Corolario}
  \newcommand{\defnamecustom}{Definición}
  \newcommand{\exnamecustom}{Ejemplo}
  \newcommand{\exernamecustom}{Ejercicio}
  \newcommand{\solnamecustom}{Solución}
  \newcommand{\cexnamecustom}{Contraejemplo}
  \newcommand{\algnamecustom}{Algoritmo}
  \newcommand{\obsnamecustom}{Observación}
  \newcommand{\comnamecustom}{Comentario}
  \newcommand{\casenamecustom}{Caso}
  \newcommand{\condnamecustom}{Condición}
  \newcommand{\claimnamecustom}{Afirmación}
  \newcommand{\proofclaimnamecustom}{Demostración de la afirmación.}
  \newcommand{\basecasenamecustom}{Caso Base}
  \newcommand{\indstepnamecustom}{Paso Inductivo}
  \newcommand{\indhypnamecustom}{Hipótesis de Inducción (H.I.)}
  \newcommand{\noteboxnamecustom}{Nota}
  \newcommand{\warnboxnamecustom}{Atención}
  \newcommand{\ctrlboxnamecustom}{Pregunta de Control}
  \newcommand{\coverrefname}{Referencias Principales}
  \newcommand{\summaryname}{SUMARIO}
  \addto\captionsspanish{%
    \renewcommand{\proofname}{Prueba}%
    \renewcommand{\tablename}{Tabla}%
    \renewcommand{\listtablename}{Lista de Tablas}%
    \renewcommand{\listfigurename}{Lista de Figuras}%
  }
\fi

% =========================================================
% 4. COLORES, TIPOGRAFÍA Y MICROTIPOGRAFÍA
% =========================================================
\RequirePackage[dvipsnames]{xcolor}
\definecolor{MidnightBlue}{HTML}{1d214e}
\definecolor{UniBlue}{HTML}{1d214e}
\definecolor{brightmaroon}{rgb}{0.76, 0.13, 0.28}
\definecolor{CiteBurgundy}{rgb}{0.76, 0.13, 0.28}
\definecolor{orcidlogocol}{HTML}{A6CE39}
\definecolor{emacstodo}{HTML}{FF9900}
\definecolor{emacsfixme}{HTML}{FF0000}    
\definecolor{emacsdebug}{HTML}{A020F0}
\definecolor{emacsnote}{HTML}{00CCFF}

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
\setstretch{1.14}

\providecommand{\blacksquare}{\mbox{\rule{1.2ex}{1.2ex}}}
\providecommand{\blackSquare}{\blacksquare}

% Tipografía Principal: STIX Two (Científica / Editorial)
\setmainfont{STIXTwoText-Regular.ttf}[
  Renderer = HarfBuzz,
  BoldFont = STIXTwoText-Bold.ttf,
  ItalicFont = STIXTwoText-Italic.ttf,
  BoldItalicFont = STIXTwoText-BoldItalic.ttf,
  SmallCapsFont = STIXTwoText-Regular.ttf,
  SmallCapsFeatures = {Letters=UppercaseSmallCaps},
  Numbers = {Proportional, Lining}
]
\setmathfont{STIX Two Math}[StylisticSet = {1, 8}]
\setsansfont{texgyreheros-regular.otf}[
  Scale = MatchLowercase,
  BoldFont = texgyreheros-bold.otf,
  ItalicFont = texgyreheros-italic.otf,
  BoldItalicFont = texgyreheros-bolditalic.otf
]
\setmonofont{inconsolata}[Scale = MatchLowercase]

\addtokomafont{disposition}{\rmfamily\bfseries}

% Configuración Editorial de Notas al Pie (IHÉS / KOMA-Script)
\interfootnotelinepenalty=10000
\setlength{\skip\footins}{1.5em plus 0.5em minus 0.3em}
\setlength{\dimen\footins}{0.5\textheight}
\deffootnote[1.5em]{1.5em}{0em}{\textsuperscript{\thefootnotemark}\enskip}
\KOMAoptions{footnotes=multiple}
\setkomafont{footnote}{\normalfont\footnotesize\setstretch{1.05}}

% Penalidades de viudas y huérfanas
\clubpenalty=10000
\widowpenalty=10000
\displaywidowpenalty=10000
\brokenpenalty=10000
\raggedbottom

\RequirePackage[activate={true,nocompatibility}, final, factor=1100, stretch=10, shrink=10]{microtype}

\AtBeginDocument{
  \setlength{\abovedisplayskip}{3.5pt plus 2pt minus 1pt}
  \setlength{\belowdisplayskip}{3.5pt plus 2pt minus 1pt}
  \setlength{\abovedisplayshortskip}{1.5pt plus 1pt}
  \setlength{\belowdisplayshortskip}{1.5pt plus 1pt}
}

% =========================================================
% 5. HERRAMIENTAS, TABLAS, DIBUJO Y GRÁFICOS
% =========================================================
\RequirePackage{imakeidx}
\makeindex[intoc, columns=2, title=\indexnamecustom]

\RequirePackage{luamplib}
\mplibforcehmode

\RequirePackage{tikz}
\usetikzlibrary{cd, graphs, graphdrawing, arrows.meta, calc, positioning, shapes.geometric, intersections, decorations.pathmorphing, svg.path}
\usegdlibrary{trees, layered, force}

\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}

\RequirePackage{graphicx}
\RequirePackage{import}
\RequirePackage{transparent}
\RequirePackage{float}
\RequirePackage{booktabs}
\RequirePackage{tabularray}
\RequirePackage{varwidth}
\RequirePackage{ragged2e}
\RequirePackage{verbatim}
\RequirePackage{siunitx}
\RequirePackage{tasks}
\RequirePackage{calc}

\settasks{label=(\alph*), label-width=18pt, item-indent=25pt}

% Integración Inkscape -> pdf_tex (Workflow Castel / TeX)
\newcommand{\incfig}[2][]{%
  \if\relax\detokenize{#1}\relax
    \let\svgwidth\undefined
  \else
    \def\svgwidth{#1\columnwidth}%
  \fi
  \IfFileExists{./figuras/#2.pdf_tex}{%
    \import{./figuras/}{#2.pdf_tex}%
  }{%
    \IfFileExists{../figuras/#2.pdf_tex}{%
      \import{../figuras/}{#2.pdf_tex}%
    }{%
      \import{./}{#2.pdf_tex}%
    }%
  }%
}

% Elementos Clásicos Bourbaki / EGA
\newcommand{\viragedangereux}{\marginpar{\centering\tikz[scale=0.15,baseline=-0.5ex]{\draw[line width=2.0pt,line cap=round,line join=round] (0.8,-1.6) -- (0.8,-0.5) arc (0:180:0.8) -- (-0.8,0.5) arc (-180:0:0.8) -- (0.8,1.6);}}}
\newcommand{\oldpage}[2][]{{\marginnote{\normalfont\footnotesize{\textbf{#1}~|~#2}}}\ignorespaces}
\newcommand{\egabreak}{\par\vspace{8pt}\centerline{\rmfamily\scshape * * *}\vspace{8pt}\par}
\let\sectionbreak\egabreak

% Logo ORCID vectorial
\newcommand{\OrigHeight}{0.00390625}
\newlength{\Xheight}\setlength{\Xheight}{\fontcharht\font`X}
\newcommand{\orcidlogo}{\begin{tikzpicture}[yscale=-\OrigHeight*\Xheight,xscale=\OrigHeight*\Xheight,transform shape]\fill[orcidlogocol] svg{M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z};\fill[white] svg{M86.3,186.2H70.9V79.1h15.4v48.4V186.2z}svg{M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z} svg{M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z};\end{tikzpicture}}

% =========================================================
% 6. ENCABEZADOS Y PIES (scrlayer-scrpage)
% =========================================================
\RequirePackage[automark]{scrlayer-scrpage}
\pagestyle{scrheadings}
\clearpairofpagestyles
\KOMAoptions{headsepline=0.4pt}

\if@isarticle
  \ohead{\small\pagemark}
  \ihead{\small\rmfamily\scshape\headmark}
  \cfoot[]{}
\else
  \automark[section]{chapter}
  \lehead{\small\rmfamily\pagemark\qquad\scshape\MakeLowercase{\headmark}}
  \rohead{\small\rmfamily\scshape\MakeLowercase{\headmark}\qquad\pagemark}
  \ofoot[]{}
\fi
\setkomafont{pageheadfoot}{\normalfont\small}
\setkomafont{pagenumber}{\normalfont\normalsize\bfseries}
\setkomafont{caption}{\small\itshape}
\setkomafont{captionlabel}{\small\bfseries}
\setcapindent{1em}

% =========================================================
% 7. FORMATO DE SECCIONES Y CAPÍTULOS
% =========================================================
\if@isarticle
  \addtokomafont{section}{\Large\bfseries\color{MidnightBlue!80!black}}
  \addtokomafont{subsection}{\large\bfseries\color{MidnightBlue!70!black}}
  \addtokomafont{subsubsection}{\normalsize\bfseries\color{MidnightBlue!60!black}}
\else
  \addtokomafont{chapter}{\Huge\bfseries\color{MidnightBlue!80!black}}
  \renewcommand*{\chapterformat}{\mbox{\fontsize{48}{52}\selectfont\color{MidnightBlue!18}\thechapter\autodot\enskip}}
  \renewcommand*{\chapterlinesformat}[3]{\parbox{\textwidth}{\raggedleft #2#3\par\vspace{-1ex}\textcolor{MidnightBlue!60!black}{\rule{\textwidth}{1.5pt}}}}
  \addtokomafont{section}{\Large\bfseries\color{MidnightBlue!80!black}}
  \addtokomafont{subsection}{\large\bfseries\color{MidnightBlue!70!black}}
  \addtokomafont{part}{\color{MidnightBlue!80!black}}
\fi

% =========================================================
% 8. CAJAS, RESALTADOS Y AMBIENTES AUXILIARES
% =========================================================
\RequirePackage{tcolorbox}
\RequirePackage{luacolor}
\RequirePackage{lua-ul}

\newcommand{\deftech}[1]{\highLight[pink!40]{#1}} 
\newcommand{\usual}[1]{\highLight[yellow!40]{#1}}
\newcommand{\highlightgreen}[1]{\highLight[ForestGreen!20]{#1}}

\directlua{os.setenv("TEXMF_OUTPUT_DIRECTORY", ".")} 
\tcbuselibrary{listings, breakable, skins, minted}
\RequirePackage{csquotes}

\newcommand{\mastervskip}{1.5ex plus 0.3ex minus 0.1ex}

% Notas editoriales TODO, FIXME, DEBUG, NOTE
\newcommand{\TODO}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacstodo!15}{\textcolor{emacstodo}{\sffamily\textbf{\scriptsize TODO}}}\ \textcolor{emacstodo!70!black}{\small #1}\endgroup}
\newcommand{\FIXME}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsfixme!15}{\textcolor{emacsfixme}{\sffamily\textbf{\scriptsize FIXME}}}\ \textcolor{emacsfixme!85!black}{\small\textbf{#1}}\endgroup}
\newcommand{\DEBUG}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsdebug!15}{\textcolor{emacsdebug}{\sffamily\textbf{\scriptsize DEBUG}}}\ \textcolor{emacsdebug!70!black}{\small #1}\endgroup}
\newcommand{\NOTE}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsnote!15}{\textcolor{emacsnote}{\sffamily\textbf{\scriptsize NOTE}}}\ \textcolor{emacsnote!70!black}{\small #1}\endgroup}

% Cajas estilizadas
\newtcolorbox{notabox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=MidnightBlue!3, colframe=MidnightBlue!60!black, title={\textbf{\noteboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{warningbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=red!3, colframe=red!60!black, title={\textbf{\warnboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{controlbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=ForestGreen!3, colframe=ForestGreen!40!black, title={\textbf{\ctrlboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}

\newenvironment{convencionbox}[1][]{%
  \par\vspace{0.6em}\noindent\hrule height 0.4pt\vspace{0.4em}%
  \noindent\textbf{\textit{Convención\ifblank{#1}{}{: #1}.\ \textemdash}}\enskip\ignorespaces
}{%
  \par\vspace{0.4em}\noindent\hrule height 0.4pt\vspace{0.8em}\par
}

% =========================================================
% 9. GESTIÓN BIBLIOGRÁFICA CON BIBLATEX
% =========================================================
\if@citaalphabetic
  \RequirePackage[backend=biber, style=alphabetic, sorting=none, backref=true]{biblatex}
\fi
\if@citaieee
  \RequirePackage[backend=biber, style=ieee, sorting=none, backref=true]{biblatex}
\fi
\if@citaapa
  \RequirePackage[backend=biber, style=apa, backref=true]{biblatex}
\fi
\if@citanumeric
  \RequirePackage[backend=biber, style=numeric-comp, sorting=none, backref=true]{biblatex}
\fi

\RequirePackage[colorlinks=true, linkcolor=CiteBurgundy, citecolor=CiteBurgundy, urlcolor=MidnightBlue, pdfencoding=auto, psdextra]{hyperref}
\RequirePackage{bookmark} 

\pdfstringdefDisableCommands{%
  \def\symbb#1{#1}\def\symcal#1{#1}\def\symfrak#1{#1}\def\symbf#1{#1}\def\symup#1{#1}\def\symbfup#1{#1}%
  \def\R{R}\def\C{C}\def\N{N}\def\Z{Z}\def\Q{Q}\def\F{F}\def\K{K}\def\D{D}\def\PP{P}\def\A{A}%
  \def\Ox{O_X}\def\Oy{O_Y}\def\Oz{O_Z}\def\Fsh{F}\def\Gsh{G}\def\Esh{E}\def\Lsh{L}\def\Ish{I}\def\Jsh{J}%
  \def\shHom{Hom}\def\shExt{Ext}\def\shTor{Tor}\def\shDer{Der}\def\shEnd{End}\def\shAut{Aut}%
  \def\Set{Set}\def\Sch{Sch}\def\QCoh{QCoh}\def\Coh{Coh}\def\Ab{Ab}\def\CRing{CRing}\def\Mod{Mod}\def\Top{Top}\def\Grp{Grp}\def\Vect{Vect}%
  \def\inmap#1#2#3{#1: #2 -> #3}\def\chart#1#2{(#1, #2)}\def\chartcoords#1#2{(#1, #2)}\def\rest#1#2{#1}%
}
\bookmarksetup{numbered, open, openlevel=1, depth=3}

% =========================================================
% 10. TEOREMAS, DEMOSTRACIONES Y LISTAS BOURBAKI
% =========================================================
\RequirePackage{amsthm}
\RequirePackage{mleftright}
\mleftright

\newcommand{\dependencias}[1]{{\noindent\small\textbf{\textcolor{Magenta}{Dependencias:}} #1\par}\smallskip}
\newcommand{\blueprint}[1]{{\noindent\small\textbf{\textcolor{BlueViolet}{Idea Fuerza (Blueprint):}} #1\par}\medskip}

\newtheoremstyle{my-thm-style}{\mastervskip}{\mastervskip}{\itshape}{}{\normalfont}{}{0.5em}{\bfseries\color{Black}\thmname{#1}\space\thmnumber{#2}\thmnote{ (#3)}.}
\newtheoremstyle{my-plain-style}{\mastervskip}{\mastervskip}{\normalfont}{}{\normalfont}{}{0.5em}{\bfseries\thmname{#1}\space\thmnumber{#2}\thmnote{ (#3)}.}
\newtheoremstyle{my-remark-style}{\mastervskip}{\mastervskip}{\normalfont}{}{\itshape}{}{0.5em}{\bfseries\thmname{#1}\thmnote{ (#3)}.}

\if@isarticle
  \theoremstyle{my-thm-style}
  \newtheorem{theorem}{\thmnamecustom}[section]
  \newtheorem{proposition}{\propnamecustom}[section]
  \newtheorem{lemma}{\lemmanamecustom}[section]
  \newtheorem{corollary}{\cornamecustom}[section]
  \theoremstyle{my-plain-style}
  \newtheorem{definition}{\defnamecustom}[section]
  \newtheorem{example}{\exnamecustom}[section]
  \newtheorem{exercise}{\exernamecustom}[section]
  \newtheorem{solution}{\solnamecustom}[section]
  \newtheorem{counterexample}{\cexnamecustom}[section]
  \newtheorem{algorithm}{\algnamecustom}[section] 
  \newcounter{casocounter}[section]
  \newcounter{condicioncounter}[section]
  \newcounter{proofcount}[section]
  \newcounter{claimcount}[section]
\else
  \theoremstyle{my-thm-style}
  \newtheorem{theorem}{\thmnamecustom}[chapter]
  \newtheorem{proposition}{\propnamecustom}[chapter]
  \newtheorem{lemma}{\lemmanamecustom}[chapter]
  \newtheorem{corollary}{\cornamecustom}[chapter]
  \theoremstyle{my-plain-style}
  \newtheorem{definition}{\defnamecustom}[chapter]
  \newtheorem{example}{\exnamecustom}[chapter]
  \newtheorem{exercise}{\exernamecustom}[chapter]
  \newtheorem{solution}{\solnamecustom}[chapter]
  \newtheorem{counterexample}{\cexnamecustom}[chapter]
  \newtheorem{algorithm}{\algnamecustom}[chapter] 
  \newcounter{casocounter}[chapter]
  \newcounter{condicioncounter}[chapter]
  \newcounter{proofcount}[chapter]
  \newcounter{claimcount}[chapter]
\fi

\theoremstyle{my-remark-style}
\newtheorem*{remark}{\obsnamecustom}
\newtheorem*{commentary}{\comnamecustom}
\newtheorem*{notation}{Notación}
\newtheorem*{objetive}{Objetivo}

% Párrafos numerados estilo EGA: (1.1.1) Texto...
\newcommand{\parag}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{\thetheorem.\ifx&#1&\else\ #1.\fi}\enskip\ignorespaces}
\newcommand{\numpar}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{(\thetheorem)}\ifblank{#1}{\textbf{.\ \textemdash}}{\ \textbf{\textit{#1.}}\ \textbf{\textemdash}}\enskip\ignorespaces}

\renewcommand{\qedsymbol}{\ensuremath{\blacksquare}}

% Demostración elegante con barra lateral
\renewenvironment{proof}[1][\proofname]{%
  \par\stepcounter{proofcount}\setcounter{claimcount}{0}\pushQED{\qed}%
  \normalfont\small\setstretch{1.10}%
  \noindent\textbf{\textit{#1\@addpunct{.}}}\hspace{0.5em}\ignorespaces
}{%
  \popQED\par
  \vspace{4pt plus 2pt minus 1pt}%
}
\tcolorboxenvironment{proof}{blanker, breakable, left=6mm, right=4mm, top=0pt, bottom=0pt, before skip=\mastervskip, after skip=\mastervskip, borderline west={1.2pt}{0pt}{MidnightBlue!35}}

% Casos y Afirmaciones
\newenvironment{caso}[1]{\refstepcounter{casocounter}\par\smallskip\noindent\textbf{\textcolor{MidnightBlue!90!black}{\casenamecustom\ #1:}} }{\par\smallskip}
\newenvironment{condicion}[1]{\refstepcounter{condicioncounter}\par\smallskip\noindent\textbf{\textcolor{DarkOrchid!90!black}{\condnamecustom\ #1:}} }{\par\smallskip}

\newenvironment{claim}[1][]{\refstepcounter{claimcount}\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\def\@currentlabelname{}\textbf{\claimnamecustom\ \arabic{claimcount}.\ \textemdash}}{\def\@currentlabelname{#1}\textbf{\claimnamecustom\ \arabic{claimcount}\ (#1).\ \textemdash}}\enskip\itshape\ignorespaces}{\par\vspace{3pt plus 1pt minus 1pt}}
\newenvironment{claim*}[1][]{\par\vspace{4pt plus 1pt minus 1pt}\noindent\ifblank{#1}{\def\@currentlabelname{}\textbf{\claimnamecustom.\ \textemdash}}{\def\@currentlabelname{#1}\textbf{\claimnamecustom\ (#1).\ \textemdash}}\enskip\itshape\ignorespaces}{\par\vspace{3pt plus 1pt minus 1pt}}
\newenvironment{claimproof}{\par\vspace{2pt plus 1pt minus 1pt}\noindent\textit{\proofclaimnamecustom}\enskip\ignorespaces}{\hfill$\circ$\par\vspace{3pt plus 1pt minus 1pt}}
\newenvironment{pruebaafirmacion}{\par\noindent\small\textit{\proofclaimnamecustom} }{\hfill\ensuremath{\lozenge}\par\smallskip}

\newcommand{\casobase}[1]{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\basecasenamecustom\ (#1):}}\ }
\newcommand{\pasoinductivo}{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\indstepnamecustom:}}\ }
\newcommand{\hipotesisind}{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\indhypnamecustom:}}\ }

% Pasos formales de demostración
\newcommand{\directstep}{\par\vspace{2pt}\noindent(\(\Rightarrow\))\enskip\ignorespaces}
\newcommand{\reversestep}{\par\vspace{2pt}\noindent(\(\Leftarrow\))\enskip\ignorespaces}
\newcommand{\containedstep}{\par\vspace{2pt}\noindent(\(\subset\))\enskip\ignorespaces}
\newcommand{\inversecontainedstep}{\par\vspace{2pt}\noindent(\(\supset\))\enskip\ignorespaces}

% Listas Bourbaki (EGA Alinéas y TFAEs)
\RequirePackage[shortlabels]{enumitem}
\newcommand{\myleftmargin}{8mm}
\setlist[enumerate]{topsep=1ex plus 0.2ex minus 0.1ex, itemsep=0.4ex plus 0.1ex, partopsep=0pt, parsep=0pt, leftmargin=\myleftmargin, label=\normalfont\arabic*.}
\setlist[itemize]{topsep=1ex plus 0.2ex minus 0.1ex, itemsep=0.4ex plus 0.1ex, partopsep=0pt, parsep=0pt, leftmargin=\myleftmargin}

\newlist{egalist}{enumerate}{2}
\setlist[egalist,1]{label=\normalfont\textit{\alph*)}, ref=\normalfont\textit{\alph*)}, leftmargin=2em, labelsep=0.5em, topsep=3pt, itemsep=2pt, parsep=0pt}
\setlist[egalist,2]{label=\normalfont\textit{\roman*)}, ref=\normalfont\textit{\roman*)}, leftmargin=2em, labelsep=0.5em, topsep=1pt, itemsep=1pt}

\newlist{tfae}{enumerate}{1}
\setlist[tfae,1]{label=\normalfont\textit{(\roman*)}, ref=\normalfont\textit{(\roman*)}, leftmargin=2.5em, itemsep=2pt, topsep=3pt, parsep=0pt}

\newlist{proofcases}{enumerate}{2}
\setlist[proofcases,1]{label=\textit{\casenamecustom\ \arabic*:}, leftmargin=2.5em, align=left, labelwidth=*, labelindent=0pt, itemsep=0.3em, topsep=0.3em, parsep=0pt}
\setlist[proofcases,2]{label=\textit{Subcaso \arabic{proofcasesi}.\arabic*:}, leftmargin=2.5em, align=left, labelwidth=*, labelindent=0pt, itemsep=0.2em}

\newlist{properties}{itemize}{1}
\setlist[properties]{
  label=\textbullet,
  leftmargin=2.2em,
  topsep=2.5pt plus 1pt minus 1pt,
  itemsep=2pt plus 1pt,
  parsep=0pt,
  partopsep=0pt
}
\newcommand{\propitem}[1]{\item \textbf{#1.}\enskip\ignorespaces}

\newlist{enuthm}{enumerate}{1}
\setlist[enuthm,1]{label=\normalfont\arabic*., leftmargin=\myleftmargin, topsep=0pt, partopsep=0pt, parsep=0pt, itemsep=0.4ex plus 0.1ex, before=\leavevmode}

% =========================================================
% 11. REFERENCIAS INTELIGENTES (CLEVEREF + SREF SUITE)
% =========================================================
\if@isenglish
  \RequirePackage[english,noabbrev]{cleveref}
  \crefname{theorem}{Theorem}{Theorems} \Crefname{theorem}{Theorem}{Theorems}
  \crefname{lemma}{Lemma}{Lemmas} \Crefname{lemma}{Lemma}{Lemmas}
  \crefname{proposition}{Proposition}{Propositions} \Crefname{proposition}{Proposition}{Propositions}
  \crefname{corollary}{Corollary}{Corollaries} \Crefname{corollary}{Corollary}{Corollaries}
  \crefname{definition}{Definition}{Definitions} \Crefname{definition}{Definition}{Definitions}
  \crefname{chapter}{Chapter}{Chapters} \Crefname{chapter}{Chapter}{Chapters}
  \crefname{section}{Section}{Sections} \Crefname{section}{Section}{Sections}
  \crefname{algorithm}{Algorithm}{Algorithms} \Crefname{algorithm}{Algorithm}{Algorithms}
  \crefname{casocounter}{Case}{Cases} \Crefname{casocounter}{Case}{Cases}
  \crefname{exercise}{Exercise}{Exercises} \Crefname{exercise}{Exercise}{Exercises}
  \crefname{example}{Example}{Examples} \Crefname{example}{Example}{Examples}
  \crefname{solution}{Solution}{Solutions} \Crefname{solution}{Solution}{Solutions}
\else
  \RequirePackage[spanish,noabbrev]{cleveref}
  \crefname{theorem}{Teorema}{Teoremas} \Crefname{theorem}{Teorema}{Teoremas}
  \crefname{lemma}{Lema}{Lemas} \Crefname{lemma}{Lema}{Lemas}
  \crefname{proposition}{Proposición}{Proposiciones} \Crefname{proposition}{Proposición}{Proposiciones}
  \crefname{corollary}{Corolario}{Corolarios} \Crefname{corollary}{Corolario}{Corolarios}
  \crefname{definition}{Definición}{Definiciones} \Crefname{definition}{Definición}{Definiciones}
  \crefname{chapter}{Capítulo}{Capítulos} \Crefname{chapter}{Capítulo}{Capítulos}
  \crefname{section}{Sección}{Secciones} \Crefname{section}{Sección}{Secciones}
  \crefname{algorithm}{Algoritmo}{Algoritmos} \Crefname{algorithm}{Algoritmo}{Algoritmos}
  \crefname{casocounter}{Caso}{Casos} \Crefname{casocounter}{Caso}{Casos}
  \crefname{exercise}{Ejercicio}{Ejercicios} \Crefname{exercise}{Ejercicio}{Ejercicios}
  \crefname{example}{Ejemplo}{Ejemplos} \Crefname{example}{Ejemplo}{Ejemplos}
  \crefname{solution}{Solución}{Soluciones} \Crefname{solution}{Solución}{Soluciones}
\fi

\newcommand{\nameditem}[2][]{\item \textup{\textbf{(#2)}}\ \ifx&#1&\else\protected@edef\@currentlabel{\textup{\theenumi~\textbf{(#2)}}}\label{#1}\fi}

\newcommand{\@srefcontent}[1]{%
  \@ifundefined{r@#1}{#1}{\ref{#1}}%
}

% Suite de Referencias Bourbaki / IHÉS
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

\NewDocumentCommand{\csref}{s o m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
}

\NewDocumentCommand{\namedsref}{s o m m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#5}{\sref{#3}}{\sref{#3}[#5]}%
  }{%
    \IfNoValueTF{#5}{\sref[#2]{#3}}{\sref[#2]{#3}[#5]}%
  }%
  \nobreakspace\textit{(#4)}%
}

\NewDocumentCommand{\titref}{s o m m o}{%
  \hyperref[#3]{#4}%
  \nobreakspace
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#5}{\sref{#3}}{\sref{#3}[#5]}%
  }{%
    \IfNoValueTF{#5}{\sref[#2]{#3}}{\sref[#2]{#3}[#5]}%
  }%
}

\NewDocumentCommand{\autonamedsref}{s o m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
  \IfBlankF{\nameref*{#3}}{\nobreakspace\textit{(\nameref*{#3})}}%
}

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

% =========================================================
% 12. ENTORNOS DE CÓDIGO EJECUTABLE (MINTED / PYTHON)
% =========================================================
\newtcblisting{pseudocodigo}[2][]{listing engine=minted, minted language=#2, minted options={linenos, breaklines, fontsize=\small}, listing only, title={\textbf{#1}}, colback=white, colframe=MidnightBlue!60!black, sharp corners, boxrule=0.5pt, left=2mm, top=2mm, bottom=2mm, breakable}

\definecolor{codebg}{HTML}{F8F9FA} \definecolor{codeframe}{HTML}{2C3E50} \definecolor{libframe}{HTML}{16A085} \definecolor{termbg}{HTML}{1E1E1E}     

\newtcblisting{pythonlib}[2][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, listing file=#2.py, title={\textbf{\# Librería Python}\ifx&#1&\else: $\ \ \blacktriangleright \ \ $ #1\fi \hfill \texttt{\detokenize{#2}.py}}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\newtcblisting{pythonexec}[1][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, listing file=\jobname-script.py, title={\textbf{>\_ Código Python (Ejecutable)}\ifx&#1&\else $\ \ \blacktriangleright \ \ $ #1\fi}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\AfterEndEnvironment{pythonexec}{\immediate\write18{python3 "\jobname-script.py" > "\jobname-output.txt" 2>&1}\vspace{-1.5ex}\tcbinputlisting{enhanced, breakable, drop fuzzy shadow, listing file=\jobname-output.txt, listing only, listing engine=minted, minted language=text, minted options={fontsize=\small, breaklines}, colback=black!2, colframe=black!40, coltext=black!90, coltitle=black!80, colbacktitle=black!8, arc=2pt, boxrule=0.5pt, left=4mm, top=1mm, bottom=2mm, title={\textbf{\textbf{>\_}} \ Salida estándar (stdout)}, fonttitle=\small\bfseries, titlerule=0.5pt, titlerule style={black!20}}}

\newtcblisting{pythoncode}[1][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, title={\textbf{\texttt{</>}\  Código Python}\ifx&#1&\else: #1\fi}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\newcounter{condcounter}
\newenvironment{conditions}{%
    \setcounter{condcounter}{0}%
    \[\left\{\begin{tabular}{@{}l@{\quad}l@{}}%
}{%
    \end{tabular}\right.\]\ignorespacesafterend
}
\newcommand{\conditem}{\stepcounter{condcounter}\textbf{\arabic{condcounter}.}~}

% =========================================================
% 13. SUITE MATEMÁTICA INTEGRAL (EGA, SGA, HACES Y ÁLGEBRA)
% =========================================================

% ---------------------------------------------------------
% 13.1 CONSTANTES, CONJUNTOS NUMÉRICOS Y CONECTORES
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
\providecommand{\Rn}{\symbb{R}^{n}}
\newcommand{\PP}{\symbb{P}} 
\providecommand{\A}{\symbb{A}}
\newcommand{\Lr}{\symcal{L}}

\providecommand{\ie}{\textit{i.e.}\,}
\providecommand{\tq}{\text{ t.q. }}
\newcommand{\syss}{\,si y solo si\,}

% ---------------------------------------------------------
% 13.2 DELIMITADORES Y VECTORES
% ---------------------------------------------------------
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\absolute}{\lvert}{\rvert}
\DeclarePairedDelimiter{\inner}{\langle}{\rangle}
\DeclarePairedDelimiterX{\interno}[2]{\langle}{\rangle}{\mkern 2mu #1, #2 \mkern 2mu}

\providecommand{\mat}[1]{\symbf{#1}}
\providecommand{\vect}[1]{\symbf{#1}}
\providecommand{\glie}[1]{\symfrak{gl}(#1)}
\providecommand{\evec}[2]{\symbfup{Vec}_{#1}(#2)}

% ---------------------------------------------------------
% 13.3 HACES Y GAVILLAS (Sheaves)
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

% Funtores de haces con micro-kerning estilo IHÉS
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
% 13.4 CATEGORÍAS (Bourbaki: Siempre en \symbfup)
% ---------------------------------------------------------
\newcommand{\Set}{\symbfup{Set}}
\newcommand{\ETop}{\symbfup{Top}}
\newcommand{\HTop}{\symbfup{hTop}}
\newcommand{\Grp}{\symbfup{Grp}}
\newcommand{\Ab}{\symbfup{Ab}}
\newcommand{\Rng}{\symbfup{Rng}}
\newcommand{\CRing}{\symbfup{CRing}}
\newcommand{\Mod}{\symbfup{Mod}}
\newcommand{\Ev}{\symbfup{Vect}}
\newcommand{\Evn}{\symbfup{Norm}}
\newcommand{\EBan}{\symbfup{Ban}}
\newcommand{\EHil}{\symbfup{Hilb}}
\newcommand{\Sch}{\symbfup{Sch}}
\newcommand{\AffSch}{\symbfup{AffSch}}
\newcommand{\QCoh}{\symbfup{QCoh}}
\newcommand{\Coh}{\symbfup{Coh}}
\newcommand{\Posets}{\symbfup{Posets}}
\newcommand{\MCom}{\symbfup{Met}_{\mathrm{comp}}}

\newcommand{\Db}{\symbfup{D}^{\mathrm{b}}}
\newcommand{\Rder}{\symbfup{R}}
\newcommand{\Lder}{\symbfup{L}}
\newcommand{\Cls}{\symcal{C}}

\newcommand{\Evf}{\Ev(F)}
\newcommand{\Evc}{\Ev(\C)}
\newcommand{\Evr}{\Ev(\R)}
\newcommand{\RMod}{\Mod(R)}

% ---------------------------------------------------------
% 13.5 OPERADORES ALGEBRAICOS Y GEOMÉTRICOS (EGA / SGA)
% ---------------------------------------------------------
\DeclareMathOperator{\id}{id}
\DeclareMathOperator{\Id}{Id}
\DeclareMathOperator{\rg}{rg}
\DeclareMathOperator{\rk}{rk}
\DeclareMathOperator{\rank}{rk}
\DeclareMathOperator{\Hom}{Hom}
\DeclareMathOperator{\End}{End}
\DeclareMathOperator{\Aut}{Aut}
\DeclareMathOperator{\Ext}{Ext}
\DeclareMathOperator{\Tor}{Tor}
\DeclareMathOperator{\Ker}{Ker}
\DeclareMathOperator{\im}{Im}
\DeclareMathOperator{\Image}{Im}
\DeclareMathOperator{\Coker}{Coker}
\DeclareMathOperator{\Coim}{Coim}
\DeclareMathOperator{\Codim}{Codim}
\DeclareMathOperator{\codim}{codim}
\DeclareMathOperator{\Ind}{Ind}
\DeclareMathOperator{\ind}{Ind}
\DeclareMathOperator{\GL}{GL}
\DeclareMathOperator{\Gl}{GL}
\DeclareMathOperator{\SL}{SL}
\DeclareMathOperator{\Tr}{Tr}
\DeclareMathOperator{\Span}{Span}
\DeclareMathOperator{\mcd}{mcd}
\DeclareMathOperator{\Nat}{Nat}

\DeclareMathOperator{\Spec}{Spec}
\DeclareMathOperator{\Specmax}{Specmax}
\DeclareMathOperator{\Spm}{Spm}
\DeclareMathOperator{\Proj}{Proj}
\DeclareMathOperator{\Supp}{Supp}
\DeclareMathOperator{\Ann}{Ann}
\DeclareMathOperator{\ann}{ann}
\DeclareMathOperator{\Ass}{Ass}
\DeclareMathOperator{\Frac}{Frac}
\DeclareMathOperator{\Sym}{Sym}
\DeclareMathOperator{\Rad}{Rad}
\DeclareMathOperator{\nil}{nil}
\DeclareMathOperator{\Der}{Der}
\DeclareMathOperator{\Tan}{Tan}
\DeclareMathOperator{\Pic}{Pic}
\DeclareMathOperator{\Div}{Div}
\DeclareMathOperator{\divop}{div}
\DeclareMathOperator{\prof}{prof}
\DeclareMathOperator{\dhdim}{dh}
\DeclareMathOperator{\grade}{grade}
\DeclareMathOperator{\Height}{ht}
\DeclareMathOperator{\degre}{deg}
\DeclareMathOperator{\interior}{int}
\DeclareMathOperator{\alt}{Alt}

% Límites categóricos estilo Bourbaki
\newcommand{\dirlim}{\varinjlim}
\newcommand{\invlim}{\varprojlim}
\newcommand{\morf}[3]{\Hom_{#1}(#2, #3)}

% ---------------------------------------------------------
% 13.6 OPERADORES DE ANÁLISIS, PROBABILIDAD Y OPTIMIZACIÓN
% ---------------------------------------------------------
\DeclareMathOperator{\sen}{sen}
\DeclareMathOperator{\arcsen}{arcsen}
\DeclareMathOperator{\sgn}{sgn}
\DeclareMathOperator{\Dom}{Dom}
\DeclareMathOperator{\dom}{dom}
\DeclareMathOperator{\dir}{dir}
\DeclareMathOperator{\gph}{gph}
\DeclareMathOperator{\ctp}{Ctp.}
\DeclareMathOperator{\con}{con}
\DeclareMathOperator{\pos}{pos}
\DeclareMathOperator{\bdry}{bdry}
\DeclareMathOperator{\Dif}{Dif}
\DeclareMathOperator{\rel}{rel}
\DeclareMathOperator{\co}{co}
\DeclareMathOperator{\core}{core}
\DeclareMathOperator{\lin}{lin}
\DeclareMathOperator{\aff}{aff}
\DeclareMathOperator{\val}{val}
\DeclareMathOperator{\epi}{epi}
\DeclareMathOperator{\lev}{lev}
\DeclareMathOperator{\cl}{cl}
\DeclareMathOperator{\dist}{dist}
\DeclareMathOperator{\rge}{rge}
\DeclareMathOperator{\cond}{cond}
\DeclareMathOperator{\diag}{diag}

\DeclareMathOperator*{\argmin}{argmin}
\DeclareMathOperator*{\argmax}{argmax}
\DeclareMathOperator*{\conv}{conv}
\DeclareMathOperator*{\osc}{osc}
\DeclareMathOperator*{\rint}{rint}
\DeclareMathOperator*{\ri}{ri}

\newcommand{\re}[1]{\symfrak{R} (#1)}
\renewcommand{\im}[1]{\symfrak{I} (#1)}
\newcommand{\episum}{\mathbin{\#}}
\newcommand{\epimult}{\star}

\providecommand{\serie}[1]{({#1}_{n})_{n=0}^\infty}
\providecommand{\probability}[1][]{\symbb{P}\ifx&#1&\else\mleft[#1\mright]\fi}
\providecommand{\expectation}[1]{\symbb{E}\mleft[#1\mright]}
\DeclareMathOperator{\Var}{Var}
\providecommand{\variance}[1]{\Var\mleft(#1\mright)}
\providecommand{\randomVariable}{X}
\newcommand{\probabilitySpace}{\ensuremath{(\Omega, \mathcal{F}, \symbb{P})}}
\providecommand{\borelian}{\mathcal{B}}
\providecommand{\indexFinite}{\mathcal{I}}
\providecommand{\vareal}{\textit{v.a.r.}}
\providecommand{\randomVariableSequence}{\ensuremath{\{X_n\}_{n \ge 1}}}

\newcommand{\ent}{\Rightarrow\quad &}

% Mapas, morfismos y cartas
\newcommand{\chart}[2]{\left(#1, #2\right)}
\newcommand{\chartcoords}[2]{\left(#1, \left(#2^1, \dots, #2^n\right)\right)}
\newcommand{\rest}[2]{{#1|}_{#2}}
\newcommand{\transmap}[2]{#2 \circ #1^{-1}}

\newcommand{\map}[6]{%
    \begin{array}{@{} r @{\,} c @{\;} c @{\;} c @{} l @{}}
      #1 \colon & \displaystyle #2 & \longrightarrow & \displaystyle #3 & \\
      \ifstrempty{#4}{}{%
        & \displaystyle #4 & \longmapsto & \displaystyle #5 & \displaystyle {}#6
      }%
    \end{array}
}

\newcommand{\inmap}[3]{#1 : #2 \longrightarrow #3}
\newcommand{\mapchain}[7]{#1 \xrightarrow{#5} #2 \xrightarrow{#6} #3 \xrightarrow{#7} #4}

\NewDocumentCommand{\Fobj}{ m m m m m }{%
  #1 \coloneq
  \left\{
    \begin{aligned}
      #2 &\longrightarrow #3 \\
      #4 &\longmapsto #5
    \end{aligned}
  \right.
}

% Paquete Optidef con traducciones multilingües
\RequirePackage[]{optidef}

\if@isenglish
  \newcommand{\optmin}{minimize} \newcommand{\optmax}{maximize} \newcommand{\optst}{subject~to}
\else
  \newcommand{\optmin}{minimizar} \newcommand{\optmax}{maximizar} \newcommand{\optst}{sujeto~a}
\fi

\renewcommand{\setFormatLong}[2]{\global\def\localProblemFormat{l}\let\bodyobj\bodyobjLong \ifthenelse{\equal{#1}{minimize}}{\renewcommand{\localProblemType}{\optmin}}{\ifthenelse{\equal{#1}{maximize}}{\renewcommand{\localProblemType}{\optmax}}{\ifthenelse{\equal{#1}{arg~min}}{\renewcommand{\localProblemType}{arg~\optmin}}{\ifthenelse{\equal{#1}{arg~max}}{\renewcommand{\localProblemType}{arg~\optmax}}{\renewcommand{\localProblemType}{#1}}}}}}
\renewcommand{\setFormatShort}[2]{\global\def\localProblemFormat{s}\let\bodyobj\bodyobjShort \ifthenelse{\equal{#1}{min}}{\renewcommand{\localProblemType}{mín}}{\ifthenelse{\equal{#1}{max}}{\renewcommand{\localProblemType}{máx}}{\ifthenelse{\equal{#1}{arg~min}}{\renewcommand{\localProblemType}{arg~mín}}{\ifthenelse{\equal{#1}{arg~max}}{\renewcommand{\localProblemType}{arg~máx}}{\renewcommand{\localProblemType}{#1}}}}}}
\renewcommand{\bodyobjLong}[4]{\ifthenelse{\isempty{#4}}{&\mathmakebox[\widthof{$\underset{#1}{\mathrm{\optmin}}$}][l]{\underset{#1}{\mathrm{\localProblemType}}} \quad #2\span\span\span\span}{#4~&\mathmakebox[\widthof{$\underset{#1}{\mathrm{\optmin}}$}][l]{\underset{#1}{\mathrm{\localProblemType}}} \quad #2\span\span\span\span}}
\renewcommand{\bodyobjShort}[4]{\ifthenelse{\isempty{#4}}{&\mathmakebox[\widthof{$\underset{#1}{\mathrm{s.~a.}}$}][l]{\underset{#1}{\mathrm{\localProblemType}}} \quad #2\span\span\span\span}{#4 ~ &\mathmakebox[\widthof{$\underset{#1}{\mathrm{s.~a.}}$}][l]{\underset{#1}{\mathrm{\localProblemType}}} \quad #2\span\span\span\span}}
\RenewDocumentCommand{\bodyconst}{m G{}}{\ifthenelse{\equal{\localProblemFormat}{s}}{\equalsNothing{#2}{\\ &\mathmakebox[\widthof{$\underset{\phantom{\localOptimalVariable}}{\mathrm{s.~a.}}$}][l]{\underset{\phantom{\localOptimalVariable}}{\mathrm{s.~a.}}} \quad &&#1 #2}{\\ &\mathmakebox[\widthof{$\underset{\phantom{\localOptimalVariable}}{\mathrm{s.~a.}}$}][l]{\underset{\phantom{\localOptimalVariable}}{\mathrm{s.~a.}}}  \quad &#1 & #2}}{\equalsNothing{#2}{\\ &\mathmakebox[\widthof{$\underset{\phantom{\localOptimalVariable}}{\mathrm{\optmin}}$}][l]{\underset{\phantom{\localOptimalVariable}}{\mathrm{\optst}}} \quad &&#1 #2}{\\ &\mathmakebox[\widthof{$\underset{\phantom{\localOptimalVariable}}{\mathrm{\optmin}}$}][l]{\underset{\phantom{\localOptimalVariable}}{\mathrm{\optst}}}  \quad &#1 & #2}}}

% Diagrama de transición entre cartas
\newcommand{\transitiondiagram}[7]{%
  \begin{equation*}
  \begin{tikzpicture}[scale=0.85, baseline=(current bounding box.center)]
    \draw[smooth cycle, tension=0.7, fill=gray!3, draw=gray] plot coordinates {(-1,1.5) (1,2) (3,1.5) (2,0) (0,0)};
    \node at (2.5,1.7) {$#1$};
    \draw[fill=blue!8, opacity=0.6, draw=blue!40] (0.5,0.8) circle (0.7cm);
    \draw[fill=red!8, opacity=0.6, draw=red!40] (1.3,0.8) circle (0.7cm);
    \node at (0.2,1.4) {$#2$}; \node at (1.6,1.4) {$#3$};
    \begin{scope}\clip (0.5,0.8) circle (0.7cm);\fill[purple!15] (1.3,0.8) circle (0.7cm);\end{scope}
    \node at (0.9,0.8) {\tiny $#2 \cap #3$};
    \draw[gray, ->] (-2,-2.3) -- (-0.5,-2.3) node[right, black] {$#6$};
    \draw[gray, ->] (-2.2,-2.5) -- (-2.2,-1.0);
    \draw[fill=blue!4, draw=blue!30] (-1.3,-1.7) circle (0.5cm); \node at (-1.3,-1.7) {\small $#4(#2)$};
    \draw[gray, ->] (2,-2.3) -- (3.5,-2.3) node[right, black] {$#7$};
    \draw[gray, ->] (1.8,-2.5) -- (1.8,-1.0);
    \draw[fill=red!4, draw=red!30] (2.7,-1.7) circle (0.5cm); \node at (2.7,-1.7) {\small $#5(#3)$};
    \draw[->, thick, bend right, draw=blue!80] (0.3,0.6) to node[left, black] {$#4$} (-1.2,-1.1);
    \draw[->, thick, bend left, draw=red!80] (1.5,0.6) to node[right, black] {$#5$} (2.6,-1.1);
    \draw[->, thick, purple, bend right=15] (-0.6,-1.7) to node[above, black] {\small $#5 \circ #4^{-1}$} (2.0,-1.7);
    \draw[<-, thick, orange, bend left=15] (-0.6,-1.9) to node[below, black] {\small $#4 \circ #5^{-1}$} (2.0,-1.9);
  \end{tikzpicture}
  \end{equation*}
}

% =========================================================
% 14. DISEÑO DE PORTADAS (DUAL: ARTÍCULO Y LIBRO)
% =========================================================
\def\@universidad{} \newcommand{\universidad}[1]{\def\@universidad{#1}}
\def\@facultad{}    \newcommand{\facultad}[1]{\def\@facultad{#1}}
\def\@curso{}       \newcommand{\curso}[1]{\def\@curso{#1}}
\def\@codigo{}      \newcommand{\codigo}[1]{\def\@codigo{#1}}
\def\@semestre{}    \newcommand{\semestre}[1]{\def\@semestre{#1}}

\def\shorttitle{}   \def\@title{}
\renewcommand{\title}[2][]{\def\shorttitle{#1}\def\@title{#2}}

\def\shortauthor{}  \def\@author{}
\renewcommand{\author}[2][]{\def\shortauthor{#1}\def\@author{#2}}

\def\@profesor{}    \newcommand{\profesor}[1]{\def\@profesor{#1}}
\def\@asistente{}   \newcommand{\asistente}[1]{\def\@asistente{#1}}
\def\@email{}       \newcommand{\email}[1]{\def\@email{#1}}
\def\@orcid{}       \newcommand{\orcid}[1]{\def\@orcid{#1}}
\def\@lugar{}       \newcommand{\lugar}[1]{\def\@lugar{#1}}
\def\@version{}     \newcommand{\version}[1]{\def\@version{#1}}
\def\@logo{}        \newcommand{\logo}[1]{\def\@logo{#1}}
\def\@referencias{} \newcommand{\referencias}[1]{\def\@referencias{#1}}

% Compatibilidad residual
\providecommand{\address}[2][]{\def\@address{#2}}
\providecommand{\subjclass}[2][]{\def\@subjclass{#2}} 
\providecommand{\keywords}[1]{\def\@keywords{#1}}
\providecommand{\dedicatory}[1]{\def\@dedicatory{#1}}

\if@isarticle
  % ---------------------------------------------------------
  % 14A. ENCABEZADO TÉCNICO PREMIUM (MODO ARTÍCULO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \thispagestyle{plain}
    
    \vspace*{-3em}
    \noindent\textcolor{MidnightBlue!30}{\rule{\textwidth}{1pt}}\par\vspace{1.5ex}
    
    % Bloque 1: Logo (Izquierda) y Contexto (Derecha)
    \noindent
    \ifx\@logo\@empty
      \begin{minipage}[c]{\textwidth}
        \begin{flushright}
    \else
      \begin{minipage}[c]{0.12\textwidth}
        \includegraphics[width=\linewidth]{\@logo}
      \end{minipage}%
      \hfill
      \begin{minipage}[c]{0.84\textwidth}
        \begin{flushright}
    \fi
          \ifx\@universidad\@empty\else
            {\sffamily\small\bfseries\textcolor{MidnightBlue}{\@universidad}}\\[0.4ex]
          \fi
          \ifx\@facultad\@empty\else
            {\sffamily\small\textcolor{MidnightBlue!70!black}{\@facultad}}\\[0.4ex]
          \fi
          \ifx\@curso\@empty\else
            {\sffamily\footnotesize\color{gray}\@curso 
            \ifx\@codigo\@empty\else\ (\@codigo)\fi 
            \ifx\@semestre\@empty\else\ -- \@semestre\fi}
          \fi
        \end{flushright}
      \end{minipage}
      
    \par\vspace{2.5ex}
    
    % Bloque 2: Título y Autor
    \begin{tcolorbox}[
      enhanced,
      breakable,
      colback=MidnightBlue!2,
      colframe=MidnightBlue!2,
      borderline west={3pt}{0pt}{MidnightBlue},
      boxrule=0pt,
      arc=3pt,
      left=12pt,
      top=8pt,
      bottom=8pt
    ]
      \begin{flushleft}
        \ifx\@title\@empty\else
          {\LARGE \bfseries \textcolor{black!40!MidnightBlue}{\@title}\par}\vspace{1.2ex}
        \fi
        \ifx\shorttitle\@empty\else
          {\large \bfseries \textcolor{MidnightBlue!60!black}{\shorttitle}\par}\vspace{1.2ex}
        \fi
        \ifx\@author\@empty\else
          {\large \bfseries \textcolor{black}{\@author}}\\[0.4ex]
        \fi
        \ifx\@email\@empty\else
          {\sffamily\small\textcolor{MidnightBlue}{\@email}}\enskip
        \fi
        \ifx\@orcid\@empty\else
          \orcidlogo\ \href{https://orcid.org/\@orcid}{\footnotesize\sffamily\@orcid}
        \fi
      \end{flushleft}
    \end{tcolorbox}
    
    \vspace{2ex}
    
    % Bloque 3: Metadatos y Referencias (A 2 Columnas)
    \noindent
    \begin{minipage}[t]{0.45\textwidth}
      \sffamily\footnotesize% 
      \ifx\@profesor\@empty\else 
        \textcolor{MidnightBlue!80!black}{\textbf{Profesor:}} \textcolor{black}{\@profesor}\par\vspace{0.8ex}
      \fi
      \ifx\@asistente\@empty\else 
        \textcolor{MidnightBlue!80!black}{\textbf{Jefe de Prácticas:}} \textcolor{black}{\@asistente}\par\vspace{0.8ex}
      \fi
      \textcolor{MidnightBlue!80!black}{\textbf{Fecha:}} \textcolor{black}{\@date} \ifx\@lugar\@empty\else\ \textcolor{gray}{(\@lugar)}\fi\par\vspace{0.8ex}%
      \ifx\@version\@empty\else 
        \textcolor{MidnightBlue!80!black}{\textbf{Versión:}} \textcolor{black}{\@version}\par\vspace{0.8ex}
      \fi
    \end{minipage}%
    \hfill
    \begin{minipage}[t]{0.50\textwidth}
      \sffamily\footnotesize% 
      \ifx\@referencias\@empty\else
        \textcolor{MidnightBlue!80!black}{\textbf{\coverrefname:}}\par\vspace{0.8ex}%
        {\color{gray!90!black}\@referencias}
      \fi
    \end{minipage}
    
    \par\vspace{2.5ex}
    \noindent\textcolor{MidnightBlue}{\rule{\textwidth}{1.2pt}}
    \par\vspace{2.5em}
  }
\else
  % ---------------------------------------------------------
  % 14B. PORTADA A PÁGINA COMPLETA (MODO LIBRO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \begin{titlepage}
      \thispagestyle{empty} 
      
      \vspace*{0.5cm}
      \noindent
      \begin{minipage}[t]{0.3\textwidth}
        \vspace{0pt}
        \ifx\@logo\@empty\else
          \includegraphics[width=0.85\linewidth]{\@logo}
        \fi
      \end{minipage}%
      \hfill \begin{minipage}[t]{0.65\textwidth}
        \vspace{0pt}
        \begin{flushright}
          \ifx\@universidad\@empty\else
            {\LARGE\sffamily\bfseries \textcolor{MidnightBlue!90!black}{\@universidad}}\\[0.5ex]
          \fi
          \ifx\@facultad\@empty\else
            {\Large\sffamily \textcolor{MidnightBlue!80!black}{\@facultad}}\\[1ex]
          \fi
          \ifx\@curso\@empty\else
            {\large\sffamily\color{gray}\@curso
            \ifx\@codigo\@empty\else\ \textbf{--} \@codigo\fi}\\[0.5ex]
          \fi
          \ifx\@semestre\@empty\else
            {\small\sffamily \textcolor{MidnightBlue!50}{\@semestre}}
          \fi
        \end{flushright}
      \end{minipage}
      
      \vspace{3.0cm}
      
      \begin{tcolorbox}[
        blanker, borderline west={4pt}{0pt}{MidnightBlue!80!black}, 
        left=15pt, top=5pt, bottom=5pt
      ]
        \ifx\@title\@empty\else
          {\Huge \bfseries \textcolor{MidnightBlue!90!black}{\@title}}\\[1.5ex]
        \fi
        \ifx\shorttitle\@empty\else
          {\LARGE \textit{\textcolor{MidnightBlue!60}{\shorttitle}}}
        \fi
      \end{tcolorbox}
      
      \vfill
      
      \noindent
      \begin{minipage}[b]{0.48\textwidth}
        \ifx\@referencias\@empty\else
          \vspace*{0pt} 
          {\sffamily\small\bfseries\textcolor{MidnightBlue!60!black}{\coverrefname}}\\[1ex]
          {\footnotesize\color{gray}\@referencias}
        \fi
      \end{minipage}%
      \hfill
      \begin{minipage}[b]{0.48\textwidth}
        \begin{flushright}
          \ifx\@author\@empty\else
            {\Large \bfseries \@author}\\[0.4ex]
          \fi
          \ifx\@email\@empty\else
            {\small \sffamily \textcolor{MidnightBlue!70}{\@email}}\\[1.0ex]
          \fi
          \ifx\@orcid\@empty\else
            \orcidlogo\ \href{https://orcid.org/\@orcid}{\footnotesize\sffamily\@orcid}\\[1.5ex]
          \fi
          \ifx\@profesor\@empty\else
            {\large \color{gray}Profesor: \@profesor}\\[0.4ex]
          \fi
          \ifx\@asistente\@empty\else
            {\normalsize \color{gray}Jefe de Prácticas: \@asistente}\\[1ex]
          \fi
          \vspace{1.2cm}
          \ifx\@lugar\@empty\else
            {\large \sffamily \color{gray}\@lugar}\\[0.4ex]
          \fi
          {\large \sffamily \color{gray}\@date}\\[0.4ex]
          \ifx\@version\@empty\else
            {\small \sffamily \color{gray}Versión \@version}
          \fi
        \end{flushright}
      \end{minipage}
      
      \vspace*{1.5cm}
    \end{titlepage}
    \cleardoublepage
  }
\fi

\AtBeginDocument{
  \hypersetup{pdftitle={\shorttitle}, pdfauthor={\shortauthor}, pdfsubject={\@curso}}
}

% Comandos para secciones no numeradas en TOC
\newcommand{\addsubsec}[1]{%
  \phantomsection
  \subsection*{#1}%
  \addcontentsline{toc}{subsection}{#1}%
}

\newcommand{\addsubsubsec}[1]{%
  \phantomsection
  \subsubsection*{#1}%
  \addcontentsline{toc}{subsubsection}{#1}%
}

\endinput
