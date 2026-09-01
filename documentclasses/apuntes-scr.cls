%% apuntes-scr.cls
%% Clase Maestra para Apuntes Personales, Libros de Estudio y Artículos Académicos
%% Arquitectura Editorial: KOMA-Script + Estilo Bourbaki / IHÉS / EGA
%% Compilación exclusiva en LuaLaTeX - Versión 6.5 (Bourbaki Edition)
%% ------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{apuntes-scr}[2026/08/30 v6.5 Apuntes - LuaLaTeX Bourbaki/IHES Architecture]

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
% 1. LÓGICA DE OPCIONES (TIPO, ESTILO, IDIOMA, CITAS Y DRAFT)
% =========================================================
\RequirePackage{etoolbox}

\newif\if@isarticle      \@isarticlefalse 
\newif\if@estilobourbaki \@estilobourbakitrue  % Estilo Bourbaki activado por defecto
\newif\if@estiloihes     \@estiloihestrue      % Estilo IHÉS compatible
\newif\if@estiloega      \@estiloegatrue       % Estilo EGA (Grothendieck / IHÉS)
\newif\if@estilobonn     \@estilobonnfalse
\newif\if@langspanish    \@langspanishtrue     % Idioma español por defecto
\newif\if@langenglish    \@langenglishfalse
\newif\if@langfrench     \@langfrenchfalse
\newif\if@langgerman     \@langgermanfalse
\newif\if@fastmode       \@fastmodefalse
\newif\if@citaalphabetic  \@citaalphabetictrue  % Cita alphabetic por defecto
\newif\if@citaieee        \@citaieeefalse
\newif\if@citaapa         \@citaapafalse
\newif\if@citanumeric     \@citanumericfalse

% Opciones de tipo de documento
\DeclareOption{article}{\@isarticletrue}
\DeclareOption{book}{\@isarticlefalse}

% Opciones de estilo editorial
\DeclareOption{bourbaki}{\@estilobourbakitrue\@estiloihestrue\@estiloegatrue\@estilobonnfalse}
\DeclareOption{ihes}{\@estilobourbakitrue\@estiloihestrue\@estiloegatrue\@estilobonnfalse}
\DeclareOption{ega}{\@estiloegatrue\@estiloihestrue\@estilobourbakitrue\@estilobonnfalse}
\DeclareOption{bonn}{\@estilobonntrue\@estiloihesfalse\@estilobourbakifalse\@estiloegafalse}

% Opciones de idioma
\DeclareOption{spanish}{\@langspanishtrue\@langenglishfalse\@langfrenchfalse\@langgermanfalse}
\DeclareOption{english}{\@langenglishtrue\@langspanishfalse\@langfrenchfalse\@langgermanfalse}
\DeclareOption{french}{\@langfrenchtrue\@langspanishfalse\@langenglishfalse\@langgermanfalse}
\DeclareOption{german}{\@langgermantrue\@langspanishfalse\@langenglishfalse\@langfrenchfalse}

% Opciones de estilo bibliográfico
\DeclareOption{alphabetic}{\@citaalphabetictrue\@citaieeefalse\@citaapafalse\@citanumericfalse}
\DeclareOption{ieee}{\@citaieeetrue\@citaalphabeticfalse\@citaapafalse\@citanumericfalse}
\DeclareOption{apa}{\@citaapatrue\@citaalphabeticfalse\@citaieeefalse\@citanumericfalse}
\DeclareOption{numeric}{\@citanumerictrue\@citaalphabeticfalse\@citaieeefalse\@citaapafalse}

% Modo Rápido / Borrador (Acelera la compilación)
\DeclareOption{fast}{\@fastmodetrue}

% Pasar cualquier otra opción a la clase base KOMA-Script
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\if@isarticle scrartcl\else scrbook\fi}}

% Tipografía base por defecto (10pt para proporciones canónicas Bourbaki / IHÉS)
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
\DeclareOldFontCommands

\KOMAoptions{usegeometry=true}
\setcounter{tocdepth}{2}

% =========================================================
% 2. GEOMETRÍA Y MÁRGENES (Métricas Reales Bourbaki / IHÉS / KOMA)
% =========================================================
\RequirePackage{geometry}
\if@isarticle
  \if@estiloihes
    \geometry{
      a4paper,
      twoside,
      textwidth=14.2cm,
      textheight=22.5cm,
      heightrounded,
      inner=2.8cm,
      top=2.8cm,
      marginparwidth=2.4cm,
      marginparsep=0.4cm,
      headheight=18pt,
      footskip=28pt
    }
  \else
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
  \fi
\else
  \if@estiloihes
    % Métrica exacta Bourbaki / IHÉS: Bloque clásico de 14.0cm x 22.0cm con margen exterior generoso para tournants dangereux
    \geometry{
      a4paper,
      twoside,
      textwidth=14.0cm,
      textheight=22.0cm,
      heightrounded,
      inner=3.2cm,
      top=3.0cm,
      marginparwidth=2.5cm,
      marginparsep=0.4cm,
      headheight=18pt,
      footskip=30pt
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
\fi
\setlength{\footheight}{20pt}
\setlength{\parindent}{1.5em}
\setlength{\parskip}{0pt plus 1pt}

% =========================================================
% 3. DICCIONARIO Y TRADUCCIONES AUTOMÁTICAS
% =========================================================
\newcommand{\indexnamecustom}{Índice Alfabético}
\newcommand{\thmnamecustom}{Teorema}
\newcommand{\propnamecustom}{Proposición}
\newcommand{\lemmanamecustom}{Lema}
\newcommand{\cornamecustom}{Corolario}
\newcommand{\defnamecustom}{Definición}
\newcommand{\exnamecustom}{Ejemplo}
\newcommand{\exernamecustom}{Ejercicio}
\newcommand{\exercicesnamecustom}{Ejercicios}
\newcommand{\notehistnamecustom}{Nota Histórica}
\newcommand{\livrenamecustom}{Libro}
\newcommand{\solnamecustom}{Solución}
\newcommand{\cexnamecustom}{Contraejemplo}
\newcommand{\algnamecustom}{Algoritmo}
\newcommand{\obsnamecustom}{Observación}
\newcommand{\comnamecustom}{Comentario}
\newcommand{\casenamecustom}{Caso}
\newcommand{\condnamecustom}{Condición}
\newcommand{\claimnamecustom}{Afirmación}
\newcommand{\proofclaimnamecustom}{Prueba de la afirmación.}
\newcommand{\basecasenamecustom}{Caso Base}
\newcommand{\indstepnamecustom}{Paso Inductivo}
\newcommand{\indhypnamecustom}{Hipótesis de Inducción (H.I.)}
\newcommand{\noteboxnamecustom}{Nota}
\newcommand{\warnboxnamecustom}{Atención}
\newcommand{\ctrlboxnamecustom}{Pregunta de Control}
\newcommand{\coverrefname}{Referencias Principales}
\newcommand{\summaryname}{SUMARIO}

\if@langenglish
  \RequirePackage[english]{babel}
  \renewcommand{\indexnamecustom}{Alphabetical Index}
  \renewcommand{\thmnamecustom}{Theorem}
  \renewcommand{\propnamecustom}{Proposition}
  \renewcommand{\lemmanamecustom}{Lemma}
  \renewcommand{\cornamecustom}{Corollary}
  \renewcommand{\defnamecustom}{Definition}
  \renewcommand{\exnamecustom}{Example}
  \renewcommand{\exernamecustom}{Exercise}
  \renewcommand{\exercicesnamecustom}{Exercises}
  \renewcommand{\notehistnamecustom}{Historical Note}
  \renewcommand{\livrenamecustom}{Book}
  \renewcommand{\solnamecustom}{Solution}
  \renewcommand{\cexnamecustom}{Counterexample}
  \renewcommand{\algnamecustom}{Algorithm}
  \renewcommand{\obsnamecustom}{Remark}
  \renewcommand{\comnamecustom}{Commentary}
  \renewcommand{\casenamecustom}{Case}
  \renewcommand{\condnamecustom}{Condition}
  \renewcommand{\claimnamecustom}{Claim}
  \renewcommand{\proofclaimnamecustom}{Proof of the claim.}
  \renewcommand{\basecasenamecustom}{Base Case}
  \renewcommand{\indstepnamecustom}{Inductive Step}
  \renewcommand{\indhypnamecustom}{Induction Hypothesis (I.H.)}
  \renewcommand{\noteboxnamecustom}{Note}
  \renewcommand{\warnboxnamecustom}{Warning}
  \renewcommand{\ctrlboxnamecustom}{Control Question}
  \renewcommand{\coverrefname}{Main References}
  \renewcommand{\summaryname}{SUMMARY}
  \addto\captionsenglish{%
    \renewcommand{\proofname}{Proof}%
    \renewcommand{\tablename}{Table}%
    \renewcommand{\listtablename}{List of Tables}%
    \renewcommand{\listfigurename}{List of Figures}%
  }
\fi

\if@langspanish
  \RequirePackage[spanish,es-nodecimaldot,es-sloppy]{babel}
  \RequirePackage[spanish]{datetime2}
  \addto\captionsspanish{%
    \renewcommand{\proofname}{Prueba}%
    \renewcommand{\tablename}{Tabla}%
    \renewcommand{\listtablename}{Lista de Tablas}%
    \renewcommand{\listfigurename}{Lista de Figuras}%
    \renewcommand{\summaryname}{SUMARIO}%
    \renewcommand{\exercicesnamecustom}{Ejercicios}%
    \renewcommand{\notehistnamecustom}{Nota Histórica}%
    \renewcommand{\livrenamecustom}{Libro}%
  }
\fi

\if@langfrench
  \RequirePackage[french]{babel}
  \renewcommand{\indexnamecustom}{Index Alphabétique}
  \renewcommand{\thmnamecustom}{Théorème}
  \renewcommand{\propnamecustom}{Proposition}
  \renewcommand{\lemmanamecustom}{Lemme}
  \renewcommand{\cornamecustom}{Corollaire}
  \renewcommand{\defnamecustom}{Définition}
  \renewcommand{\exnamecustom}{Exemple}
  \renewcommand{\exernamecustom}{Exercice}
  \renewcommand{\exercicesnamecustom}{Exercices}
  \renewcommand{\notehistnamecustom}{Note Historique}
  \renewcommand{\livrenamecustom}{Livre}
  \renewcommand{\solnamecustom}{Solution}
  \renewcommand{\cexnamecustom}{Contre-exemple}
  \renewcommand{\algnamecustom}{Algorithme}
  \renewcommand{\obsnamecustom}{Remarque}
  \renewcommand{\comnamecustom}{Commentaire}
  \renewcommand{\casenamecustom}{Cas}
  \renewcommand{\condnamecustom}{Condition}
  \renewcommand{\claimnamecustom}{Affirmation}
  \renewcommand{\proofclaimnamecustom}{Démonstration de l'affirmation.}
  \renewcommand{\basecasenamecustom}{Cas de Base}
  \renewcommand{\indstepnamecustom}{Pas Inductif}
  \renewcommand{\indhypnamecustom}{Hypothèse de Récurrence (H.R.)}
  \renewcommand{\noteboxnamecustom}{Note}
  \renewcommand{\warnboxnamecustom}{Attention}
  \renewcommand{\ctrlboxnamecustom}{Question de Contrôle}
  \renewcommand{\coverrefname}{Références Principales}
  \renewcommand{\summaryname}{SOMMAIRE}
  \addto\captionsfrench{%
    \renewcommand{\proofname}{Démonstration}%
    \renewcommand{\tablename}{Table}%
    \renewcommand{\listtablename}{Liste des Tables}%
    \renewcommand{\listfigurename}{Liste des Figures}%
    \renewcommand{\summaryname}{SOMMAIRE}%
  }
\fi

\if@langgerman
  \RequirePackage[ngerman]{babel}
  \renewcommand{\indexnamecustom}{Stichwortverzeichnis}
  \renewcommand{\thmnamecustom}{Satz}
  \renewcommand{\propnamecustom}{Proposition}
  \renewcommand{\lemmanamecustom}{Lemma}
  \renewcommand{\cornamecustom}{Korollar}
  \renewcommand{\defnamecustom}{Definition}
  \renewcommand{\exnamecustom}{Beispiel}
  \renewcommand{\exernamecustom}{Übung}
  \renewcommand{\exercicesnamecustom}{Übungen}
  \renewcommand{\notehistnamecustom}{Historische Anmerkung}
  \renewcommand{\livrenamecustom}{Buch}
  \renewcommand{\solnamecustom}{Lösung}
  \renewcommand{\cexnamecustom}{Gegenbeispiel}
  \renewcommand{\algnamecustom}{Algorithmus}
  \renewcommand{\obsnamecustom}{Bemerkung}
  \renewcommand{\comnamecustom}{Kommentar}
  \renewcommand{\casenamecustom}{Fall}
  \renewcommand{\condnamecustom}{Bedingung}
  \renewcommand{\claimnamecustom}{Behauptung}
  \renewcommand{\proofclaimnamecustom}{Beweis der Behauptung.}
  \renewcommand{\basecasenamecustom}{Induktionsanfang}
  \renewcommand{\indstepnamecustom}{Induktionsschritt}
  \renewcommand{\indhypnamecustom}{Induktionsvoraussetzung (I.V.)}
  \renewcommand{\noteboxnamecustom}{Hinweis}
  \renewcommand{\warnboxnamecustom}{Warnung}
  \renewcommand{\ctrlboxnamecustom}{Kontrollfrage}
  \renewcommand{\coverrefname}{Hauptreferenzen}
  \renewcommand{\summaryname}{ÜBERSICHT}
  \addto\captionsngerman{%
    \renewcommand{\proofname}{Beweis}%
    \renewcommand{\tablename}{Tabelle}%
    \renewcommand{\listtablename}{Tabellenverzeichnis}%
    \renewcommand{\listfigurename}{Abbildungsverzeichnis}%
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

% Tipografía Principal: STIX Two (Científica / Editorial IHÉS Contemporánea) con fallback a TeX Gyre Termes
\IfFontExistsTF{STIX Two Text}{%
  \setmainfont{STIX Two Text}[
    Renderer = HarfBuzz,
    BoldFont = * Bold,
    ItalicFont = * Italic,
    BoldItalicFont = * Bold Italic,
    Numbers = {Proportional, Lining}
  ]
  \setmathfont{STIX Two Math}[StylisticSet = {1, 8}]
}{%
  \IfFontExistsTF{STIXTwoText-Regular.ttf}{%
    \setmainfont{STIXTwoText-Regular.ttf}[
      Renderer = HarfBuzz,
      BoldFont = STIXTwoText-Bold.ttf,
      ItalicFont = STIXTwoText-Italic.ttf,
      BoldItalicFont = STIXTwoText-BoldItalic.ttf,
      Numbers = {Proportional, Lining}
    ]
    \setmathfont{STIX Two Math}[StylisticSet = {1, 8}]
  }{%
    \setmainfont{TeX Gyre Termes}[Ligatures=TeX]
    \setmathfont{TeX Gyre Termes Math}
  }%
}

\IfFontExistsTF{TeX Gyre Heros}{%
  \setsansfont{TeX Gyre Heros}[Scale = MatchLowercase]
}{%
  \IfFontExistsTF{texgyreheros-regular.otf}{%
    \setsansfont{texgyreheros-regular.otf}[
      Scale = MatchLowercase,
      BoldFont = texgyreheros-bold.otf,
      ItalicFont = texgyreheros-italic.otf,
      BoldItalicFont = texgyreheros-bolditalic.otf
    ]
  }{%
    \setsansfont{TeX Gyre Heros}[Scale = MatchLowercase]
  }%
}
\setmonofont{TeX Gyre Cursor}[Scale = MatchLowercase]

\addtokomafont{disposition}{\rmfamily\bfseries}

% Configuración Editorial Estricta de Notas al Pie (IHÉS / KOMA-Script)
\interfootnotelinepenalty=10000
\setlength{\skip\footins}{1.5em plus 0.5em minus 0.3em}
\setlength{\dimen\footins}{0.5\textheight}
\deffootnote[1.5em]{1.5em}{0em}{\textsuperscript{\thefootnotemark}\enskip}
\KOMAoptions{footnotes=multiple}
\setkomafont{footnote}{\normalfont\footnotesize\setstretch{1.05}}

% Penalidades de viudas, huérfanas y saltos de línea
\clubpenalty=10000
\widowpenalty=10000
\displaywidowpenalty=10000
\brokenpenalty=10000
\raggedbottom

\RequirePackage[activate={true,nocompatibility}, protrusion=true, expansion=true, final, factor=1100, stretch=10, shrink=10]{microtype}

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

% --- Estilos TikZ para Diagramas de Programación No Lineal y Geometría ---
\tikzset{
    pnldiagram/.style={
        >={Stealth[scale=1.1]},
        scale=1.3,
        every node/.append style={font=\small},
        line width=0.75pt,
        baseline=(current bounding box.center)
    },
    pnlaxis/.style={->, >=Stealth, thick, color=black!70},
    feasible set/.style={draw=MidnightBlue!85!black, fill=MidnightBlue!12, thick},
    infeasible set/.style={draw=Maroon!85!black, fill=Maroon!10, thick},
    contour/.style={draw=ForestGreen!85!black, thick},
    contour label/.style={font=\footnotesize\itshape, color=ForestGreen!90!black},
    vector/.style={->, >=Stealth, very thick, color=Maroon},
    tangent vector/.style={->, >=Stealth, thick, color=ForestGreen!80!black},
    descent vector/.style={->, >=Stealth, thick, color=red!80!black},
    tangent line/.style={draw=ForestGreen!80!black, thick},
    normal line/.style={draw=Maroon, thick},
    point/.style={circle, fill=black, inner sep=0pt, minimum size=3.5pt},
    point label/.style={font=\small},
    cone fill/.style={fill=ForestGreen!15, draw=ForestGreen!85!black, thick},
    cone border/.style={draw=ForestGreen!90!black, thick},
    hyperplane/.style={draw=ForestGreen!80!black, line width=1.4pt},
    subgradient/.style={draw=Maroon, thick},
    neighborhood/.style={draw=Maroon!80!black, fill=Maroon!5, dashed, thick}
}

\RequirePackage{etoc}
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

% =========================================================
% 5.1 SIGNOS MARGINALES BOURBAKI Y TOURNANTS DANGEREUX
% =========================================================
\newcommand{\viragedangereuxglyph}{%
  \begin{tikzpicture}[scale=0.13, baseline=-0.5ex]
    \draw[line width=1.5pt, line cap=round, line join=round] 
      (0.7,-1.5) -- (0.7,-0.4) arc (0:180:0.7) -- (-0.7,0.4) arc (-180:0:0.7) -- (0.7,1.5);
  \end{tikzpicture}%
}

\newcommand{\dbviragedangereuxglyph}{%
  \begin{tikzpicture}[scale=0.13, baseline=-0.5ex]
    \draw[line width=1.35pt, line cap=round, line join=round] 
      (0.3,-1.5) -- (0.3,-0.4) arc (0:180:0.35) -- (-0.4,0.4) arc (-180:0:0.35) -- (0.3,1.5);
    \draw[line width=1.35pt, line cap=round, line join=round] 
      (1.1,-1.5) -- (1.1,-0.4) arc (0:180:0.35) -- (0.4,0.4) arc (-180:0:0.35) -- (1.1,1.5);
  \end{tikzpicture}%
}

\newcommand{\viragedangereux}{\marginnote{\centering\viragedangereuxglyph}\ignorespaces}
\newcommand{\dbviragedangereux}{\marginnote{\centering\dbviragedangereuxglyph}\ignorespaces}
\let\bourbakidanger\viragedangereux
\let\bourbakidbdanger\dbviragedangereux
\let\danger\viragedangereux
\let\dbdanger\dbviragedangereux

\newenvironment{dangerousbend}{\par\vspace{4pt plus 1pt minus 1pt}\viragedangereux\noindent\ignorespaces}{\par\vspace{4pt plus 1pt minus 1pt}}
\newenvironment{doubledangerousbend}{\par\vspace{4pt plus 1pt minus 1pt}\dbviragedangereux\noindent\ignorespaces}{\par\vspace{4pt plus 1pt minus 1pt}}
\let\tournantdangereux\dangerousbend
\let\endtournantdangereux\enddangerousbend
\let\doubletournantdangereux\doubledangerousbend
\let\enddoubletournantdangereux\enddoubledangerousbend

\newcommand{\oldpage}[2][]{{\marginnote{\normalfont\footnotesize{\textbf{#1}~|~#2}}}\ignorespaces}
\newcommand{\ega}[2]{\oldpage[\textbf{EGA #1}]{#2}}
\newcommand{\sga}[2]{\oldpage[\textbf{SGA #1}]{#2}}
\newcommand{\fac}[1]{\oldpage[\textbf{FAC}]{#1}}
\newcommand{\fga}[1]{\oldpage[\textbf{FGA}]{#1}}
\newcommand{\bourbakibreak}{\par\vspace{8pt plus 2pt minus 2pt}\centerline{\rmfamily\scshape * * *}\vspace{8pt plus 2pt minus 2pt}\par}
\let\egabreak\bourbakibreak
\let\sectionbreak\bourbakibreak

% =========================================================
% 5.2 SECCIÓN DE EJERCICIOS Y NOTA HISTÓRICA BOURBAKI
% =========================================================
\newenvironment{exercices}[1][\exercicesnamecustom]{%
  \par\vspace{18pt plus 4pt minus 2pt}%
  \phantomsection
  \if@isarticle
    \addcontentsline{toc}{section}{#1}%
  \else
    \addcontentsline{toc}{section}{#1}%
  \fi
  \noindent\centerline{\fontsize{13pt}{16pt}\selectfont\rmfamily\scshape #1}%
  \par\vspace{4pt}%
  \centerline{\rule{0.3\textwidth}{0.4pt}}%
  \vspace{10pt}%
  \begingroup\small\setstretch{1.08}%
  \begin{enumerate}[
    label=\normalfont\textbf{\arabic*)},
    ref=\arabic*,
    leftmargin=2.2em,
    itemsep=4pt plus 1pt minus 1pt,
    topsep=4pt,
    partopsep=0pt,
    parsep=2pt
  ]%
}{%
  \end{enumerate}%
  \endgroup
  \par\vspace{14pt plus 3pt minus 2pt}%
}

\newcommand{\exer}{\item}
\newcommand{\exerdif}{\item[\normalfont\textbf{*~\arabic*)}]}
\newcommand{\exerpro}{\item[\normalfont\textbf{**~\arabic*)}]}

\newenvironment{notehistorique}[1][\notehistnamecustom]{%
  \par\vspace{22pt plus 4pt minus 2pt}%
  \phantomsection
  \if@isarticle
    \addcontentsline{toc}{section}{#1}%
  \else
    \addcontentsline{toc}{section}{#1}%
  \fi
  \noindent\centerline{\fontsize{14pt}{18pt}\selectfont\rmfamily\scshape #1}%
  \par\vspace{6pt}%
  \centerline{\rule{0.4\textwidth}{0.4pt}}%
  \vspace{12pt}%
  \begingroup\small\setstretch{1.10}%
  \noindent\ignorespaces
}{%
  \endgroup
  \par\vspace{18pt plus 3pt minus 2pt}%
}


% Logo ORCID vectorial de alta precisión
\newcommand{\OrigHeight}{0.00390625}
\newlength{\Xheight}\setlength{\Xheight}{\fontcharht\font`X}
\newcommand{\orcidlogo}{\begin{tikzpicture}[yscale=-\OrigHeight*\Xheight,xscale=\OrigHeight*\Xheight,transform shape]\fill[orcidlogocol] svg{M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z};\fill[white] svg{M86.3,186.2H70.9V79.1h15.4v48.4V186.2z}svg{M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z} svg{M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z};\end{tikzpicture}}

% =========================================================
% 6. ENCABEZADOS Y PIES (scrlayer-scrpage)
% =========================================================
\RequirePackage[automark]{scrlayer-scrpage}
\pagestyle{scrheadings}
\clearpairofpagestyles
\KOMAoptions{headsepline=0.35pt}

\if@isarticle
  \ohead{\small\pagemark}
  \ihead{\small\rmfamily\scshape\headmark}
  \cfoot[]{}
\else
  \automark[section]{chapter}
  \if@estiloihes
    \lehead{\small\rmfamily\pagemark\qquad\scshape\MakeLowercase{\headmark}}
    \rohead{\small\rmfamily\scshape\MakeLowercase{\headmark}\qquad\pagemark}
    \ofoot[]{}
  \else
    \lehead{\small\sffamily\headmark}
    \rohead{\small\sffamily\headmark}
    \ofoot[\pagemark]{\pagemark}
  \fi
\fi
\setkomafont{pageheadfoot}{\normalfont\small}
\setkomafont{pagenumber}{\normalfont\normalsize}
\setkomafont{caption}{\fontsize{9pt}{11pt}\selectfont\itshape}
\setkomafont{captionlabel}{\fontsize{9pt}{11pt}\selectfont\bfseries}
\renewcommand*{\captionformat}{.\enskip}

% =========================================================
% 7. FORMATO DE SECCIONES, CAPÍTULOS Y SUMARIOS BOURBAKI
% =========================================================
\newif\if@enapendice\@enapendicefalse
\g@addto@macro\appendix{\@enapendicetrue}

\if@isarticle
  \addtokomafont{section}{\Large\rmfamily\scshape\centering}
  \addtokomafont{subsection}{\large\rmfamily\bfseries}
  \addtokomafont{subsubsection}{\normalsize\rmfamily\itshape}
  \renewcommand*{\sectionformat}{§~\thesection.\enskip}
  \renewcommand*{\subsectionformat}{\thesubsection.\enskip}
\else
  \if@estiloihes
    \KOMAoptions{chapterprefix=true}
    \setkomafont{disposition}{\rmfamily}   
    \setkomafont{chapterentry}{\rmfamily\scshape} 
    \setkomafont{chapterprefix}{\fontsize{13pt}{17pt}\selectfont\rmfamily\scshape}
    \setkomafont{chapter}{\fontsize{17pt}{22pt}\selectfont\rmfamily\bfseries}
    \setkomafont{section}{\fontsize{12.5pt}{16pt}\selectfont\rmfamily\scshape}
    \setkomafont{subsection}{\fontsize{11pt}{14pt}\selectfont\rmfamily\bfseries}
    \setkomafont{subsubsection}{\fontsize{10.5pt}{13pt}\selectfont\rmfamily\itshape}
    
    \renewcommand*{\raggedchapter}{\centering}
    \renewcommand*{\chapterformat}{\chaptername~\thechapter}
    \renewcommand*{\raggedsection}{\centering}
    \renewcommand*{\sectionformat}{§~\thesection.\enskip}
    \renewcommand*{\subsectionformat}{\thesubsection.\enskip}

    \renewcommand*{\chapterlineswithprefixformat}[3]{%
      \Ifstr{#2}{}{#3}{%
        \centering
        {\fontsize{13pt}{17pt}\selectfont\rmfamily\scshape #2}\par\nobreak\vspace{0.35cm}%
        {\fontsize{17pt}{22pt}\selectfont\rmfamily\bfseries #3}\par\nobreak\vspace{0.45cm}%
      }%
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

    \KOMAoptions{toc=chapterentrywithdots}
    \setkomafont{chapterentry}{\normalfont\scshape}
    \setkomafont{chapterentrypagenumber}{\normalfont\scshape}
    \RedeclareSectionCommand[tocnumwidth=2.5em, tocpagenumberwidth=2.5em]{chapter}
    \RedeclareSectionCommand[tocindent=2.5em, tocnumwidth=3.0em, tocpagenumberwidth=2.5em]{section}
    \RedeclareSectionCommand[tocindent=5.5em, tocnumwidth=3.5em, tocpagenumberwidth=2.5em]{subsection}
    \RedeclareSectionCommand[tocindent=8.5em, tocnumwidth=4.0em, tocpagenumberwidth=2.5em]{subsubsection}
  \else
    \addtokomafont{chapter}{\Huge\bfseries\color{MidnightBlue!80!black}}
    \renewcommand*{\chapterformat}{\mbox{\fontsize{48}{52}\selectfont\color{MidnightBlue!18}\thechapter\autodot\enskip}}
    \renewcommand*{\chapterlinesformat}[3]{\parbox{\textwidth}{\raggedleft #2#3\par\vspace{-1ex}\textcolor{MidnightBlue!60!black}{\rule{\textwidth}{1.5pt}}}}
    \addtokomafont{section}{\Large\bfseries\color{MidnightBlue!80!black}}
    \addtokomafont{subsection}{\large\bfseries\color{MidnightBlue!70!black}}
    \addtokomafont{part}{\color{MidnightBlue!80!black}}
    \RedeclareSectionCommand[beforeskip=0pt, afterskip=20pt]{chapter}
    \RedeclareSectionCommand[beforeskip=18pt, afterskip=6pt]{section}
    \RedeclareSectionCommand[beforeskip=18pt, afterskip=6pt]{subsection}
    \RedeclareSectionCommand[beforeskip=12pt, afterskip=6pt]{subsubsection}
  \fi
\fi

% Sumario de Capítulo estilo Bourbaki / IHÉS (Sommaire du chapitre)
\newcommand{\chaptersummary}[1][\summaryname]{%
  \IfFileExists{\jobname.toc}{%
    \begingroup
    \etocsetnexttocdepth{section}%
    \setlength{\parskip}{0pt}%
    \setlength{\parindent}{0pt}%
    \setstretch{1.02}%
    \etocsettocstyle{%
      \par\vspace{0.8em}\centerline{\fontsize{10pt}{12pt}\selectfont\rmfamily\scshape #1}\vspace{0.4em}\hrule height 0.35pt\vspace{0.5em}%
    }{\vspace{0.5em}\hrule height 0.35pt\vspace{1.2em}\par}%
    \etocsetstyle{section}{}{%
      \par\noindent\leftskip=1.5cm\rightskip=1.0cm\parindent=0pt
    }{%
      \etocifnumbered{%
        \makebox[3.2em][l]{\etoclink{§~\etocnumber.}}\etocname.\par\vspace{2.0pt}%
      }{%
        \hspace*{1.0em}\textit{\etocname}.\par\vspace{2.0pt}%
      }%
    }{}%
    \localtableofcontents
    \endgroup
  }{}%
}

% Manejo Inteligente de Apéndices en Modo Libro
\newcommand{\iniciarapendices}{%
  \cleardoublepage
  \appendix
  \@enapendicetrue
  \if@estiloihes
    \renewcommand*{\chapterformat}{\appendixname~\thechapter.\enskip}
  \else
    \renewcommand*{\chapterformat}{\appendixname~\thechapter}
  \fi
  \DeclareTOCStyleEntry[
    numwidth=6.5em,
    entrynumberformat=\tocappendixprefix
  ]{chapter}{chapter}
  \if@estilobonn
    \renewcommand{\theequation}{\thechapter.\arabic{equation}}
  \fi
}
\newcommand\tocappendixprefix[1]{\appendixname~#1}

% Soporte para Capítulo Cero / Preliminares (EGA Chapitre 0)
\newcommand{\chapitrezero}[2][]{%
  \cleardoublepage
  \setcounter{chapter}{-1}%
  \ifblank{#1}{\chapter{#2}}{\chapter[#1]{#2}}%
}
\let\capitulozero\chapitrezero

% Colofón Editorial Monumental EGA / IHÉS
\newcommand{\colophon}[1][]{%
  \cleardoublepage
  \thispagestyle{empty}%
  \vspace*{\fill}%
  \begin{center}%
    \rule{3.0cm}{0.35pt}\par\vspace{1.5em}%
    {\small\rmfamily\scshape\ifblank{#1}{Institut des Hautes Études Scientifiques}{#1}}\par\vspace{0.6em}%
    \ifx\@lugar\@empty\else{\footnotesize\rmfamily \@lugar}\par\vspace{0.4em}\fi%
    \ifx\@date\@empty\else{\footnotesize\rmfamily \@date}\par\fi%
    \vspace{1.5em}\rule{3.0cm}{0.35pt}%
  \end{center}%
  \vspace*{2cm}%
}

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
\newtcolorbox{notabox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=MidnightBlue!3, colframe=MidnightBlue!60!black, title={\ifblank{#1}{\textbf{\noteboxnamecustom}}{\textbf{\noteboxnamecustom}: #1}}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{warningbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=red!3, colframe=red!60!black, title={\ifblank{#1}{\textbf{\warnboxnamecustom}}{\textbf{\warnboxnamecustom}: #1}}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}
\newtcolorbox{controlbox}[1][]{enhanced, breakable, arc=2pt, boxrule=0.5pt, colback=ForestGreen!3, colframe=ForestGreen!40!black, title={\ifblank{#1}{\textbf{\ctrlboxnamecustom}}{\textbf{\ctrlboxnamecustom}: #1}}, left=4mm, right=4mm, top=2mm, bottom=2mm, before skip=\mastervskip, after skip=\mastervskip, drop fuzzy shadow}

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
  \RequirePackage[backend=biber, style=alphabetic, sorting=anyt, backref=true]{biblatex}
\fi
\if@citaieee
  \RequirePackage[backend=biber, style=ieee, sorting=none, backref=true]{biblatex}
\fi
\if@citaapa
  \RequirePackage[backend=biber, style=apa, sorting=nyt, backref=true]{biblatex}
\fi
\if@citanumeric
  \RequirePackage[backend=biber, style=numeric-comp, sorting=none, backref=true]{biblatex}
\fi

\RequirePackage[colorlinks=true, linkcolor=CiteBurgundy, citecolor=CiteBurgundy, urlcolor=MidnightBlue, plainpages=false, pdfpagelabels=true, pdfencoding=auto, psdextra]{hyperref}
\RequirePackage{bookmark} 

\pdfstringdefDisableCommands{%
  \def\\{}%
  \def\medskip{}%
  \def\sref#1{(#1)}%
  \def\eref#1{(#1)}%
  \def\csref#1{#1}%
  \def\namedsref#1#2{#1 (#2)}%
  \def\titref#1#2{#2}%
  \def\autonamedsref#1{#1}%
  \def\srefname#1#2{(#1, #2)}%
  \def\namesref#1{#1}%
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

\if@isarticle
  \newcounter{proofcount}[section]
  \newcounter{claimcount}[section]
  \def\theHproofcount{\theHsection.\arabic{proofcount}}
  \def\theHclaimcount{\theHsection.\arabic{proofcount}.\arabic{claimcount}}
\else
  \newcounter{proofcount}[chapter]
  \newcounter{claimcount}[chapter]
  \def\theHproofcount{\theHchapter.\arabic{proofcount}}
  \def\theHclaimcount{\theHchapter.\arabic{proofcount}.\arabic{claimcount}}
\fi

\if@estiloihes
  % --- Bourbaki / IHÉS: Formato (1.1.1) Teorema. — --- 
  \newtheoremstyle{ihes-plain}%
    {\mastervskip}%
    {\mastervskip}%
    {\itshape}%
    {0pt}%
    {\rmfamily}%
    {}%
    {0pt}%
    {\thmnumber{\textbf{(#2)}}\enskip\textbf{\thmname{#1}}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.\ \textemdash\enskip}

  \newtheoremstyle{ihes-def}%
    {\mastervskip}%
    {\mastervskip}%
    {\normalfont}%
    {0pt}%
    {\rmfamily}%
    {}%
    {0pt}%
    {\thmnumber{\textbf{(#2)}}\enskip\textbf{\thmname{#1}}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.\ \textemdash\enskip}

  \newtheoremstyle{ihes-remark}%
    {\mastervskip}%
    {\mastervskip}%
    {\normalfont}%
    {0pt}%
    {\rmfamily}%
    {}%
    {0pt}%
    {\thmnumber{\textbf{(#2)}}\enskip\textit{\thmname{#1}}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.\ \textemdash\enskip}



  \if@isarticle
    \theoremstyle{ihes-plain}
    \newtheorem{theorem}{\thmnamecustom}[section]
    \newtheorem{proposition}[theorem]{\propnamecustom}
    \newtheorem{lemma}[theorem]{\lemmanamecustom}
    \newtheorem{corollary}[theorem]{\cornamecustom}

    \theoremstyle{ihes-def}
    \newtheorem{definition}[theorem]{\defnamecustom}
    \newtheorem{example}[theorem]{\exnamecustom}
    \newtheorem{exercise}[theorem]{\exernamecustom}
    \newtheorem{solution}[theorem]{\solnamecustom}
    \newtheorem{counterexample}[theorem]{\cexnamecustom}
    \newtheorem{algorithm}[theorem]{\algnamecustom}
    \newtheorem{conventions}[theorem]{Convenciones}

    \theoremstyle{ihes-remark}
    \newtheorem{remark}[theorem]{\obsnamecustom}
    \newtheorem{commentary}[theorem]{\comnamecustom}
    \newtheorem{notation}[theorem]{Notación}
    \newtheorem{objetive}[theorem]{Objetivo}
    \newtheorem{scholium}[theorem]{Escolio}
    \newtheorem{scholie}[theorem]{Scholie}
    \newtheorem{rappel}[theorem]{Recordatorio}
  \else
    \theoremstyle{ihes-plain}
    \newtheorem{theorem}{\thmnamecustom}[section]
    \newtheorem{proposition}[theorem]{\propnamecustom}
    \newtheorem{lemma}[theorem]{\lemmanamecustom}
    \newtheorem{corollary}[theorem]{\cornamecustom}

    \theoremstyle{ihes-def}
    \newtheorem{definition}[theorem]{\defnamecustom}
    \newtheorem{example}[theorem]{\exnamecustom}
    \newtheorem{exercise}[theorem]{\exernamecustom}
    \newtheorem{solution}[theorem]{\solnamecustom}
    \newtheorem{counterexample}[theorem]{\cexnamecustom}
    \newtheorem{algorithm}[theorem]{\algnamecustom}
    \newtheorem{conventions}[theorem]{Convenciones}

    \theoremstyle{ihes-remark}
    \newtheorem{remark}[theorem]{\obsnamecustom}
    \newtheorem{commentary}[theorem]{\comnamecustom}
    \newtheorem{notation}[theorem]{Notación}
    \newtheorem{objetive}[theorem]{Objetivo}
    \newtheorem{scholium}[theorem]{Escolio}
    \newtheorem{scholie}[theorem]{Scholie}
    \newtheorem{rappel}[theorem]{Recordatorio}
  \fi
\else
  \newtheoremstyle{my-thm-style}{\mastervskip}{\mastervskip}{\itshape}{}{\normalfont}{}{0.5em}{\bfseries\color{Black}\thmname{#1}\space\thmnumber{#2}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.}
  \newtheoremstyle{my-plain-style}{\mastervskip}{\mastervskip}{\normalfont}{}{\normalfont}{}{0.5em}{\bfseries\thmname{#1}\space\thmnumber{#2}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.}
  \newtheoremstyle{my-remark-style}{\mastervskip}{\mastervskip}{\normalfont}{}{\itshape}{}{0.5em}{\bfseries\thmname{#1}\IfBlankTF{#3}{\def\@currentlabelname{}}{\def\@currentlabelname{#3}\thmnote{ (#3)}}.}

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
    \theoremstyle{my-remark-style}
    \newtheorem{remark}{\obsnamecustom}[section]
    \newtheorem{commentary}{\comnamecustom}[section]
    \newtheorem{notation}{Notación}[section]
    \newtheorem{objetive}{Objetivo}[section]
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
    \theoremstyle{my-remark-style}
    \newtheorem{remark}{\obsnamecustom}[chapter]
    \newtheorem{commentary}{\comnamecustom}[chapter]
    \newtheorem{notation}{Notación}[chapter]
    \newtheorem{objetive}{Objetivo}[chapter]
  \fi
\fi

\newcounter{casocounter}[section]
\newcounter{condicioncounter}[section]

% Párrafos numerados estilo EGA: (1.1.1) Texto...
\newcommand{\parag}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{\thetheorem.\ifx&#1&\else\ #1.\fi}\enskip\ignorespaces}
\newcommand{\numpar}[1][]{\refstepcounter{theorem}\par\vspace{4pt plus 1pt minus 1pt}\noindent\textbf{(\thetheorem)}\ifblank{#1}{\textbf{.\ \textemdash}}{\ \textbf{\textit{#1.}}\ \textbf{\textemdash}}\enskip\ignorespaces}

\renewcommand{\qedsymbol}{\ensuremath{\blacksquare}}

% Entorno de Demostración IHÉS con Barra Lateral
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
  \renewenvironment{proof}[1][\proofname]{%
    \par\stepcounter{proofcount}\setcounter{claimcount}{0}\pushQED{\qed}%
    \normalfont\small\setstretch{1.10}%
    \noindent\textbf{\textit{#1\@addpunct{.}}}\hspace{0.5em}\ignorespaces
  }{%
    \popQED\par
    \vspace{4pt plus 2pt minus 1pt}%
  }
  \tcolorboxenvironment{proof}{blanker, breakable, left=6mm, right=4mm, top=0pt, bottom=0pt, before skip=\mastervskip, after skip=\mastervskip, borderline west={1.2pt}{0pt}{MidnightBlue!35}}
\fi

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
  \crefname{counterexample}{contraejemplo}{contraejemplos}
  \Crefname{counterexample}{Contraejemplo}{Contraejemplos}
  \crefname{remark}{observación}{observaciones}
  \Crefname{remark}{Observación}{Observaciones}
  \crefname{commentary}{comentario}{comentarios}
  \Crefname{commentary}{Comentario}{Comentarios}
  \crefname{notation}{notación}{notaciones}
  \Crefname{notation}{Notación}{Notaciones}
  \crefname{claim}{afirmación}{afirmaciones}
  \Crefname{claim}{Afirmación}{Afirmaciones}
  \crefname{algorithm}{algoritmo}{algoritmos}
  \Crefname{algorithm}{Algoritmo}{Algoritmos}
  \crefname{chapter}{capítulo}{capítulos}
  \Crefname{chapter}{Capítulo}{Capítulos}
  \crefname{section}{sección}{secciones}
  \Crefname{section}{Sección}{Secciones}
  \crefname{subsection}{subsección}{subsecciones}
  \Crefname{subsection}{Subsección}{Subsecciones}
  \crefname{convencionbox}{convención}{convenciones}
  \Crefname{convencionbox}{Convención}{Convenciones}
  \crefname{scholium}{escolio}{escolios}
  \Crefname{scholium}{Escolio}{Escolios}
  \crefname{scholie}{escolio}{escolios}
  \Crefname{scholie}{Escolio}{Escolios}
  \crefname{rappel}{recordatorio}{recordatorios}
  \Crefname{rappel}{Recordatorio}{Recordatorios}
  \crefname{conventions}{convención}{convenciones}
  \Crefname{conventions}{Convención}{Convenciones}
  \crefformat{equation}{ecuación~(#2#1#3)}
  \Crefformat{equation}{Ecuación~(#2#1#3)}
\fi

\if@langenglish
  \RequirePackage[english,noabbrev]{cleveref}
  \crefname{equation}{equation}{equations}
  \Crefname{equation}{Equation}{Equations}
  \crefname{theorem}{theorem}{theorems}
  \Crefname{theorem}{Theorem}{Theorems}
  \crefname{proposition}{proposition}{propositions}
  \Crefname{proposition}{Proposition}{Propositions}
  \crefname{lemma}{lemma}{lemmas}
  \Crefname{lemma}{Lemma}{Lemmas}
  \crefname{corollary}{corollary}{corollaries}
  \Crefname{corollary}{Corollary}{Corollaries}
  \crefname{definition}{definition}{definitions}
  \Crefname{definition}{Definition}{Definitions}
  \crefname{example}{example}{examples}
  \Crefname{example}{Example}{Examples}
  \crefname{exercise}{exercise}{exercises}
  \Crefname{exercise}{Exercise}{Exercises}
  \crefname{solution}{solution}{solutions}
  \Crefname{solution}{Solution}{Solutions}
  \crefname{counterexample}{counterexample}{counterexamples}
  \Crefname{counterexample}{Counterexample}{Counterexamples}
  \crefname{remark}{remark}{remarks}
  \Crefname{remark}{Remark}{Remarks}
  \crefname{commentary}{commentary}{commentaries}
  \Crefname{commentary}{Commentary}{Commentaries}
  \crefname{notation}{notation}{notations}
  \Crefname{notation}{Notation}{Notations}
  \crefname{claim}{claim}{claims}
  \Crefname{claim}{Claim}{Claims}
  \crefname{algorithm}{algorithm}{algorithms}
  \Crefname{algorithm}{Algorithm}{Algorithms}
  \crefname{chapter}{chapter}{chapters}
  \Crefname{chapter}{Chapter}{Chapters}
  \crefname{section}{section}{sections}
  \Crefname{section}{Section}{Sections}
  \crefname{subsection}{subsection}{subsections}
  \Crefname{subsection}{Subsection}{Subsections}
  \crefname{convencionbox}{convention}{conventions}
  \Crefname{convencionbox}{Convention}{Conventions}
  \crefname{scholium}{scholium}{scholia}
  \Crefname{scholium}{Scholium}{Scholia}
  \crefname{scholie}{scholium}{scholia}
  \Crefname{scholie}{Scholium}{Scholia}
  \crefname{rappel}{recollection}{recollections}
  \Crefname{rappel}{Recollection}{Recollections}
  \crefname{conventions}{convention}{conventions}
  \Crefname{conventions}{Convention}{Conventions}
  \crefformat{equation}{equation~(#2#1#3)}
  \Crefformat{equation}{Equation~(#2#1#3)}
\fi

\if@langfrench
  \RequirePackage[french,noabbrev]{cleveref}
  \crefname{equation}{équation}{équations}
  \Crefname{equation}{Équation}{Équations}
  \crefname{theorem}{théorème}{théorèmes}
  \Crefname{theorem}{Théorème}{Théorèmes}
  \crefname{proposition}{proposition}{propositions}
  \Crefname{proposition}{Proposition}{Propositions}
  \crefname{lemma}{lemme}{lemmes}
  \Crefname{lemma}{Lemme}{Lemmes}
  \crefname{corollary}{corollaire}{corollaires}
  \Crefname{corollary}{Corollaire}{Corollaires}
  \crefname{definition}{définition}{définitions}
  \Crefname{definition}{Définition}{Définitions}
  \crefname{example}{exemple}{exemples}
  \Crefname{example}{Exemple}{Exemples}
  \crefname{exercise}{exercice}{exercices}
  \Crefname{exercise}{Exercice}{Exercices}
  \crefname{solution}{solution}{solutions}
  \Crefname{solution}{Solution}{Solutions}
  \crefname{counterexample}{contre-exemple}{contre-exemples}
  \Crefname{counterexample}{Contre-exemple}{Contre-exemples}
  \crefname{remark}{remarque}{remarques}
  \Crefname{remark}{Remarque}{Remarques}
  \crefname{commentary}{commentaire}{commentaires}
  \Crefname{commentary}{Commentaire}{Commentaires}
  \crefname{notation}{notation}{notations}
  \Crefname{notation}{Notation}{Notations}
  \crefname{claim}{affirmation}{affirmations}
  \Crefname{claim}{Affirmation}{Affirmations}
  \crefname{algorithm}{algorithme}{algorithmes}
  \Crefname{algorithm}{Algorithme}{Algorithmes}
  \crefname{chapter}{chapitre}{chapitres}
  \Crefname{chapter}{Chapitre}{Chapitres}
  \crefname{section}{section}{sections}
  \Crefname{section}{Section}{Sections}
  \crefname{subsection}{sous-section}{sous-sections}
  \Crefname{subsection}{Sous-section}{Sous-sections}
  \crefname{convencionbox}{convention}{conventions}
  \Crefname{convencionbox}{Convention}{Conventions}
  \crefname{scholium}{scholie}{scholies}
  \Crefname{scholium}{Scholie}{Scholies}
  \crefname{scholie}{scholie}{scholies}
  \Crefname{scholie}{Scholie}{Scholies}
  \crefname{rappel}{rappel}{rappels}
  \Crefname{rappel}{Rappel}{Rappels}
  \crefname{conventions}{convention}{conventions}
  \Crefname{conventions}{Convention}{Conventions}
  \crefformat{equation}{équation~(#2#1#3)}
  \Crefformat{equation}{Équation~(#2#1#3)}
\fi

\if@langgerman
  \RequirePackage[ngerman,noabbrev]{cleveref}
  \crefname{equation}{Gleichung}{Gleichungen}
  \Crefname{equation}{Gleichung}{Gleichungen}
  \crefname{theorem}{Satz}{Sätze}
  \Crefname{theorem}{Satz}{Sätze}
  \crefname{proposition}{Proposition}{Propositionen}
  \Crefname{proposition}{Proposition}{Propositionen}
  \crefname{lemma}{Lemma}{Lemmata}
  \Crefname{lemma}{Lemma}{Lemmata}
  \crefname{corollary}{Korollar}{Korollare}
  \Crefname{corollary}{Korollar}{Korollare}
  \crefname{definition}{Definition}{Definitionen}
  \Crefname{definition}{Definition}{Definitionen}
  \crefname{example}{Beispiel}{Beispiele}
  \Crefname{example}{Beispiel}{Beispiele}
  \crefname{exercise}{Übung}{Übungen}
  \Crefname{exercise}{Übung}{Übungen}
  \crefname{solution}{Lösung}{Lösungen}
  \Crefname{solution}{Lösung}{Lösungen}
  \crefname{counterexample}{Gegenbeispiel}{Gegenbeispiele}
  \Crefname{counterexample}{Gegenbeispiel}{Gegenbeispiele}
  \crefname{remark}{Bemerkung}{Bemerkungen}
  \Crefname{remark}{Bemerkung}{Bemerkungen}
  \crefname{commentary}{Kommentar}{Kommentare}
  \Crefname{commentary}{Kommentar}{Kommentare}
  \crefname{notation}{Notation}{Notationen}
  \Crefname{notation}{Notation}{Notationen}
  \crefname{claim}{Behauptung}{Behauptungen}
  \Crefname{claim}{Behauptung}{Behauptungen}
  \crefname{algorithm}{Algorithmus}{Algorithmen}
  \Crefname{algorithm}{Algorithmus}{Algorithmen}
  \crefname{chapter}{Kapitel}{Kapitel}
  \Crefname{chapter}{Kapitel}{Kapitel}
  \crefname{section}{Abschnitt}{Abschnitte}
  \Crefname{section}{Abschnitt}{Abschnitte}
  \crefname{subsection}{Unterabschnitt}{Unterabschnitte}
  \Crefname{subsection}{Unterabschnitt}{Unterabschnitte}
  \crefname{convencionbox}{Konvention}{Konventionen}
  \Crefname{convencionbox}{Konvention}{Konventionen}
  \crefname{scholium}{Scholie}{Scholien}
  \Crefname{scholium}{Scholie}{Scholien}
  \crefname{scholie}{Scholie}{Scholien}
  \Crefname{scholie}{Scholie}{Scholien}
  \crefname{rappel}{Erinnerung}{Erinnerungen}
  \Crefname{rappel}{Erinnerung}{Erinnerungen}
  \crefname{conventions}{Konvention}{Konventionen}
  \Crefname{conventions}{Konvention}{Konventionen}
  \crefformat{equation}{Gleichung~(#2#1#3)}
  \Crefformat{equation}{Gleichung~(#2#1#3)}
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

\NewDocumentCommand{\namesref}{s o m o}{%
  \IfBooleanTF{#1}{\namecref{#3}~}{\nameCref{#3}~}%
  \IfNoValueTF{#2}{%
    \IfNoValueTF{#4}{\sref{#3}}{\sref{#3}[#4]}%
  }{%
    \IfNoValueTF{#4}{\sref[#2]{#3}}{\sref[#2]{#3}[#4]}%
  }%
  \IfBlankF{\nameref*{#3}}{\nobreakspace\textit{(\nameref*{#3})}}%
}

% Alias de Cleveref para Entornos de Teoremas con Contador Compartido
\AtBeginEnvironment{theorem}{\crefalias{theorem}{theorem}}
\AtBeginEnvironment{proposition}{\crefalias{theorem}{proposition}}
\AtBeginEnvironment{lemma}{\crefalias{theorem}{lemma}}
\AtBeginEnvironment{corollary}{\crefalias{theorem}{corollary}}
\AtBeginEnvironment{definition}{\crefalias{theorem}{definition}}
\AtBeginEnvironment{example}{\crefalias{theorem}{example}}
\AtBeginEnvironment{exercise}{\crefalias{theorem}{exercise}}
\AtBeginEnvironment{solution}{\crefalias{theorem}{solution}}
\AtBeginEnvironment{counterexample}{\crefalias{theorem}{counterexample}}
\AtBeginEnvironment{algorithm}{\crefalias{theorem}{algorithm}}
\AtBeginEnvironment{remark}{\crefalias{theorem}{remark}}
\AtBeginEnvironment{commentary}{\crefalias{theorem}{commentary}}
\AtBeginEnvironment{notation}{\crefalias{theorem}{notation}}
\AtBeginEnvironment{scholium}{\crefalias{theorem}{scholium}}
\AtBeginEnvironment{scholie}{\crefalias{theorem}{scholie}}
\AtBeginEnvironment{rappel}{\crefalias{theorem}{rappel}}
\AtBeginEnvironment{conventions}{\crefalias{theorem}{conventions}}

\def\theHtheorem{\theHsection.\arabic{theorem}}

\if@estiloihes
  \RequirePackage{chngcntr}
  \numberwithin{equation}{theorem} % Ecuaciones tipo (1.1.1.1)
  \renewcommand{\theequation}{\thetheorem.\arabic{equation}}
\else
  \if@isarticle
    \numberwithin{equation}{section}
  \else
    \numberwithin{equation}{chapter}
  \fi
\fi

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
\let\D\relax\newcommand{\D}{\symbb{D}}
\let\Cn\relax\newcommand{\Cn}{\symbb{C}^{n}}
\let\Rn\relax\newcommand{\Rn}{\symbb{R}^{n}}
\newcommand{\PP}{\symbb{P}} 
\let\A\relax\newcommand{\A}{\symbb{A}}
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

% Límites categóricos estilo Bourbaki / EGA
\newcommand{\dirlim}{\varinjlim}
\newcommand{\invlim}{\varprojlim}
\newcommand{\morf}[3]{\Hom_{#1}(#2, #3)}

% Flechas y morfismos canónicos de esquemas (EGA / SGA)
\newcommand{\xisom}[1][]{\xrightarrow[\smash{#1}]{\sim}}
\newcommand{\isom}{\xisom{}}
\newcommand{\xisoto}[1][]{\xrightarrow[\smash{#1}]{\smash{\raisebox{-0.2ex}{\ensuremath{\scriptstyle\sim}}}}}
\newcommand{\isoto}{\xisoto{}}

% Atajos de Haz y Álgebra Relativa Grothendieck (EGA)
\newcommand{\tensor}{\otimes}
\newcommand{\tensorOx}{\otimes_{\Ox}}
\newcommand{\kappapt}[1]{\kappa(#1)}
\newcommand{\fiber}[2]{#1(#2)}
\newcommand{\Dzar}[1]{\mathrm{D}(#1)}
\newcommand{\Vzar}[1]{\mathrm{V}(#1)}
\newcommand{\OmegaRel}[2]{\Omega_{#1/#2}^1}
\newcommand{\OmegaRelP}[3]{\Omega_{#1/#2}^{#3}}
\newcommand{\HLoc}[3]{H_{#2}^{#1}(#3)}
\DeclareMathOperator{\depth}{depth}

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

\if@langenglish
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
  % 14A. ENCABEZADO TÉCNICO BOURBAKI / IHÉS (MODO ARTÍCULO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \thispagestyle{plain}
    
    \vspace*{-2em}
    \noindent\hrule height 0.6pt\vspace{1.5pt}\hrule height 0.3pt\par\vspace{1.5ex}
    
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
            {\rmfamily\small\scshape \@universidad}\\[0.3ex]
          \fi
          \ifx\@facultad\@empty\else
            {\rmfamily\footnotesize\scshape \@facultad}\\[0.3ex]
          \fi
          \ifx\@curso\@empty\else
            {\rmfamily\footnotesize\itshape \@curso 
            \ifx\@codigo\@empty\else\ (\@codigo)\fi 
            \ifx\@semestre\@empty\else\ -- \@semestre\fi}
          \fi
        \end{flushright}
      \end{minipage}
      
    \par\vspace{2.0ex}
    
    % Bloque 2: Título y Autor Centrados (Estilo Clásico)
    \begin{center}
      \ifx\@title\@empty\else
        {\LARGE\rmfamily\bfseries \@title\par}\vspace{1.0ex}
      \fi
      \ifx\shorttitle\@empty\else
        {\large\rmfamily\itshape \shorttitle\par}\vspace{1.0ex}
      \fi
      \begingroup
      \def\and{\quad\hbox{\normalfont\textbullet}\quad}%
      \ifx\@author\@empty\else
        {\large\rmfamily\scshape \@author}\\[0.4ex]
      \fi
      \endgroup
      \ifx\@email\@empty\else
        {\small\rmfamily\textit{\@email}}\enskip
      \fi
      \ifx\@orcid\@empty\else
        \orcidlogo\ \href{https://orcid.org/\@orcid}{\footnotesize\rmfamily\@orcid}
      \fi
    \end{center}
    
    \vspace{1.5ex}
    
    % Bloque 3: Metadatos y Referencias (A 2 Columnas)
    \noindent
    \begin{minipage}[t]{0.48\textwidth}
      \rmfamily\footnotesize% 
      \ifx\@profesor\@empty\else 
        \textbf{Profesor:} \@profesor\par\vspace{0.6ex}
      \fi
      \ifx\@asistente\@empty\else 
        \textbf{Jefe de Prácticas:} \@asistente\par\vspace{0.6ex}
      \fi
      \textbf{Fecha:} \@date \ifx\@lugar\@empty\else\ (\@lugar)\fi\par\vspace{0.6ex}%
      \ifx\@version\@empty\else 
        \textbf{Versión:} \@version\par\vspace{0.6ex}
      \fi
    \end{minipage}%
    \hfill
    \begin{minipage}[t]{0.48\textwidth}
      \rmfamily\footnotesize% 
      \ifx\@referencias\@empty\else
        \textbf{\coverrefname:}\par\vspace{0.6ex}%
        {\color{black!80}\@referencias}
      \fi
    \end{minipage}
    
    \par\vspace{2.0ex}
    \noindent\hrule height 0.3pt\vspace{1.5pt}\hrule height 0.6pt
    \par\vspace{2.5em}
  }
\else
  % ---------------------------------------------------------
  % 14B. PORTADA MONUMENTAL BOURBAKI (MODO LIBRO)
  % ---------------------------------------------------------
  \renewcommand{\maketitle}{%
    \begin{titlepage}
      \thispagestyle{empty} 
      
      \vspace*{0.5cm}
      \begin{center}
        \ifx\@universidad\@empty
          {\fontsize{13pt}{17pt}\selectfont\rmfamily\scshape ÉLÉMENTS DE MATHÉMATIQUE}\\[0.4ex]
        \else
          {\fontsize{13pt}{17pt}\selectfont\rmfamily\scshape \@universidad}\\[0.4ex]
        \fi
        \ifx\@facultad\@empty\else
          {\fontsize{11pt}{15pt}\selectfont\rmfamily\scshape \@facultad}\\[0.4ex]
        \fi
        \ifx\@curso\@empty\else
          {\fontsize{10.5pt}{14pt}\selectfont\rmfamily\itshape \@curso
          \ifx\@codigo\@empty\else\ \textbf{--} \@codigo\fi}\\[0.3ex]
        \fi
        \ifx\@semestre\@empty\else
          {\fontsize{9.5pt}{13pt}\selectfont\rmfamily \@semestre}
        \fi
        
        \vspace{1.2cm}
        \rule{4.5cm}{0.4pt}
        \vspace{1.5cm}
        
        \begingroup
        \def\and{\quad\hbox{\normalfont\textbullet}\quad}%
        \ifx\@author\@empty\else
          {\fontsize{14pt}{18pt}\selectfont\rmfamily\scshape \@author}\\[1.5cm]
        \fi
        \endgroup
        
        \ifx\@title\@empty\else
          {\fontsize{20pt}{26pt}\selectfont\rmfamily\bfseries \@title}\\[1.2ex]
        \fi
        \ifx\shorttitle\@empty\else
          {\fontsize{13pt}{17pt}\selectfont\rmfamily\itshape \shorttitle}\\[1.0ex]
        \fi
        
        \ifx\@orcid\@empty\else
          \vspace{0.4cm}
          \orcidlogo\ \href{https://orcid.org/\@orcid}{\footnotesize\rmfamily\@orcid}\\[0.5ex]
        \fi
        \ifx\@email\@empty\else
          {\small\rmfamily\textit{\@email}}\\[0.5ex]
        \fi
      \end{center}
      
      \vfill
      
      \noindent
      \begin{minipage}[b]{0.52\textwidth}
        \ifx\@referencias\@empty\else
          \vspace*{0pt}%
          {\small\rmfamily\scshape\coverrefname:}\\[0.8ex]%
          {\footnotesize\rmfamily\color{black!80}\@referencias}%
        \fi
      \end{minipage}%
      \hfill
      \begin{minipage}[b]{0.44\textwidth}
        \begin{flushright}
          \ifx\@profesor\@empty\else
            {\small\rmfamily\textit{Profesor:} \@profesor}\\[0.3ex]
          \fi
          \ifx\@asistente\@empty\else
            {\small\rmfamily\textit{Jefe de Prácticas:} \@asistente}\\[0.8ex]
          \fi
          \ifx\@lugar\@empty\else
            {\normalsize\rmfamily\scshape \@lugar}\\[0.3ex]
          \fi
          {\normalsize\rmfamily \@date}\\[0.3ex]
          \ifx\@version\@empty\else
            {\footnotesize\rmfamily\textit{Versión \@version}}
          \fi
        \end{flushright}
      \end{minipage}
      
      \vspace*{1.2cm}
    \end{titlepage}
    \cleardoublepage
  }
\fi

\AtBeginDocument{
  \hypersetup{pdftitle={\texorpdfstring{\shorttitle}{\@title}}, pdfauthor={\texorpdfstring{\shortauthor}{\@author}}, pdfsubject={\@curso}}
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
