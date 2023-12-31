\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{zett}[Zettelkasten class]

\LoadClass[article,10pt,twocolumn]{memoir}

\RequirePackage{amsthm,amssymb,amsmath,stmaryrd,mathrsfs}
\RequirePackage[T1]{fontenc}
\RequirePackage{xcolor}
\definecolor{darkgreen}{rgb}{0,0.45,0} 
\RequirePackage[pagebackref,colorlinks,citecolor=darkgreen,linkcolor=darkgreen]{hyperref}
\RequirePackage{libertine}
\RequirePackage{zi4}
\RequirePackage[capitalise]{cleveref}

\counterwithout{section}{chapter}
\setsecnumdepth{subsection}
\setsecnumformat{\csname the#1\endcsname.\ \ }

\setsecheadstyle{\bfseries}
\setsubsecheadstyle{\bfseries}
\setsubsubsecheadstyle{\bfseries}
\setparaheadstyle{\bfseries}
\setsubparaheadstyle{\bfseries}


\pretitle{\begin{center}\LARGE\bfseries\MakeTextUppercase}
\posttitle{\par\end{center}\vskip 0.5em}

\linespread{1.1}

\ExplSyntaxOn

\AtEndPreamble{
  \setlrmarginsandblock{2cm}{*}{1}
  \setulmarginsandblock{2cm}{*}{1}
  \setheaderspaces{*}{\onelineskip}{*}
  \checkandfixthelayout
}

\NewDocumentCommand\ega_thesection{}{\thesection.~}
\NewDocumentCommand\ega_thesubsection{}{\thesubsection.~}
\NewDocumentCommand\ega_thesubsubsection{}{\thesubsubsection.~}


\setsecnumdepth{subsubsection}
\setsecnumformat{\csname ega_the#1\endcsname}
\setsecheadstyle{\normalsize\bfseries\MakeUppercase}
\setsubsecheadstyle{\noindent\normalfont\bfseries}


\appto\mainmatter{
  \setcounter{secnumdepth}{30}
}


\cs_new:Npn \__ega_append_period:c #1 {
  \cs_if_exist:cTF {#1} {
    \cs_set_eq:cc {ega_old_ #1} {#1}
    \cs_set:cpn {#1} ##1 {
      \use:c {ega_old_ #1} [##1]{##1.}
    }
  }{}
}


% \__ega_append_period:c {subsection}
% \__ega_append_period:c {subsubsection}
\__ega_append_period:c {paragraph}
\__ega_append_period:c {subparagraph}

\bool_new:N \dieudonne_include_chapter
\bool_set_false:N \dieudonne_include_chapter

\DeclareOption{chapters}{
  \bool_set_true:N \dieudonne_include_chapter
}


%% Numbered paragraphs
\ProcessOptions\relax

%% Customizable

\newlength\DieudonneNodeIndent
\setlength\DieudonneNodeIndent{0pt}

\NewDocumentCommand\DieudonneInterpunct{}{
  \textperiodcentered
}

\NewDocumentCommand\DieudonneFormatTrail{m}{
  #1
}


\newcounter{node}

\cs_if_exist:cTF {crefformat} {
  \crefformat{node}{
    \textbf{(#2#1#3)}
  }

  \crefmultiformat{node}{\textbf{(#2#1#3)}}{~and~\textbf{(#2#1#3)}}{,~\textbf{(#2#1#3)}}{~and~\textbf{(#2#1#3)}}
  \crefrangeformat{node}{\textbf{(#3#1#4)}~through~\textbf{(#5#2#6)}}

  \crefrangemultiformat{node}{\textbf{(#3#1#4)}~through\textbf{(#5#2#6)}}{~and~\textbf{(#3#1#4)}~through~\textbf{(#5#2#6)}}{,~\textbf{(#3#1#4)}~through~\textbf{(#5#2#6)}}{~and~\textbf{(#3#1#4)}~through~\textbf{(#5#2#6)}}
  \crefname{node}{}{}
} {}

\cs_new:Npn \dieudonne_if_counter_exist:nT #1 #2 {
  \cs_if_exist:cTF {c@#1} {#2} {}
}

\cs_new:Npn \dieudonne_if_counter_exist:nF #1 #2 {
  \cs_if_exist:cTF {c@#1} {} {#2}
}

% To set the counter resets safely in case Dieudonne is used in a class
% where these don't exist.
\cs_new:Npn \dieudonne_counter_within:nn #1 #2 {
  \dieudonne_if_counter_exist:nT {#1} {
    \dieudonne_if_counter_exist:nT {#2} {
      \counterwithin*{#1}{#2}
    }
  }
}

\cs_new:Npn \dieudonne_setup_counters:n #1 {
  \seq_set_split:Nnn \l_tmpa_seq {,} {#1}

  \int_set:Nn \l_tmpa_int {\seq_count:N \l_tmpa_seq}
  \int_do_until:nn {\l_tmpa_int = 0} {
    \int_decr:N \l_tmpa_int
    \seq_pop_right:NN \l_tmpa_seq \l_tmpa_tl

    \tl_set:Nn \l_tmpb_tl {dieudonne_ \l_tmpa_tl _zero}
    \dieudonne_if_counter_exist:nF {\l_tmpb_tl} {
      \newcounter{\l_tmpb_tl}[\l_tmpb_tl]
    }

    \seq_map_inline:Nn \l_tmpa_seq {
      \dieudonne_counter_within:nn {\l_tmpa_tl} {##1}
    }
  }
}

% all counters should be reset when an ancestor is stepped
\dieudonne_setup_counters:n {chapter,section,subsection,subsubsection,paragraph,subparagraph,node,equation}


%% To support "Chapter 0" or "Section 0": in these case we really want to print the 0's,
%% as opposed to the case where there _is_ no first section/chapter/etc.
\NewDocumentCommand\CounterZeroNext{m}{
  \setcounter{#1}{-1}
  \setcounter{dieudonne_#1_zero}{1}
}

\setcounter{secnumdepth}{30}




\cs_new:Npn \dieudonne_fmt_num:nn #1 #2 {
  \if_int_compare:w \value{#2}=0
     \if_int_compare:w \value{dieudonne_#2_zero}=1
       #1{0}
     \fi
  \else
    #1\arabic{#2}
  \fi
}

% Formatting for numbers that will appear in the table of contents
\cs_new:Npn \dieudonne_fmt_num_toc:n #1 {
  \dieudonne_fmt_num:nn {.} {#1}
}

% Formatting for numbers that will not appear in the table of contents
\cs_new:Npn \dieudonne_fmt_num_notoc:n #1 {
  \DieudonneFormatTrail{\dieudonne_fmt_num:nn {\DieudonneInterpunct} {#1}}
}

\DeclareExpandableDocumentCommand\thesection{}{
  \bool_if:NTF \dieudonne_include_chapter {
    \thechapter
    \dieudonne_fmt_num_toc:n {section}
  } {
    \arabic{section}%
  }
}

\DeclareExpandableDocumentCommand\thesubsection{}{
  \thesection
  \dieudonne_fmt_num_toc:n {subsection}
}

\DeclareExpandableDocumentCommand\thesubsubsection{}{
  \thesubsection
  \dieudonne_fmt_num_toc:n {subsubsection}
}

\DeclareExpandableDocumentCommand\theparagraph{}{
  \thesubsubsection
  \dieudonne_fmt_num_toc:n {paragraph}
}

\DeclareExpandableDocumentCommand\thesubparagraph{}{
  \theparagraph
  \dieudonne_fmt_num_toc:n {paragraph}
}


\DeclareExpandableDocumentCommand\thenode{}{
  \thesubparagraph
  \dieudonne_fmt_num_notoc:n {node}
}

\DeclareExpandableDocumentCommand\theequation{}{
  \thenode
  \dieudonne_fmt_num_notoc:n {equation}
}


\NewDocumentEnvironment{node}{o}{
  \refstepcounter{node}
  \noindent
  \IfValueT{#1}{#1}
  \hspace{\DieudonneNodeIndent}\textbf{(\thenode)}\hspace{.3em}
  \ignorespaces
}{
  \par\addvspace{.5\baselineskip}
}

\ExplSyntaxOff


%% theorem environments
\newtheorem{thm}{Theorem}[section]
\newtheorem{lem}[thm]{Lemma}
\newtheorem{cor}[thm]{Corollary}
\newtheorem{prop}[thm]{Proposition}

\theoremstyle{definition}
\newtheorem{notn}[thm]{Notation}
\newtheorem{defn}[thm]{Definition}
\newtheorem{rmk}[thm]{Remark}
\newtheorem{eg}[thm]{Example}