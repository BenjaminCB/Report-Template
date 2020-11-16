\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{aau-report}[2020/11/11 AAU student report]

%
% Document class options
%

% Report mode.
% This will set openany and oneside mode for the book class.
% The same as passing openany and oneside manually.
\DeclareOption{report}{%
	\PassOptionsToClass{openany}{book}
	\PassOptionsToClass{oneside}{book}}


% Option for disabling the title page
\DeclareOption{noprojectpage}{\newcommand\aaur_no_project_page{1}}
\DeclareOption{noprojectinfo}{\newcommand\aaur_no_project_page{1}}
% Pass unknown options to the book class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}


\ProcessOptions\relax

% Loads the base class (book is used for this class)
\LoadClass[a4paper]{book}

% Loading of required packages
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{hyperref}

\RequirePackage{calc}
\RequirePackage{titlesec}
\RequirePackage{lastpage}

\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage[contents={},color=gray]{background}

\RequirePackage{xcolor}
\RequirePackage{xparse}
\RequirePackage{pgfmath}


\definecolor{aaublue}{RGB}{33,26,82}

% Margins
\geometry{textwidth=12.13cm, textheight=20.75cm, marginratio={4:6,5:7}}

%
% Frontmatter
%

%
% Macros for author typesetting
%
\ExplSyntaxOn
\newcounter{@aauc}

% Lists the authors separated by a newline.
\newcommand\authorLList{
	\setcounter{@aauc}{0}
	\clist_map_inline:Nn{\@author}{
		\stepcounter{@aauc}
		\ifnum\clist_count:N{\@author}=\value{@aauc}
			##1 %
		\else
			##1\\%
		\fi
	}
}

% Writes authors as a comma separated list with line breaks whenever
% the current line runs out of space. The main difference between this and
% the \@author_clist command is that the latter requires the end user to select
% how many authors to write per line whereas this one calculates it automatically.
\newcommand\authorAList{
	\newlength{\@authlen}
	\setlength{\@authlen}{\textwidth}
	\newlength{\@namelen}
	
	\def\@setComma{0}
	\pgfmathparse{1}
	
	\clist_map_inline:Nn{\@author}{
		\settowidth{\@namelen}{##1}
		\addtolength{\@authlen}{-\@namelen}

		\pgfmathparse{\@authlen>0?1:0}
		\if 1\pgfmathresult
			\if 1\@setComma
				, ##1
			\else
				##1
				\def\@setComma{1}
			\fi
		\else
			\setlength{\@authlen}{\textwidth}
			\addtolength{\@authlen}{-\@namelen}
			\\##1
		\fi
	}
}

\newcommand\testexpand[1]{
	\widthof{This is a test string}
}

% Separates the comma separated author list into of groups
% of the given size and writes them separated by a line break.
% This is mainly for backwards compatebility as well as being a fallback
% for in case the automatic version for some reason fails to work.
\newcommand\authorCList[1][2]{
	\setcounter{@aauc}{0}
	\pgfmathparse{1}
	
	\clist_map_inline:Nn {\@author}{
		\stepcounter{@aauc}\pgfmathparse{Mod(\value{@aauc},#1)==0?0:1}
		\ifnum\clist_count:N{\@author}=\value{@aauc}
			##1  
		\else
			\if 0\pgfmathresult
				##1 \\
			\else
				##1,\ %
			\fi
		\fi
	}
}

\ExplSyntaxOff

% The below macros will *provide* macros for the project fields. Meaning they will not overwrite existing macros.
\newcommand\subtitle[1]{\providecommand\@subtitle{#1}}		% Macro for setting subtitle
\newcommand\reporttype[1]{\providecommand\@reporttype{#1}}	% Macro for setting report type (Master's project, Bachelor project, Semester project, etc.)
\newcommand\reportfield[1]{\providecommand\@reportfield{#1}}	% Macro for setting the field of study
\newcommand\groupname[1]{\providecommand\@groupname{#1}}	% Macro for setting the group name
\newcommand\projecttheme[1]{\providecommand\@projecttheme{#1}} % Macro for setting the project theme
\newcommand\projectperiod[1]{\providecommand\@projectperiod{#1}} % Macro for setting the project period
\newcommand\supervisor[1]{\providecommand\@supervisor{#1}}	% Macro for setting the supervisor
\renewcommand\author[1]{\renewcommand\@author{#1}}


% Frontpage and project info
\renewcommand\maketitle{%
	% Warnings for missing parameters
	\@ifundefined{@title}{\ClassWarning{aau-report}{Title not provided before maketitle. Use \\title to set title.}}{}
	\@ifundefined{@subtitle}{\ClassWarning{aau-report}{Subtitle not provided before maketitle. Use \\subtitle to set subtitle.}}{}
	\@ifundefined{@reporttype}{\ClassWarning{aau-report}{Report type not provided before maketitle. Use \\reporttype to report type.}}{}
	\@ifundefined{@reportfield}{\ClassWarning{aau-report}{Field of study not provided before maketitle. Use \\reportfield to set field of study.}}{}
	% Actual frontpage
	\pdfbookmark[0]{Front page}{label:frontpage}%
	\begin{titlepage}
	\vspace*{\fill}
	    \backgroundsetup{
	    scale=1.1,
	    angle=0,
	    opacity=1.0,  %% adjust
	    contents={\includegraphics[width=\paperwidth,height=\paperheight]{media/AAUGraphics/aau_waves}}
	    }
	  \addtolength{\hoffset}{0.5\evensidemargin-0.5\oddsidemargin}
	  \noindent%
	  {\color{white}\fboxsep0pt\colorbox{aaublue}{\begin{tabular}{@{}p{\textwidth}@{}}
	    \begin{center}
	    \Huge{\textbf{\@title}}
	    \end{center}
	    \begin{center}
	      \Large{\@subtitle}
	    \end{center}
	    \vspace{0.2cm}
	   \begin{center}
	    {\Large
	      \authorAList % ----------------------------------------------------------
	    }\\
	    \vspace{0.2cm}
	    {\large
	      \@reportfield{}, \@ifundefined{@groupname}{\ClassInfo{aau-report}{No group name provided. Omitting group name on frontpage. Group name can be set using \\groupname.}}{\@groupname{},} \the\year{}-\the\month{}
	    }
	   \end{center}
	   \vspace{0.2cm}
	   \begin{center}
	    {\Large\@reporttype}
	   \end{center}
	  \end{tabular}}}
	  \vfill
	  \begin{center}
	    \includegraphics[width=0.2\paperwidth]{media/AAUGraphics/aau_logo_circle_en}
	  \end{center}
	\end{titlepage}
	\clearpage
	%
	% Project info
	%
	\@ifundefined{aaur_no_project_page}{% TODO print title page
		{%set up various length
		\ifx\titlepageleftcolumnwidth\undefined
		\newlength{\titlepageleftcolumnwidth}
		\newlength{\titlepagerightcolumnwidth}
		\fi
		\setlength{\titlepageleftcolumnwidth}{0.5\textwidth-\tabcolsep}
		\setlength{\titlepagerightcolumnwidth}{\textwidth-2\tabcolsep-\titlepageleftcolumnwidth}
		%create title page
		\thispagestyle{empty}
		\noindent%
		\begin{tabular}{@{}ll@{}}
		 	\parbox{\titlepageleftcolumnwidth}{
			\includegraphics[width=\titlepageleftcolumnwidth]{media/AAUGraphics/aau_logo_en}
			} &
			\parbox{\titlepagerightcolumnwidth}{\raggedleft\sf\small
			\textbf{\@reportfield}\\
			Aalborg University
			\href{http://www.aau.dk}{http://www.aau.dk}
			}\bigskip\\
			\parbox[t]{\titlepageleftcolumnwidth}{
				\textbf{Title:}\\ \@title{}\bigskip\par
				\@ifundefined{@projecttheme}
					{\ClassWarning{aau-report}{Theme not set. Omitting from project info. Use \\projecttheme to set theme.}}
					{\textbf{Theme:}\\ \@projecttheme{}\bigskip\par}
				\@ifundefined{@projectperiod}
					{\ClassWarning{aau-report}{Project period not set. Omitting from project info. Use \\projectperiod to set the project period.}}
					{\textbf{Project Period:}\\ \@projectperiod{}\bigskip\par}
				\@ifundefined{@groupname}
					{\ClassWarning{aau-report}{Group name not set. Omitting from project info. Use \\groupname to set group name.}}
					{\textbf{Project Group:}\\ \@groupname{}\bigskip\par}
				\textbf{Participant(s):}\\ \authorLList \bigskip\par
				\@ifundefined{@supervisor}
					{\ClassWarning{aau-report}{Supervisor not specified. Omitting from project info. Use \\supervisor to set supervisor.}}
					{\textbf{Supervisor(s):}\\ \@supervisor{}\bigskip\par}
				\textbf{Page Numbers:} \pageref{LastPage}\bigskip\par
				\textbf{Date of Completion:}\\ \@date
			} &
			\parbox[t]{\titlepagerightcolumnwidth}{%
			\textbf{Abstract:}\bigskip\par
			\fbox{\parbox{\titlepagerightcolumnwidth-2\fboxsep-2\fboxrule}{%
			Abstract % todo get this from user info
			}}
			}\\
		\end{tabular}
		\vfill
		\noindent{\footnotesize\emph{The content of this report is freely available, but publication (with reference) may only be pursued due to agreement with the author.}}
		\clearpage}}{}}