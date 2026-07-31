%% tesis-uni.cls
%% Clase para Proyectos de Tesis y Tesis - UNI
%% Optimizada para LuaLaTeX y KOMA-Script (scrbook)
%% --------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tesis-uni}[2026/01/20 v3.5 Clase para Tesis UNI - LuaLaTeX (KOMA-Script Avanzado)]

% --- Heredar de la clase scrbook (KOMA-Script para libros) ---
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrbook}}
\ProcessOptions\relax
% twoside, openright: Doble cara, capítulos inician en página impar.
\LoadClass[a4paper,fontsize=11pt,twoside,openright,usegeometry]{scrbook}

% =========================================================
% 1. PAQUETES ESENCIALES (Orden Crítico)
% =========================================================
\RequirePackage[dvipsnames]{xcolor} % Cargar xcolor ANTES de tikz
\RequirePackage{mathtools}
\RequirePackage{amssymb}
\RequirePackage{fontspec}
\RequirePackage{unicode-math} % Reemplaza amssymb en LuaLaTeX

% Definición vectorial robusta del cuadrado negro QED
\providecommand{\blacksquare}{\mbox{\rule{1.2ex}{1.2ex}}}
\providecommand{\blackSquare}{\blacksquare}

% --- Motores de Gráficos ---
\RequirePackage{luamplib}
\mplibforcehmode
\RequirePackage{tikz}
\usetikzlibrary{cd, graphs, graphdrawing, arrows.meta, calc, positioning, shapes.geometric, intersections, decorations.pathmorphing, svg.path}
\usegdlibrary{trees, layered, force}
\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}

% --- Ícono ORCID ---
\definecolor{orcidlogocol}{HTML}{A6CE39}
\newcommand{\OrigHeight}{0.00390625}
\newlength{\Xheight}\setlength{\Xheight}{\fontcharht\font`X}
\newcommand{\orcidlogo}{%
\begin{tikzpicture}[yscale=-\OrigHeight*\Xheight,xscale=\OrigHeight*\Xheight,transform shape]
\fill[orcidlogocol] svg{M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z};
\fill[white] svg{M86.3,186.2H70.9V79.1h15.4v48.4V186.2z}svg{M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z} svg{M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z};
\end{tikzpicture}}

% --- Utilidades y Tablas ---
\RequirePackage{graphicx}
\RequirePackage{import}       
\RequirePackage{transparent}  
\RequirePackage{float}
\RequirePackage{booktabs}
\RequirePackage{tabularray}
\RequirePackage{varwidth}
\RequirePackage{multicol}
\RequirePackage[spanish]{datetime2}
\RequirePackage{verbatim}     
\RequirePackage{siunitx}      
\RequirePackage{tasks}        
\settasks{ label=(\alph*), label-width=18pt, item-indent=25pt }

% --- Índice Alfabético ---
\RequirePackage{imakeidx}
\makeindex[intoc, title=Índice Alfabético]

% --- Geometría, Idioma y Márgenes ---
\RequirePackage[inner=3.00cm,outer=2.50cm,top=2.50cm,bottom=2.50cm,headheight=20pt,footskip=30pt]{geometry}
\setlength{\footheight}{20pt} % Evita advertencia de scrlayer-scrpage

\RequirePackage[spanish,es-nodecimaldot,es-sloppy]{babel}
\RequirePackage{ragged2e}
\addto\captionsspanish{%
  \renewcommand{\tablename}{Tabla}%
  \renewcommand{\listtablename}{Índice de Tablas}%
}

% =========================================================
% 2. DISEÑO NATIVO KOMA-SCRIPT (Títulos, TOC y Captions)
% =========================================================

\definecolor{ColorTema}{HTML}{1A365D} % Azul oscuro elegante

% --- Diseño de Capítulos ---
\KOMAoptions{chapterprefix=false}
\setkomafont{chapter}{\Huge\bfseries}

\renewcommand*{\chapterformat}{%
  \fontsize{70}{70}\selectfont\color{black!15}\thechapter
}
\renewcommand*{\chapterlinesformat}[3]{%
  \Ifstr{#2}{}{%
    \raggedright #3
  }{%
    \parbox[b]{0.20\textwidth}{\raggedleft #2}%
    \hspace{0.04\textwidth}%
    \parbox[b]{0.75\textwidth}{\raggedright #3}%
  }
}
\RedeclareSectionCommand[beforeskip=-20pt, afterskip=3pc]{chapter}

% --- Estilo de Secciones y Subsecciones ---
\setkomafont{section}{\Large\bfseries\color{ColorTema}}
\setkomafont{subsection}{\large\bfseries\itshape}
\setkomafont{subsubsection}{\normalsize\bfseries}

\RedeclareSectionCommand[beforeskip=-12pt, afterskip=6pt]{section}
\RedeclareSectionCommand[beforeskip=-10pt, afterskip=4pt]{subsection}

% --- Diseño del Índice de Contenidos (TOC) ---
\KOMAoptions{toc=chapterentrydotfill}

\DeclareTOCStyleEntry[beforeskip=0.4cm]{chapter}{chapter}
\setkomafont{chapterentry}{\bfseries\color{ColorTema}} 
\setkomafont{chapterentrypagenumber}{\bfseries\color{ColorTema}}

\DeclareTOCStyleEntry[beforeskip=0.1cm]{section}{section}

% --- Leyendas (Captions) ---
\setkomafont{caption}{\small}
\setkomafont{captionlabel}{\small\bfseries\color{ColorTema}}
\renewcommand*{\captionformat}{.\enskip}

% --- Encabezados y Pies de Página (scrlayer-scrpage) ---
\RequirePackage[automark, headsepline]{scrlayer-scrpage}
\pagestyle{scrheadings}
\clearpairofpagestyles 
\lehead{\leftmark}  % Izquierda (Página Par): Capítulo
\rohead{\rightmark} % Derecha (Página Impar): Sección
\cfoot[\pagemark]{\pagemark} 
\setkomafont{pageheadfoot}{\normalfont\small\itshape}
\setkomafont{pagenumber}{\normalfont\upshape}

% =========================================================
% 3. CAJAS, CÓDIGO E INTERLINEADO
% =========================================================
\RequirePackage{tcolorbox}
\tcbuselibrary{listings, breakable, skins, minted}
\RequirePackage{csquotes}     
\RequirePackage{algorithm}
\RequirePackage{algpseudocode}
\RequirePackage{microtype} 
\RequirePackage{setspace}

% Interlineado profesional de matemática (1.25)
\setstretch{1.25} 

% Acotar espacios arriba y abajo de ecuaciones despejadas
\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt plus 2pt minus 1pt}
  \setlength{\belowdisplayskip}{4pt plus 2pt minus 1pt}
  \setlength{\abovedisplayshortskip}{2pt plus 1pt}
  \setlength{\belowdisplayshortskip}{2pt plus 1pt}
}

\tolerance=1000           
\emergencystretch=3em     
\hyphenpenalty=500        
\hfuzz=0.5pt              

% =========================================================
% 4. FUENTES TIPOGRÁFICAS
% =========================================================
\setmainfont{TeX Gyre Pagella}[Ligatures=TeX]
\setmathfont{TeX Gyre Pagella Math}
\setsansfont{TeX Gyre Heros}[Scale=MatchLowercase]
\setmonofont{TeX Gyre Cursor}[Scale=MatchLowercase] % Fuente monoespaciada estándar garantizada

% =========================================================
% 5. COMANDOS EDITORIALES VISUALES Y CAJAS
% =========================================================
\definecolor{emacstodo}{HTML}{FF9900} \definecolor{emacsfixme}{HTML}{FF0000}    
\definecolor{emacsdebug}{HTML}{A020F0} \definecolor{emacsnote}{HTML}{00CCFF}     

\newcommand{\TODO}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacstodo!15}{\textcolor{emacstodo}{\sffamily\textbf{\scriptsize TODO}}}\ \textcolor{emacstodo!70!black}{\small #1}\endgroup}
\newcommand{\FIXME}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsfixme!15}{\textcolor{emacsfixme}{\sffamily\textbf{\scriptsize FIXME}}}\ \textcolor{emacsfixme!85!black}{\small\textbf{#1}}\endgroup}
\newcommand{\DEBUG}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsdebug!15}{\textcolor{emacsdebug}{\sffamily\textbf{\scriptsize DEBUG}}}\ \textcolor{emacsdebug!70!black}{\small #1}\endgroup}
\newcommand{\NOTE}[1]{\begingroup\setlength{\fboxsep}{2pt}\colorbox{emacsnote!15}{\textcolor{emacsnote}{\sffamily\textbf{\scriptsize NOTE}}}\ \textcolor{emacsnote!70!black}{\small #1}\endgroup}

\newtcbox{\highlightpink}{on line, arc=2pt, colback=pink!40, colframe=pink!40, boxrule=0pt, boxsep=0pt, left=3pt, right=3pt, top=2pt, bottom=2pt}
\newtcbox{\highlightyellow}{on line, arc=2pt, colback=yellow!40, colframe=yellow!40, boxrule=0pt, boxsep=0pt, left=3pt, right=3pt, top=2pt, bottom=2pt}
\newtcbox{\highlightgreen}{on line, arc=2pt, colback=ForestGreen!20, colframe=ForestGreen!20, boxrule=0pt, boxsep=0pt, left=3pt, right=3pt, top=2pt, bottom=2pt}
\newcommand{\deftech}[1]{\highlightpink{#1}} \newcommand{\usual}[1]{\highlightyellow{#1}}  

\newtcolorbox{notabox}[1][]{
    enhanced, breakable, arc=2pt, boxrule=0.5pt,
    colback=blue!5, colframe=blue!40!black,
    title={\textbf{Nota}\ifx&#1&\else: #1\fi},
    left=4mm, right=4mm, top=2mm, bottom=2mm,
    drop fuzzy shadow
}
\newtcolorbox{warningbox}[1][]{
    blanker, breakable, left=4mm, top=1mm, bottom=1mm, before skip=2ex, after skip=2ex,
    borderline west={1.5pt}{0pt}{black!60}, fonttitle=\bfseries, coltitle=black,
    title={\textbf{Advertencia}\ifx&#1&\else: #1\fi}
}

\newtcblisting{pseudocodigo}[2][]{
  listing engine=minted, minted language=#2, minted options={linenos, breaklines, fontsize=\small},
  title={\textbf{#1}}, colback=white, colframe=MidnightBlue!80!black, sharp corners, boxrule=0.5pt, left=2mm, top=2mm, bottom=2mm, breakable
}

\definecolor{incolor}{HTML}{303F9F}
\definecolor{cellbackground}{HTML}{F7F7F7}
\newtcblisting{pythoncode}[1][]{
  listing engine=minted, minted language=python, minted options={linenos, breaklines, fontsize=\small},
  title={\textbf{Código Python} \ifx&#1&\else - #1\fi}, colback=cellbackground, colframe=incolor, sharp corners, boxrule=0.5pt, left=2mm, top=2mm, bottom=2mm, breakable
}

% =========================================================
% 6. VARIABLES Y ENTORNO DE PORTADA (UNI)
% =========================================================
\def\@codigo{}        \newcommand{\codigo}[1]{\def\@codigo{#1}}
\def\@asesor{}        \newcommand{\asesor}[1]{\def\@asesor{#1}}
\def\@orcidautor{}    \newcommand{\orcidautor}[1]{\def\@orcidautor{#1}}
\def\@orcidasesor{}   \newcommand{\orcidasesor}[1]{\def\@orcidasesor{#1}}
\def\@curso{}         \newcommand{\curso}[1]{\def\@curso{#1}}
\def\@profesor{}      \newcommand{\profesor}[1]{\def\@profesor{#1}}
\def\@facultad{}      \newcommand{\facultad}[1]{\def\@facultad{#1}}
\def\@tipodocumento{MONOGRAFÍA DE PRÁCTICA PRE-PROFESIONAL}
\newcommand{\tipodocumento}[1]{\def\@tipodocumento{#1}}

% --- GENERAR LA PORTADA AUTOMÁTICA UNI ---
\newcommand{\makeportada}{
    \begin{titlepage}
    \begin{center}
        \begin{Large}
        \textsc{UNIVERSIDAD NACIONAL DE INGENIERÍA}\\
        \textsc{FACULTAD DE CIENCIAS}\\
        \textsc{ESCUELA PROFESIONAL DE MATEMÁTICA}\par
        \end{Large}
        
        \vfill
        \vfill
        
        \includegraphics[width=0.40\textwidth, height=4.5cm, keepaspectratio]{imagenes/uni.png} 
        
        \vfill 
        
        \begin{large}
        {\Large \bfseries \textsc{\@title} \par}
        
        \vfill 
        
        \textsc{\@tipodocumento}\par
        
        \vfill 
        
        \textsc{ELABORADO POR:}\\[0.2cm]
        \textbf{\@author}\\[0.15cm]
        \ifx\@orcidautor\empty\else \orcidlogo\ \href{https://orcid.org/\@orcidautor}{\@orcidautor}\\[0.15cm] \fi
        \ifx\@codigo\empty\else \textbf{Código: \@codigo} \fi\par
        
        \vfill 
        
        \ifx\@asesor\empty\else 
            \textsc{ASESOR:}\\[0.2cm] 
            \textbf{\@asesor}\\[0.15cm] 
            \ifx\@orcidasesor\empty\else \orcidlogo\ \href{https://orcid.org/\@orcidasesor}{\@orcidasesor} \fi\par
        \fi
        
        \vfill 
        \vfill 
        
        \begin{minipage}{\textwidth}
            \centering
            \textbf{Lima - Perú}\\[0.15cm]
            \textbf{\@date}
        \end{minipage}
        
        \end{large}
    \end{center}
    \end{titlepage}
    \cleardoublepage
}

% --- CÓMO CITAR ---
\newcommand{\makecitacion}{
    \thispagestyle{empty}
    \vspace*{\fill}
    \noindent\rule{\textwidth}{0.4pt}\\[0.3cm]
    \textbf{Forma sugerida de citar este trabajo (Estilo APA 7ma ed.):}\\
    \@author\ (\@date). \textit{\@title}. [\@tipodocumento, Universidad Nacional de Ingeniería]. Repositorio Institucional Cybertesis UNI.\\[0.1cm]
    \noindent\rule{\textwidth}{0.4pt}
    \vspace{2cm}
    \cleardoublepage
}

\newenvironment{dedicatoria}{
    \cleardoublepage
    \thispagestyle{empty}
    \vspace*{0.2\textheight}
    \begin{flushright}\itshape
}{
    \end{flushright}
}

\newenvironment{agradecimientos}{
    \cleardoublepage
    \thispagestyle{empty}
    \vspace*{0.1\textheight}
    \begin{center}\Large\textbf{AGRADECIMIENTO}\end{center}\vspace{1cm}
    \begin{flushleft}
}{
    \end{flushleft}
}

% --- ENTORNOS PARA RESUMEN Y ABSTRACT ---
\makeatletter
\newenvironment{resumen}[1][]{%
  \def\@resumenkw{#1}%
  \cleardoublepage
  \thispagestyle{plain}
  \begin{center}
    {\Large\bfseries\color{ColorTema} RESUMEN}
  \end{center}
  \vspace{0.5cm}
  \par
}{%
  \ifx\@resumenkw\empty\else
    \vspace{1cm}
    \noindent\textbf{Palabras clave:} \@resumenkw.
  \fi
}

\newenvironment{abstracting}[1][]{%
  \def\@abstractkw{#1}%
  \cleardoublepage
  \thispagestyle{plain}
  \begin{center}
    {\Large\bfseries\color{ColorTema} ABSTRACT}
  \end{center}
  \vspace{0.5cm}
  \par
}{%
  \ifx\@abstractkw\empty\else
    \vspace{1cm}
    \noindent\textbf{Keywords:} \@abstractkw.
  \fi
}
\makeatother

% =========================================================
% 7. TEOREMAS Y HERRAMIENTAS DE DEMOSTRACIÓN
% =========================================================
\RequirePackage{amsthm}
\RequirePackage{mleftright}
\mleftright

\renewcommand{\qedsymbol}{\blacksquare}
\addto\captionsspanish{\renewcommand{\proofname}{\textbf{\textit{Prueba}}}}

\makeatletter
\renewenvironment{proof}[1][\proofname]{\par
  \setcounter{claimcount}{0}% <--- INYECCIÓN: Resetea las afirmaciones en cada prueba
  \pushQED{\qed}%
  \normalfont \small 
  \trivlist          
  \item[] \textbf{\textit{#1\@addpunct{.}}}\hspace{0.5em}\ignorespaces
}{%
  \popQED\endtrivlist\@endpefalse
}
\makeatother

\tcolorboxenvironment{proof}{
    blanker,
    breakable,
    left=8mm,          
    right=8mm,         
    top=0pt,
    bottom=0pt,
    before skip=2.5ex plus 0.5ex minus 0.2ex,
    after skip=2.5ex plus 0.5ex minus 0.2ex,
    borderline west={1.5pt}{0pt}{black!30}  
}

% --- Estructuras para Listas Compactas ---
\RequirePackage[shortlabels]{enumitem}

\setlist[enumerate]{
    topsep=2pt plus 1pt minus 1pt,
    parsep=0pt,
    partopsep=0pt,
    itemsep=2pt plus 1pt,
    leftmargin=10mm,
    label=\normalfont\arabic*.
}

\setlist[itemize]{
    topsep=2pt plus 1pt minus 1pt,
    parsep=0pt,
    partopsep=0pt,
    itemsep=2pt plus 1pt,
    leftmargin=10mm
}

\newlist{enuthm}{enumerate}{1}
\setlist[enuthm,1]{
    label=\normalfont\arabic*.,
    leftmargin=10mm,
    topsep=0.2ex,
    partopsep=0pt,
    parsep=0pt,
    itemsep=0.2ex,
    before=\leavevmode
}

% 1. Doble Implicancia
\newcommand{\directstep}{\par\smallskip\noindent\textbf{(\(\Rightarrow\))}\ \ignorespaces}
\newcommand{\reversestep}{\par\smallskip\noindent\textbf{(\(\Leftarrow\))}\ \ignorespaces}

% 2. Casos y Subcasos
\newlist{proofcases}{enumerate}{2}
\setlist[proofcases,1]{
    label=\textbf{Caso \arabic*:},
    leftmargin=2.5em,           % Fija el margen absoluto para evitar el colapso en trivlist
    align=left,                 % Alinea la etiqueta a la izquierda del margen
    labelwidth=*,               % Permite que la etiqueta respire sin empujar el texto
    labelindent=0pt,
    listparindent=\parindent,
    itemsep=0.3em,
    topsep=0.3em,
    parsep=0pt
}
\setlist[proofcases,2]{
    label=\textbf{Subcaso \arabic{proofcasesi}.\arabic*:},
    leftmargin=2.5em,
    align=left,
    labelwidth=*,
    labelindent=0pt,
    itemsep=0.2em
}

% 3. Afirmaciones e Inferencia Intermedia (Claims)
\newcounter{claimcount}
\newenvironment{claim}[1][]{%
  \refstepcounter{claimcount}%
  \par\smallskip\noindent\textbf{Afirmación \arabic{claimcount}\ifx&#1&\else\ (#1)\fi:}\ \itshape
}{\par\smallskip}

\newenvironment{claimproof}{%
  \par\noindent\textit{Prueba de la afirmación.}\ \small
}{%
  \hfill$\square $\par\smallskip
}

% Variante no numerada de la afirmación
\newenvironment{claim*}[1][]{%
  \par\smallskip\noindent\textbf{Afirmación\ifx&#1&\else\ (#1)\fi:}\ \itshape
}{\par\smallskip}


% 4. Inducción y Contradicción
\newcommand{\basecase}{\par\smallskip\noindent\textbf{Base inductiva:}\ \ignorespaces}
\newcommand{\inductionhyp}{\par\smallskip\noindent\textbf{Hipótesis inductiva:}\ \ignorespaces}
\newcommand{\inductionstep}{\par\smallskip\noindent\textbf{Paso inductivo:}\ \ignorespaces}
\newcommand{\bycontradiction}{\par\smallskip\noindent\textbf{Por contradicción:}\ Supongamos lo contrario, es decir, que\ }

\newenvironment{conditions} {%
	\[
		\left\{
		\begin{varwidth}{\linewidth}
			\rule{0pt}{3pt}
			\begin{enumerate}[label=\textbf{\arabic*.}, leftmargin=20pt, labelsep=0.5em, itemsep=5mm, topsep=0pt, partopsep=0pt, parsep=0pt]
				} {%
			\end{enumerate}
			\rule[0pt]{0pt}{0pt}
		\end{varwidth}
		\right.
	\]
}

% =========================================================
% 8. MACROS MATEMÁTICAS COMPLETAS
% =========================================================
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
\newcommand{\Cn}{\symbb{C}^{n}}
\newcommand{\PP}{\symbb{P}} 
\newcommand{\Lr}{\mathcal{L}}
\newcommand{\A}{\mathcal{A}}
\providecommand{\ie}{\textit{i.e.}\,}
\providecommand{\tq}{\text{ t.q. }}
\newcommand{\syss}{\,si y solo si\,}

\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\absolute}{\lvert}{\rvert}
\DeclarePairedDelimiter{\inner}{\langle}{\rangle}

\providecommand{\mat}[1]{\mathbf{#1}}
\providecommand{\vect}[1]{\mathbf{#1}}
\providecommand{\glie}[1]{\mathfrak{gl}(#1)}
\providecommand{\evec}[2]{\text{Vec}_{#1}(#2)}

\DeclareMathOperator{\sen}{sen}
\DeclareMathOperator{\arcsen}{arcsen}
\DeclareMathOperator{\Dom}{Dom}
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
\DeclareMathOperator{\Span}{Span}
\newcommand{\morf}[3]{\mathcal{#1} (#2 , #3)}
\DeclareMathOperator{\rel}{rel\,}
\DeclareMathOperator{\ind}{Ind}
\DeclareMathOperator{\Proj}{Proj}
\DeclareMathOperator{\Sym}{Sym}
\DeclareMathOperator{\SL}{SL}
\DeclareMathOperator{\Frac}{Frac}
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

% =========================================================
% 9. BIBLIOGRAFÍA, HIPERVÍNCULOS Y REFERENCIAS
% =========================================================
\RequirePackage[backend=biber, style=alphabetic, sorting=none, backref=true]{biblatex}
\RequirePackage[
    colorlinks=true, 
    linkcolor=ColorTema, 
    citecolor=ColorTema, 
    urlcolor=ColorTema,
    plainpages=false,      % Evita duplicidad de anclas en hipervínculos (page.1)
    pdfpagelabels=true     % Sincroniza números de página en el lector PDF
]{hyperref}
\RequirePackage{bookmark} 
\RequirePackage[spanish,noabbrev]{cleveref} 

\hypersetup{
    pdfpagemode=UseOutlines,
    pdfdisplaydoctitle=true
}

% Inyección automática de metadatos al PDF
\AtBeginDocument{
  \hypersetup{
    pdftitle={\@title},
    pdfauthor={\@author}
  }
}

% =========================================================
% 10. TEOREMAS Y ENTORNOS (Estilo Compacto)
% =========================================================

\newtheoremstyle{compact-plain}%
  {5pt plus 2pt minus 1pt}% preskip
  {5pt plus 2pt minus 1pt}% postskip
  {\itshape}% bodyfont
  {}% indent
  {\bfseries}% headfont
  {.}% headpunct
  {5pt}% headspace
  {}% headspec

\newtheoremstyle{compact-def}%
  {5pt plus 2pt minus 1pt}% preskip
  {5pt plus 2pt minus 1pt}% postskip
  {\normalfont}% bodyfont
  {}% indent
  {\bfseries}% headfont
  {.}% headpunct
  {5pt}% headspace
  {}% headspec

\newtheoremstyle{compact-remark}%
  {5pt plus 2pt minus 1pt}% preskip
  {5pt plus 2pt minus 1pt}% postskip
  {\normalfont}% bodyfont
  {}% indent
  {\itshape}% headfont
  {.}% headpunct
  {5pt}% headspace
  {}% headspec

\theoremstyle{compact-plain}
\newtheorem{theorem}{Teorema}[chapter]
\newtheorem{proposition}[theorem]{Proposición}
\newtheorem{lemma}[theorem]{Lema}
\newtheorem{corollary}[theorem]{Corolario}

\theoremstyle{compact-def}
\newtheorem{definition}[theorem]{Definición}
\newtheorem{example}[theorem]{Ejemplo}
\newtheorem{exercise}[theorem]{Ejercicio}
\newtheorem{solution}[theorem]{Solución}

\theoremstyle{compact-remark}
\newtheorem*{remark}{Observación}
\newtheorem*{commentary}{Comentario}
\newtheorem*{notation}{Notación}
\newtheorem*{objective}{Objetivo}

\crefname{theorem}{Teorema}{Teoremas}
\crefname{proposition}{Proposición}{Proposiciones}
\crefname{lemma}{Lema}{Lemas}
\crefname{corollary}{Corolario}{Corolarios}
\crefname{definition}{Definición}{Definiciones}
\crefname{example}{Ejemplo}{Ejemplos}
\crefname{exercise}{Ejercicio}{Ejercicios}
\crefname{solution}{Solución}{Soluciones}


\endinput
