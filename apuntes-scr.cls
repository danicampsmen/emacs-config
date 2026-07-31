%% apuntes-scr.cls
%% Clase Maestra para Apuntes Personales (Libros) y Artículos
%% VERSIÓN 4.4 - MULTILINGÜE, DRAFT, INDEX Y SIN BUGS DE CATCODE
%% --------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{apuntes-scr}[2025/01/21 v4.4 Apuntes - LuaLaTeX]

% =========================================================
% 0. LÓGICA DE OPCIONES (TIPO, IDIOMA Y MODO DRAFT)
% =========================================================
\newif\if@isarticle \@isarticlefalse 
\newif\if@isenglish \@isenglishfalse
\newif\if@fastmode  \@fastmodefalse

% Opciones de la clase
\DeclareOption{article}{\@isarticletrue}
\DeclareOption{book}{\@isarticlefalse}
\DeclareOption{english}{\@isenglishtrue}
\DeclareOption{spanish}{\@isenglishfalse}
\DeclareOption{fast}{\@fastmodetrue}

% Pasar cualquier otra opción (como el tamaño de fuente) a la clase base
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\if@isarticle scrartcl\else scrbook\fi}}

% Establecer 10pt como tamaño base por defecto
\PassOptionsToClass{10pt}{\if@isarticle scrartcl\else scrbook\fi}

\ProcessOptions\relax

% Modo Borrador (Acelera compilación)
\if@fastmode
  \PassOptionsToClass{draft}{\if@isarticle scrartcl\else scrbook\fi}
  \PassOptionsToPackage{draft}{minted}
\fi

% Carga dinámica de KOMA-Script (¡sin el 10pt forzado!)
\if@isarticle
  \LoadClass[a4paper, twoside, bibliography=totoc, index=totoc, numbers=enddot]{scrartcl}
\else
  \LoadClass[a4paper, twoside, open=any, bibliography=totoc, index=totoc, numbers=enddot]{scrbook}
\fi

\setcounter{tocdepth}{2}

% =========================================================
% 1. DICCIONARIO Y TRADUCCIONES AUTOMÁTICAS
% =========================================================
\if@isenglish
  \RequirePackage[english]{babel}
  \newcommand{\indexnamecustom}{Index}
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
  \addto\captionsenglish{\renewcommand{\proofname}{\textbf{\textit{Proof}}}}
\else
  \RequirePackage[spanish,es-nodecimaldot,es-sloppy]{babel}
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
  \addto\captionsspanish{\renewcommand{\proofname}{\textbf{\textit{Prueba}}}}
\fi

% =========================================================
% 2. PAQUETES ESENCIALES E ÍNDICE ALFABÉTICO
% =========================================================
\RequirePackage{mathtools}
\RequirePackage{amssymb}      
\RequirePackage{fontspec}
\RequirePackage{unicode-math}
\RequirePackage{imakeidx}
\makeindex[intoc, columns=2, title=\indexnamecustom]

\RequirePackage{luamplib} \mplibforcehmode \RequirePackage{tikz}
\usetikzlibrary{cd, graphs, graphdrawing, arrows.meta, calc, positioning, shapes.geometric, intersections, decorations.pathmorphing}
\usegdlibrary{trees, layered, force} \RequirePackage{pgfplots} \pgfplotsset{compat=1.18}
\RequirePackage[twoside, inner=20mm, outer=20mm, top=20mm, bottom=20mm, bindingoffset=0mm]{geometry}
\raggedbottom \widowpenalty=10000 \clubpenalty=10000 \brokenpenalty=10000

\RequirePackage[headsepline=0.5pt, plainheadsepline]{scrlayer-scrpage}
\clearpairofpagestyles \ohead{\pagemark} \ihead{\headmark} \pagestyle{scrheadings}
\addtokomafont{pageheadfoot}{\normalfont\itshape\small} \addtokomafont{pagenumber}{\normalfont\bfseries}
\addtokomafont{caption}{\small\itshape} \addtokomafont{captionlabel}{\small\bfseries} \setcapindent{1em}                   

\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{graphicx} \RequirePackage{import} \RequirePackage{transparent} \RequirePackage{float}
\RequirePackage{booktabs} \RequirePackage{tabularray} \RequirePackage{varwidth} \RequirePackage{ragged2e}
\RequirePackage{datetime2} \RequirePackage{verbatim} \RequirePackage{siunitx} \RequirePackage{tasks}
\RequirePackage{calc} % <--- AÑADIR ESTE PAQUETE AQUÍ

\settasks{ label=(\alph*), label-width=18pt, item-indent=25pt }

% ==================================================================
% --- COMANDOS EDITORIALES VISUALES ---
% ==================================================================
\definecolor{emacstodo}{HTML}{FF9900} \definecolor{emacsfixme}{HTML}{FF0000}    
\definecolor{emacsdebug}{HTML}{A020F0} \definecolor{emacsnote}{HTML}{00CCFF}     

\newcommand{\TODO}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacstodo!15}{\textcolor{emacstodo}{\sffamily\textbf{\scriptsize TODO}}}\ \textcolor{emacstodo!70!black}{\small #1}\endgroup}
\newcommand{\FIXME}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsfixme!15}{\textcolor{emacsfixme}{\sffamily\textbf{\scriptsize FIXME}}}\ \textcolor{emacsfixme!85!black}{\small\textbf{#1}}\endgroup}
\newcommand{\DEBUG}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsdebug!15}{\textcolor{emacsdebug}{\sffamily\textbf{\scriptsize DEBUG}}}\ \textcolor{emacsdebug!70!black}{\small #1}\endgroup}
\newcommand{\NOTE}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsnote!15}{\textcolor{emacsnote}{\sffamily\textbf{\scriptsize NOTE}}}\ \textcolor{emacsnote!70!black}{\small #1}\endgroup}

\RequirePackage{tcolorbox}

% NUEVA IMPLEMENTACIÓN DE RESALTADOS CON COMPATIBILIDAD PARA MÁRGENES
\RequirePackage{luacolor}
\RequirePackage{lua-ul}
\newcommand{\deftech}[1]{\highLight[pink!40]{#1}} 
\newcommand{\usual}[1]{\highLight[yellow!40]{#1}}
\newcommand{\highlightgreen}[1]{\highLight[ForestGreen!20]{#1}}

\directlua{os.setenv("TEXMF_OUTPUT_DIRECTORY", ".")} 
\tcbuselibrary{listings, breakable, skins, minted}
\RequirePackage{csquotes}
\RequirePackage{etoolbox}     

\newcommand{\mastervskip}{1.5ex plus 0.3ex minus 0.1ex}

\newtcolorbox{notabox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=MidnightBlue!5, colframe=MidnightBlue!60!black, title={\textbf{\noteboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{warningbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=red!5, colframe=red!60!black, title={\textbf{\warnboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{controlbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=ForestGreen!5, colframe=ForestGreen!40!black, title={\textbf{\ctrlboxnamecustom}\ifx&#1&\else: #1\fi}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\tcolorboxenvironment{algorithm}{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=MidnightBlue!3, colframe=MidnightBlue!80!black, drop fuzzy shadow, before skip=\mastervskip, after skip=\mastervskip, left=4mm, right=4mm, top=3mm, bottom=3mm}

\RequirePackage{setspace} \setstretch{1.15} 
\RequirePackage[backend=biber, style=alphabetic, sorting=none, backref=true]{biblatex}
\RequirePackage{microtype}
\RequirePackage[colorlinks=true, linkcolor=Red, citecolor=Red, urlcolor=Red, pdfencoding=auto, psdextra]{hyperref}
\RequirePackage{bookmark} 

\pdfstringdefDisableCommands{%
  \def\symbb#1{#1}\def\symcal#1{#1}\def\symfrak#1{#1}\def\symbf#1{#1}\def\symup#1{#1}%
  \def\R{R}\def\C{C}\def\N{N}\def\Z{Z}\def\Q{Q}\def\F{F}\def\K{K}%
  \def\inmap#1#2#3{#1: #2 -> #3}\def\chart#1#2{(#1, #2)}\def\chartcoords#1#2{(#1, #2)}\def\rest#1#2{#1}%
}
\bookmarksetup{numbered, open, openlevel=1, depth=3}

% =========================================================
% 3. VARIABLES DE ENCABEZADO Y PORTADA 
% =========================================================
% Inicialización de variables obligatorias y opcionales
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

\def\@email{}       \newcommand{\email}[1]{\def\@email{#1}} % <--- AQUÍ ESTABA EL ERROR
\def\@lugar{}       \newcommand{\lugar}[1]{\def\@lugar{#1}}
\def\@version{}     \newcommand{\version}[1]{\def\@version{#1}}
\def\@logo{}        \newcommand{\logo}[1]{\def\@logo{#1}}
\def\@referencias{} \newcommand{\referencias}[1]{\def\@referencias{#1}}

% Compatibilidad AMS residual
\providecommand{\address}[2][]{\def\@address{#2}}
\providecommand{\subjclass}[2][]{\def\@subjclass{#2}} 
\providecommand{\keywords}[1]{\def\@keywords{#1}}
\providecommand{\dedicatory}[1]{\def\@dedicatory{#1}}

% =========================================================
% 4. FUENTES Y COLORES CORPORATIVOS 
% =========================================================
\setmainfont{STIXTwoText-Regular.ttf}[
  Renderer = HarfBuzz, BoldFont = STIXTwoText-Bold.ttf, ItalicFont = STIXTwoText-Italic.ttf,
  BoldItalicFont = STIXTwoText-BoldItalic.ttf, SmallCapsFont = STIXTwoText-Regular.ttf,
  SmallCapsFeatures = {Letters=UppercaseSmallCaps}, Numbers = {Proportional, Lining}
]
\setmathfont{STIX Two Math}[StylisticSet = {1, 8}]
\setsansfont{texgyreheros-regular.otf}[Scale = MatchLowercase, BoldFont = texgyreheros-bold.otf, ItalicFont = texgyreheros-italic.otf, BoldItalicFont = texgyreheros-bolditalic.otf]
\setmonofont{inconsolata}[Scale = MatchLowercase]

\addtokomafont{disposition}{\rmfamily\bfseries}

\if@isarticle
\else
  \addtokomafont{chapter}{\Huge\bfseries\color{MidnightBlue!80!black}}
  \renewcommand*{\chapterformat}{\mbox{\fontsize{60}{65}\selectfont\color{MidnightBlue!15}\thechapter\autodot\enskip}}
  \renewcommand*{\chapterlinesformat}[3]{\parbox{\textwidth}{\raggedleft #2#3\par\vspace{-1ex}\textcolor{MidnightBlue!60!black}{\rule{\textwidth}{1.5pt}}}}
\fi

\addtokomafont{section}{\Large\color{MidnightBlue!60!black}}
\addtokomafont{subsection}{\large\color{MidnightBlue!60!black}}
\addtokomafont{part}{\color{MidnightBlue!60!black}}

% =========================================================
% 5. TEOREMAS Y ENTORNOS TRADUCIDOS
% =========================================================
\RequirePackage{amsthm} \RequirePackage{mleftright} \mleftright

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
\fi

\theoremstyle{my-remark-style}
\newtheorem*{remark}{\obsnamecustom}
\newtheorem*{commentary}{\comnamecustom}
\newtheorem*{notation}{Notación}
\newtheorem*{objetive}{Objetivo}

\newenvironment{caso}[1]{\refstepcounter{casocounter}\par\smallskip\noindent\textbf{\textcolor{MidnightBlue!90!black}{\casenamecustom\ #1:}} }{\par\smallskip}
\newenvironment{condicion}[1]{\refstepcounter{condicioncounter}\par\smallskip\noindent\textbf{\textcolor{DarkOrchid!90!black}{\condnamecustom\ #1:}} }{\par\smallskip}

\newtcolorbox{afirmacion}[1][]{enhanced, breakable, colback=NavyBlue!2, colframe=NavyBlue!25, arc=2pt, boxrule=0.5pt, before skip=1.5ex, after skip=1.5ex, title={\textbf{\textcolor{NavyBlue!95!black}{\claimnamecustom\ifx&#1&\else\ (#1)\fi}}}, coltitle=NavyBlue!95!black, fonttitle=\small\bfseries, attach title to upper, after title={:\ }, left=3mm, right=3mm, top=2mm, bottom=2mm}
\newenvironment{pruebaafirmacion}{\par\noindent\small\textit{\proofclaimnamecustom} }{\hfill\ensuremath{\lozenge}\par\smallskip}

\newcommand{\casobase}[1]{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\basecasenamecustom\ (#1):}}\ }
\newcommand{\pasoinductivo}{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\indstepnamecustom:}}\ }
\newcommand{\hipotesisind}{\par\smallskip\noindent\textbf{\textcolor{ForestGreen!90!black}{\indhypnamecustom:}}\ }

\renewcommand{\qedsymbol}{$\blacksquare$}
\renewenvironment{proof}[1][\proofname]{\par\pushQED{\qed}\normalfont \small \trivlist\item[] \textbf{\textit{#1\@addpunct{.}}}\hspace{0.5em}\ignorespaces}{\popQED\endtrivlist\@endpefalse}
\tcolorboxenvironment{proof}{blanker, breakable, left=8mm, right=8mm, top=0pt, bottom=0pt, before skip=\mastervskip, after skip=\mastervskip, borderline west={1.5pt}{0pt}{black!30}}

% =========================================================
% 6. CLEVEREF Y ENUMERADORES
% =========================================================
\if@isenglish
  \RequirePackage[english,noabbrev]{cleveref}
  \crefname{theorem}{Theorem}{Theorems} \Crefname{theorem}{Theorem}{Theorems}
  \crefname{lemma}{Lemma}{Lemmas} \Crefname{lemma}{Lemma}{Lemmas}
  \crefname{proposition}{Proposition}{Propositions} \Crefname{proposition}{Proposition}{Propositions}
  \crefname{corollary}{Corollary}{Corollaries} \Crefname{corollary}{Corollary}{Corollaries}
  \crefname{definition}{Definition}{Definitions} \Crefname{definition}{Definition}{Definitions}
  \crefname{chapter}{Chapter}{Chapters} \Crefname{chapter}{Chapter}{Chapters}
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
  \crefname{algorithm}{Algoritmo}{Algoritmos} \Crefname{algorithm}{Algoritmo}{Algoritmos}
  \crefname{casocounter}{Caso}{Casos} \Crefname{casocounter}{Caso}{Casos}
  \crefname{exercise}{Ejercicio}{Ejercicios} \Crefname{exercise}{Ejercicio}{Ejercicios}
  \crefname{example}{Ejemplo}{Ejemplos} \Crefname{example}{Ejemplo}{Ejemplos}
  \crefname{solution}{Solución}{Soluciones} \Crefname{solution}{Solución}{Soluciones}
\fi

\newcommand{\nameditem}[2][]{\item \textup{\textbf{(#2)}}\ \ifx&#1&\else\protected@edef\@currentlabel{\textup{\theenumi~\textbf{(#2)}}}\label{#1}\fi}

\RequirePackage[shortlabels]{enumitem}
\newcommand{\myleftmargin}{10mm}
\setlist[enumerate]{topsep=1ex plus 0.2ex minus 0.1ex, itemsep=0.5ex plus 0.1ex, partopsep=0pt, parsep=0pt, leftmargin=\myleftmargin, label=\normalfont\arabic*.}
\setlist[itemize]{topsep=1ex plus 0.2ex minus 0.1ex, itemsep=0.5ex plus 0.1ex, partopsep=0pt, parsep=0pt, leftmargin=\myleftmargin}

\newlist{enuthm}{enumerate}{1}
\setlist[enuthm,1]{label=\normalfont\arabic*., leftmargin=\myleftmargin, topsep=0pt, partopsep=0pt, parsep=0pt, itemsep=0.5ex plus 0.1ex, before=\leavevmode}

% =========================================================
% 7. ENTORNOS DE CÓDIGO (Minted)
% =========================================================
\newtcblisting{pseudocodigo}[2][]{listing engine=minted, minted language=#2, minted options={linenos, breaklines, fontsize=\small}, listing only, title={\textbf{#1}}, colback=white, colframe=MidnightBlue!60!black, sharp corners, boxrule=0.5pt, left=2mm, top=2mm, bottom=2mm, breakable}

\definecolor{codebg}{HTML}{F8F9FA} \definecolor{codeframe}{HTML}{2C3E50} \definecolor{libframe}{HTML}{16A085} \definecolor{termbg}{HTML}{1E1E1E}     

\newtcblisting{pythonlib}[2][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, listing file=#2.py, title={\textbf{\# Librería Python}\ifx&#1&\else: $\ \ \blacktriangleright \ \ $ #1\fi \hfill \texttt{\detokenize{#2}.py}}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\newtcblisting{pythonexec}[1][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, listing file=\jobname-script.py, title={\textbf{>\_ Código Python (Ejecutable)}\ifx&#1&\else $\ \ \blacktriangleright \ \ $ #1\fi}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\AfterEndEnvironment{pythonexec}{\immediate\write18{python3 "\jobname-script.py" > "\jobname-output.txt" 2>&1}\vspace{-1.5ex}\tcbinputlisting{enhanced, breakable, drop fuzzy shadow, listing file=\jobname-output.txt, listing only, listing engine=minted, minted language=text, minted options={fontsize=\small, breaklines}, colback=black!2, colframe=black!40, coltext=black!90, coltitle=black!80, colbacktitle=black!8, arc=2pt, boxrule=0.5pt, left=4mm, top=1mm, bottom=2mm, title={\textbf{\textbf{>\_}} \ Salida estándar (stdout)}, fonttitle=\small\bfseries, titlerule=0.5pt, titlerule style={black!20}}}

\newtcblisting{pythoncode}[1][]{enhanced, breakable, drop fuzzy shadow, listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small}, listing only, title={\textbf{\texttt{</>}\  Código Python}\ifx&#1&\else: #1\fi}, colback=white, colframe=MidnightBlue!60!black, coltitle=white, fonttitle=\small\bfseries, arc=2pt, boxrule=0.5pt, left=8mm, top=2mm, bottom=2mm, underlay={\begin{tcbclipinterior}\fill[MidnightBlue!3] (interior.south west) rectangle ([xshift=8mm]interior.north west);\draw[MidnightBlue!20] ([xshift=8mm]interior.south west) -- ([xshift=8mm]interior.north west);\end{tcbclipinterior}}}

\newcounter{condcounter}
\newenvironment{conditions} {%
    \setcounter{condcounter}{0}
    \[
    \left\{
    \begin{tabular}{@{}l@{\quad}l@{}} % <--- SOLUCIÓN: dos columnas 'l' separadas por un espacio
}{%
    \end{tabular}
    \right.
    \]
    \ignorespacesafterend
}
\newcommand{\conditem}{%
    \stepcounter{condcounter}%
    \textbf{\arabic{condcounter}.}~%
}

% =========================================================
% 8. MACROS MATEMÁTICAS (Y OPTIDEF TRADUCIDO)
% =========================================================
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

\newcommand{\diff}{\mathop{}\!\symup{d}}
\newcommand{\E}{\symup{e}}
\newcommand{\Imath}{\symup{i}}           
\newcommand{\N}{\symbb{N}}
\newcommand{\Z}{\symbb{Z}}
\newcommand{\Q}{\symbb{Q}}
\newcommand{\R}{\symbb{R}}
\newcommand{\C}{\symbb{C}}
\newcommand{\F}{\symbb{F}}
\newcommand{\K}{\symbb{K}}
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\absolute}{\lvert}{\rvert}
\newcommand{\A}{\mathcal{A}}
\providecommand{\ie}{\textit{i.e.}\,}
\providecommand{\tq}{\text{ t.q. }}
\newcommand{\syss}{\,si y solo si\,}
\DeclarePairedDelimiterX{\interno}[2]{\langle}{\rangle}{\mkern 2mu #1, #2 \mkern 2mu}
\providecommand{\Span}[1]{\operatorname{span}\, \left\langle #1 \right\rangle}
\providecommand{\mat}[1]{\mathbf{#1}}
\providecommand{\vect}[1]{\mathbf{#1}}
\providecommand{\glie}[1]{\mathfrak{gl}(#1)}
\providecommand{\evec}[2]{\text{Vec}_{#1}(#2)}

\DeclareMathOperator{\dir}{dir}
\DeclareMathOperator{\gph}{gph}
\DeclareMathOperator{\Tr}{Tr}
\DeclareMathOperator{\Ker}{Ker}
\DeclareMathOperator{\Codim}{Codim}
\DeclareMathOperator{\im}{Im}
\DeclareMathOperator{\Set}{Set}
\DeclareMathOperator{\Cls}{\mathcal{C}}
\DeclareMathOperator{\End}{End}
\DeclareMathOperator{\Hom}{Hom}
\DeclareMathOperator{\Id}{Id}
\DeclareMathOperator{\Nat}{Nat}
\DeclareMathOperator{\Supp}{Supp}
\DeclareMathOperator{\ctp}{Ctp.}
\DeclareMathOperator{\rk}{rk}
\DeclareMathOperator{\ann}{ann}
\DeclareMathOperator{\mcd}{mcd}
\DeclareMathOperator{\conv}{conv}
\DeclareMathOperator{\osc}{osc}
\DeclareMathOperator{\con}{con}
\DeclareMathOperator{\pos}{pos}
\DeclareMathOperator{\rint}{rint}
\DeclareMathOperator{\bdry}{bdry}
\DeclareMathOperator{\Der}{Der}
\DeclareMathOperator{\Tan}{Tan}
\DeclareMathOperator{\Dif}{Dif\,}
\DeclareMathOperator{\Gl}{GL}
\DeclareMathOperator{\Vect}{Vect}
\DeclareMathOperator{\Frac}{Frac}
\newcommand{\morf}[3]{\symcal{#1} (#2 , #3)}
\newcommand{\re}[1]{\symfrak{R} (#1)}
\renewcommand{\im}[1]{\symfrak{I} (#1)}
\DeclareMathOperator{\rel}{rel\,}
\DeclareMathOperator{\ind}{Ind}
\DeclareMathOperator{\sgn}{sgn}
\DeclareMathOperator{\co}{co}
\DeclareMathOperator{\core}{core}
\DeclareMathOperator{\lin}{lin}
\DeclareMathOperator{\ri}{ri}
\DeclareMathOperator{\aff}{aff}
\DeclareMathOperator{\val}{val}
\DeclareMathOperator{\Proj}{Proj}
\DeclareMathOperator{\Sym}{Sym}
\DeclareMathOperator{\Spec}{Spec}
\DeclareMathOperator{\Coker}{Coker}
\DeclareMathOperator{\Coim}{Coim}
\DeclareMathOperator{\Image}{Im}
\DeclareMathOperator{\Ext}{Ext}
\DeclareMathOperator{\Tor}{Tor}
\DeclareMathOperator{\Aut}{Aut}
\DeclareMathOperator{\Rad}{Rad}
\DeclareMathOperator{\nil}{nil}

\DeclareMathOperator{\ETop}{\operatorname{Top}}
\DeclareMathOperator{\Ev}{\operatorname{Vect}}
\DeclareMathOperator{\Evn}{\operatorname{Norm}}
\DeclareMathOperator{\EBan}{\operatorname{Ban}}
\DeclareMathOperator{\EHil}{\operatorname{Hilb}}
\DeclareMathOperator{\Rng}{\operatorname{Rng}}
\DeclareMathOperator{\Grp}{\operatorname{Grp}}
\DeclareMathOperator{\Mod}{\operatorname{Mod}}
\DeclareMathOperator{\HTop}{\operatorname{hTop}}
\DeclareMathOperator{\MCom}{\operatorname{Met}_{\operatorname{Completo}}}
\DeclareMathOperator{\Posets}{\operatorname{Posets}}
\DeclareMathOperator{\interior}{\operatorname{int}}
\DeclareMathOperator{\alt}{\operatorname{Alt}
} \renewcommand{\Rn}{\symbb{R}^n}

\newcommand{\Evf}{\Ev(F)}
\newcommand{\Evc}{\Ev(\C)}
\newcommand{\Evr}{\Ev(\R)}
\newcommand{\RMod}{\Mod(R)}

\DeclareMathOperator{\CTop}{\mathcal{C}_{\operatorname{Top}}}
\DeclareMathOperator{\CEv}{\mathcal{C}_{\operatorname{Vect}}}
\DeclareMathOperator{\CEBan}{\mathcal{C}_{\operatorname{Ban}}}
\DeclareMathOperator{\CEHil}{\mathcal{C}_{\operatorname{Hilb}}}
\DeclareMathOperator{\CEvn}{\mathcal{C}_{\operatorname{Norm}}}
\DeclareMathOperator{\CRng}{\mathcal{C}_{\operatorname{Rng}}}
\DeclareMathOperator{\CGrp}{\mathcal{C}_{\operatorname{Grp}}}
\DeclareMathOperator{\CMod}{\mathcal{C}_{\operatorname{Mod}}}
\newcommand{\CEvf}{\mathcal{C}_{\Ev(F)}}
\newcommand{\CEvc}{\mathcal{C}_{\C-\Ev}}
\newcommand{\CEvr}{\mathcal{C}_{\R-\Ev}}

\DeclareMathOperator*{\argmin}{argmin}
\DeclareMathOperator*{\argmax}{argmax}
\DeclareMathOperator{\dom}{dom}
\DeclareMathOperator{\rank}{rk}
\DeclareMathOperator{\epi}{epi}
\DeclareMathOperator{\lev}{lev}
\DeclareMathOperator{\cl}{cl}
\DeclareMathOperator{\dist}{dist}
\newcommand{\episum}{\mathbin{\#}}
\newcommand{\epimult}{\star}
\DeclareMathOperator{\rge}{rge}

\DeclareMathOperator{\cond}{cond}
\DeclareMathOperator{\diag}{diag}
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
\providecommand{\Span}[1]{\operatorname{span}\, \left\langle #1 \right\ranglie}

\newcommand{\ent}{\Rightarrow\quad &}

\newcommand{\chart}[2]{\left(#1, #2\right)}
\newcommand{\chartcoords}[2]{\left(#1, \left(#2^1, \dots, #2^n\right)\right)}
\newcommand{\rest}[2]{{#1|}_{#2}}
\newcommand{\transmap}[2]{#2 \circ #1^{-1}}

\newcommand{\map}[6]{%
    % Añadimos una 5ta columna 'l' (left) sin separación extra @{}
    \begin{array}{@{} r @{\,} c @{\;} c @{\;} c @{} l @{}}
      #1 \colon & \displaystyle #2 & \longrightarrow & \displaystyle #3 & \\
      \ifstrempty{#4}{}{%
        % El {} antes de #6 asegura el espaciado correcto si empieza con "="
        & \displaystyle #4 & \longmapsto & \displaystyle #5 & \displaystyle {}#6
      }%
    \end{array}
}

\newcommand{\inmap}[3]{#1 : #2 \longrightarrow #3}
\newcommand{\mapchain}[7]{#1 \xrightarrow{#5} #2 \xrightarrow{#6} #3 \xrightarrow{#7} #4}

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
% 9. DISEÑO DE PORTADAS (DUAL: ARTÍCULO Y LIBRO)
% =========================================================
\if@isarticle
  % ---------------------------------------------------------
  % 9A. ENCABEZADO TÉCNICO PREMIUM (MODO ARTÍCULO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \thispagestyle{plain}
    
    % Línea superior sutil
    \vspace*{-4em}
    \noindent\textcolor{MidnightBlue!30}{\rule{\textwidth}{1pt}}\par\vspace{1.5ex}
    
    % --- Bloque 1: Logo (Izquierda) y Contexto (Derecha) ---
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
      
    \par\vspace{3ex}
    
    % --- Bloque 2: Título y Autor (Caja de Contraste) ---
    \begin{tcolorbox}[
      enhanced,
      breakable,
      colback=MidnightBlue!2, % Fondo azul muy pálido
      colframe=MidnightBlue!2,
      borderline west={3pt}{0pt}{MidnightBlue}, % Línea lateral elegante
      boxrule=0pt,
      arc=3pt,
      left=12pt,
      top=8pt,
      bottom=8pt
    ]
      \begin{flushleft}
        \ifx\@title\@empty\else
          {\LARGE \bfseries \textcolor{black!40!MidnightBlue}{\@title}\par}\vspace{1.5ex}
        \fi
        \ifx\shorttitle\@empty\else
          {\large \bfseries \textcolor{MidnightBlue!60!black}{\shorttitle}\par}\vspace{1.5ex}
        \fi
        \ifx\@author\@empty\else
          {\large \bfseries \textcolor{black}{\@author}}\\[0.5ex]
        \fi
        \ifx\@email\@empty\else
          {\sffamily\small\textcolor{MidnightBlue}{\@email}}
        \fi
      \end{flushleft}
    \end{tcolorbox}
    
    \vspace{2ex}
    
    % --- Bloque 3: Metadatos y Referencias (A 2 Columnas) ---
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
    
    \par\vspace{3ex}
    % --- Línea inferior sólida ---
    \noindent\textcolor{MidnightBlue}{\rule{\textwidth}{1.5pt}}
    \par\vspace{3em}
  }\else
  % ---------------------------------------------------------
  % 9B. PORTADA PREMIUM A PÁGINA COMPLETA (MODO LIBRO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \begin{titlepage}
      \thispagestyle{empty} 
      
      % Bloque Superior: Logo (Izquierda) y Contexto (Derecha)
      \vspace*{1cm}
      \noindent
      \begin{minipage}[t]{0.3\textwidth}
        \vspace{0pt}
        \ifx\@logo\@empty\else
          \includegraphics[width=0.8\linewidth]{\@logo}
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
      
      \vspace{3.5cm}
      
      % Bloque Central: Título con Barra Lateral
      \begin{tcolorbox}[
        blanker, borderline west={4pt}{0pt}{MidnightBlue!80!black}, 
        left=15pt, top=5pt, bottom=5pt
      ]
        \ifx\@title\@empty\else
          {\Huge \bfseries \textcolor{MidnightBlue!90!black}{\@title}}\\[2ex]
        \fi
        \ifx\shorttitle\@empty\else
          {\LARGE \textit{\textcolor{MidnightBlue!60}{\shorttitle}}}
        \fi
      \end{tcolorbox}
      
      \vfill
      
      % Bloque Inferior: Referencias (Izq) y Autoría/Metadatos (Der)
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
            {\Large \bfseries \@author}\\[0.5ex]
          \fi
          \ifx\@email\@empty\else
            {\small \sffamily \textcolor{MidnightBlue!70}{\@email}}\\[1.5ex]
          \fi
          \ifx\@profesor\@empty\else
            {\large \color{gray}Profesor: \@profesor}\\[0.5ex]
          \fi
          \ifx\@asistente\@empty\else
            {\normalsize \color{gray}Jefe de Prácticas: \@asistente}\\[1ex]
          \fi
          \vspace{1.5cm}
          \ifx\@lugar\@empty\else
            {\large \sffamily \color{gray}\@lugar}\\[0.5ex]
          \fi
          {\large \sffamily \color{gray}\@date}\\[0.5ex]
          \ifx\@version\@empty\else
            {\small \sffamily \color{gray}Versión \@version}
          \fi
        \end{flushright}
      \end{minipage}
      
      \vspace*{2cm}
    \end{titlepage}
    \cleardoublepage
  }
\fi

\AtBeginDocument{
  \setlength{\abovedisplayskip}{1.2ex plus 0.3ex minus 0.1ex}
  \setlength{\belowdisplayskip}{1.2ex plus 0.3ex minus 0.1ex}
  \hypersetup{pdftitle={\shorttitle}, pdfauthor={\shortauthor}, pdfsubject={\@curso}}
}

% =========================================================
% COMANDOS PERSONALIZADOS PARA SECCIONES NO NUMERADAS EN TOC
% =========================================================
\newcommand{\addsubsec}[1]{%
  \phantomsection% Asegura que el hipervínculo apunte al lugar correcto
  \subsection*{#1}% Crea la subsección sin número
  \addcontentsline{toc}{subsection}{#1}% La añade a la tabla de contenidos
}

\newcommand{\addsubsubsec}[1]{%
  \phantomsection
  \subsubsection*{#1}
  \addcontentsline{toc}{subsubsection}{#1}
}

\endinput
