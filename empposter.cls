% empposter.cls

% --- Class structure: identification part
\ProvidesClass{empposter}[2023/06/12 version 1.0 Clean academic poster template]
\NeedsTeXFormat{LaTeX2e}

\DeclareOption*{%
    \PassOptionsToClass{\CurrentOption}{article}%
}

% --- Class structure: execution of options part
\ProcessOptions \relax

% --- Class structure: declaration of options part
\LoadClass{article}

% Font selection; Domitian is roughly equivalent to Paladino
% https://tug.org/FontCatalogue/domitian/
\RequirePackage{mathpazo}
\RequirePackage{domitian}
\let\oldstylenums\oldstyle

% Page setup; 3ft by 4ft with 0.5in margins on all sides
% TODO: This could be a class option, rather than hardcoded here
\RequirePackage[margin=0.5in, paperwidth=36in, paperheight=48in]{geometry}

% Remove any and all page headers or footers
\RequirePackage{fancyhdr}
\fancyhf{}
\AtBeginDocument{\pagestyle{fancy}}

% XXX: xcolor should be loaded before qrcode to avoid option clash
\RequirePackage[dvipsnames]{xcolor}

% Column utilities
\RequirePackage{paracol}

% Graphics/images utilities
\RequirePackage{graphicx}

% Access to QR code generation; no hyperlinks for print, version 3 QR
% (this is increased as needed, but 3 looks nice at this size), and
% no extra space
\RequirePackage[nolinks]{qrcode}
\qrset{version=3, tight}

% Bibliography elements; remove hyperlink decoration for print, and don't
% attempt to set up heading bookmarks like in a traditional document
\RequirePackage{natbib}
\RequirePackage[hidelinks,hypertexnames=false]{hyperref}

% Spacing settings; remove default spacings whenever possible
\setlength{\bibsep}{0pt}
\setlength{\fboxsep}{0pt}
\setlength{\fboxrule}{0pt}
\setlength{\parindent}{0pt}
\setlength{\columnsep}{0pt}
\setlength{\tabcolsep}{0pt}
\renewcommand{\arraystretch}{1}
\renewcommand{\headrulewidth}{0pt}

% Internal class utilities
\RequirePackage{calc}       % Calculate with standard arithmetic operators
\RequirePackage{environ}    % Easily develop new environments
\RequirePackage{xkeyval}    % Process and store keyword arguments
\RequirePackage{etoolbox}   % Utilities for control sequence names, and more
\RequirePackage{adjustbox}  % Modify boxes

\makeatletter

% Simple macro for initializing the standard set of keys for a particular
% posterbox environment. The only argument is the name of the variant,
% which is prepended to each key variable
\newcommand{\@setupkeys}[1]{%
    \define@key{#1}{color}{\@namedef{@#1@color}{##1}}%
    \define@key{#1}{width}{\@namedef{@#1@width}{##1}}%
    \define@key{#1}{marginleft}{\@namedef{@#1@marginleft}{##1}}%
    \define@key{#1}{marginright}{\@namedef{@#1@marginright}{##1}}%
    \define@key{#1}{margintop}{\@namedef{@#1@margintop}{##1}}%
    \define@key{#1}{marginbottom}{\@namedef{@#1@marginbottom}{##1}}%
    \define@key{#1}{paddingleft}{\@namedef{@#1@paddingleft}{##1}}%
    \define@key{#1}{paddingright}{\@namedef{@#1@paddingright}{##1}}%
    \define@key{#1}{paddingtop}{\@namedef{@#1@paddingtop}{##1}}%
    \define@key{#1}{paddingbottom}{\@namedef{@#1@paddingbottom}{##1}}%
    \define@key{#1}{bordercolor}{\@namedef{@#1@bordercolor}{##1}}%
    \define@key{#1}{borderwidth}{\@namedef{@#1@borderwidth}{##1}}%
    \define@key{#1}{valign}{\@namedef{@#1@valign}{##1}}%
    \define@key{#1}{scale}{\@namedef{@#1@scale}{##1}}%
}

% Primary command provided by this class. Creates a new environment with the
% name given by the required argument. Additional posterbox option overrides
% are given in the first argument, enclosed by curly braces (may be fixed in
% the future).
\DeclareRobustCommand{\custombox}[2][{}]{%
    \@setupkeys{#2}%
    \NewEnviron{#2}[1][{}]{%
        % Default posterbox settings
        \setkeys{#2}{%
            color=white, %
            width=\linewidth, %
            marginleft=0pt, %
            marginright=0pt, %
            margintop=0pt, %
            marginbottom=0pt, %
            paddingleft=1em, %
            paddingright=1em, %
            paddingtop=1em, %
            paddingbottom=1em, %
            bordercolor=white, %
            borderwidth=0pt, %
            valign=t, %
            scale=0.4, %
        }{}%
        % Override settings with environment-specific ones
        \setkeys{#2}{#1}%
        % Override settings with instance-specific ones
        \setkeys{#2}{##1}%
        % Outer minipage encompasses the whole box, including margins, border,
        % paddings, and content
        \begin{minipage}[t]{\@nameuse{@#2@width}}%
            % Left and top margins as explicit space
            \vspace*{\@nameuse{@#2@margintop}}%
            \hspace{\@nameuse{@#2@marginleft}}%
            % XXX: Does this need to be a colorbox?
            \colorbox{\@nameuse{@#2@color}}{%
                % Next minipage holds the border box and inner box with
                % all the box contents
                \begin{minipage}[t]{\linewidth-\@nameuse{@#2@marginleft}-\@nameuse{@#2@marginright}}%
                    \begingroup%
                    \setlength{\fboxrule}{\@nameuse{@#2@borderwidth}}%
                    % Box with optional colored border and background
                    \fcolorbox{\@nameuse{@#2@bordercolor}}{\@nameuse{@#2@color}}{%
                        % Next minipage holds the content interior to the border,
                        % as well as any paddings
                        \begin{minipage}[t]{\linewidth-2\fboxrule}%
                            % Left and top paddings as explicit space
                            \vspace*{\@nameuse{@#2@paddingtop}}%
                            \hspace{\@nameuse{@#2@paddingleft}}%
                            % Inner minipage holds the box contents, which are
                            % scaled to fit the user's requested size. This is a
                            % workaround for the lack of "big" fonts in standard
                            % LaTeX -- we typeset in the usual document font sizes
                            % and then scale up
                            \begin{minipage}[\@nameuse{@#2@valign}]{\linewidth-\@nameuse{@#2@paddingleft}-\@nameuse{@#2@paddingright}}%
                                \resizebox{\linewidth}{!}{%
                                    \parbox{\@nameuse{@#2@scale}\linewidth}{%
                                        \BODY%
                                    }%
                                }%
                            \end{minipage}%
                            % Bottom and right paddings as explicit space
                            \hspace{\@nameuse{@#2@paddingright}}%
                            \vspace*{\@nameuse{@#2@paddingbottom}}%
                        \end{minipage}}%
                    \endgroup%
                \end{minipage}%
            }%
            % Bottom and right margins as explicit space
            \hspace{\@nameuse{@#2@marginright}}%
            \vspace*{\@nameuse{@#2@marginbottom}}%
        \end{minipage}%
    }%
}

% Set up the default, vanilla posterbox with just default options
\custombox{posterbox}

% Title setter and getter
\def\@title{}
\newcommand{\settitle}[1]{\def\@title{#1}}
\newcommand{\puttitle}{\@title}

% Appends an author to the end of a growing list; the first (optional) argument
% is a "glue" word (usually "and") that can precede the author's name after
% the comma. That option only makes sense for the last author, which the
% class does not attempt to identify, relying on the user to set the option
% if they want to
\newcommand{\addauthor}[2][]{%
    \@ifundefined{@authors}{%
        % No authors yet -- add the specified author only
        \edef\@authors{{#2}}%
    }{%
        % Authors in list already -- add the new one with the optional prefix
        \edef\@authors{\@authors, {#1} {#2}}%
    }%
}

% Injects the author list into the current position in the document
\newcommand{\putauthors}{\@ifundefined{@authors}{}{\@authors}}

% Appends an affiliation to the end of a growing list; the first (optional) argument
% is a "glue" word (usually "and") that can precede the affiliation's name after
% the comma. That option only makes sense for the last affiliation, which the
% class does not attempt to identify, relying on the user to set the option
% if they want to
\newcommand{\addaffiliation}[1]{%
    \@ifundefined{@affiliations}{%
        \edef\@affiliations{{#1}}%
    }{%
        \edef\@affiliations{\@affiliations \\ {#1}}%
    }%
}

% Injects the affiliation list into the current position in the document
\newcommand{\putaffiliations}{\@ifundefined{@affiliations}{}{\@affiliations}}

% If authors are given, injects the appropriate amount of vertical space between
% title and authors
\newcommand{\putauthorspace}{%
    \makeatletter%
    \@ifundefined{@authors}{}{\\[0.5em]}%
    \makeatother%
}

% If affiliations are given, injects the appropriate amount of vertical space between
% title/authors and affiliations
\newcommand{\putaffilspace}{%
    \makeatletter%
    \@ifundefined{@affiliations}{}{\\[0.5em]}%
    \makeatother%
}

% Redefine the `enumerate` environment to remove vertical whitespace before and
% after, since the class manages whitespace itself
\let\@oldenumerate\enumerate
\let\@oldendenumerate\endenumerate
\def\enumerate{\begingroup \vspace*{-\topsep} \@oldenumerate}
\def\endenumerate{\@oldendenumerate \vspace*{-\topsep} \endgroup}

% Redefine the `itemize` environment to remove vertical whitespace before and
% after, since the class manages whitespace itself
\let\@olditemize\itemize
\let\@oldenditemize\enditemize
\def\itemize{\begingroup \vspace*{-\topsep} \@olditemize}
\def\enditemize{\@oldenditemize \vspace*{-\topsep} \endgroup}

% Utility for making an image into a bullet; use like:
%   \item[\bulletify{something.eps}] Item text here...
\newcommand{\bulletify}[2][{}]{%
    \adjustbox{valign=c}{\includegraphics[height=1em, #1]{#2}}%
}

% Traditional title, authors, affiliations block; logos can be done manually. The
% optional argument is options controlling the base posterbox for this block
\newcommand{\titlebox}[1][]{%
    \begin{posterbox}[#1]
        \centering%
        \Huge\puttitle%
        \putauthorspace\Large\putauthors%
        \putaffilspace\large\putaffiliations%
    \end{posterbox}
}

% Redefine the `bibliography` command to remove the vertical whitespace and
% the title. XXX: Since itemize/enumerate are already modified, is the whitespace
% adjustment necessary?
\let\@oldbibliography\bibliography
\def\bibliography #1{%
    \begingroup%
    \vspace*{-\topsep}%
    \renewcommand{\section}[2]{}%
    \@oldbibliography{#1}%
    \endgroup%
}

\makeatother

% vim: set ft=tex:
