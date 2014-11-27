# latexFromExcel

## Intro: 

The aim of this tool is to be able to incorporate spreadsheet
information into LaTeX in a flexible manner.

Current tools exists with similar aims
  + [**Excel2LaTeX** a macro in Excel to output the spreadsheet in LaTeX
    format](http://www.ctan.org/tex-archive/support/excel2latex/)
  + [**exceltex.sty** a LaTeX style (in conjunction with a script) that will take part of
    a spreadsheet and insert it into a LaTeX document.](http://www.physik.uni-freiburg.de/~doerr/exceltex/index.en.html)

The goal here, however, is do be able to do the latter, but a little
more flexibly. For instance, we might want to extract columns A, B and
C from the spreadsheet, and output them in the form of rows of a LaTeX
table such as
```
    B~\cite{A} & {\bf C} \\
```

Or we might want to output the rows into some other structure (not a
table). 

Also, while exceltex provides for including formatting from the
spreadsheet, our approach specifies that formatting will be defined in
the LaTeX document.

## Installation: 

This is just a Perl script, so copy it into a location that is in your
path. 

It does require a few packages that can be installed from CPAN. The
required packages are:
  + [Spreadsheet::Read](http://search.cpan.org/~hmbrand/Spreadsheet-Read/Read.pm)
  (which needs a couple of others -- see CPAN)
  + [Data::Printer](http://search.cpan.org/~garu/Data-Printer-0.35/lib/Data/Printer.pm) 
  (which is only really used for debugging at the moment)
  + [Getopt::Long](http://search.cpan.org/~jv/Getopt-Long-2.42/lib/Getopt/Long.pm)

## Instructions: 

There are three parts of using this:
  1. Include a command in the *comments* of a .tex file. This
     instructs excel2latex what to use to construct the table.
  2. A call to the script (which needs perl plus some packages).
  3. An include to pull in the resulting table.

In detail, the first step is to include (in LaTeX comments, anywhere
in the .tex file) a command
```
      % latexFromExcel{<ExcelFile>}{<TableFile>}{<SheetNumber>}{<ROWS>}{<FORMAT>}
```
The command will be parsed by the script (when run) which will read
the `<ExcelFile>` and output the results into `<TableFile>`.  The
sheetnumber refers to the sheet of the Excel file to be read (only one
sheet can be referred to). 

The `<ROWS>` allows you to specify a single range of rows in the
following forms:
 + `4-7`: use rows 4 through 6
 + `3-*`: use rows 3 through to the last row on the sheet
 + `*-7`: use row 1 through to row 7 (NB: at the moment it doesn't
          check for the start row, so this is just equivalent to 1-7)
Eventually the plan is to allow `-n` syntax to specify how far from
the end to allow, and to allow * to specify all rows.

The `<FORMAT>` command allows a flexible specification of how each
column will be pulled into the file. The main part of this should just
be standard LaTeX, but terms such as `{!B}` will be replaced by the
cells `Bi` from the spreadsheet.

A call to the script will parse each such command and generate output
files (which will just be rows of LaTeX in the form above). A typical
call would be
```
	latexFromExcel.pl --file <LaTeXfile> -F <FilterFile>
```
The `<LaTeXfile>` is just the LaTeX file containing the embedded
command. The `<FilterFile>` allows you to apply a series of string
replacements operations to the contents of the spreadsheet before it
appears in the LaTeX. The format is just a series of lines (blank
lines and shell comments are ignored) with a Perl regexp then a `|`,
and then the replacement value. For instance
```
# put empty fields instead of '{no}', ignoring case.
{\s*[nN][oO]\s*}|{}

# replace '{yes}' with a checkmark
{\s*[yY][eE][sS]\s*}|{\checkmark}
```

The filters are applied to the LaTeX string, so they alter the LaTeX
output as well as the spreadsheet, e.g.,
```
# Don't bother including empty citations.
\\cite{\s*}|{}
```
Unfortunately there doesn't seem to be an easy way to have
backreferences like `$1` in the replacement string, which slightly
reduces what you can do.

The output from the processing can then be included into the document
using the standard LaTeX `\input{<TableFile>}` command.

## Examples: 

The examples directory contains a more complete set of examples, but
briefly: in the LaTeX you might have something like:
```
    \begin{tabular}{r|ll}
      % latexFromExcel{example.xlsx}{table_header.tex}{1}{2-2}{{\bf {!B}} & {\bf {!C}} & {\bf {!D}} \\}
      \input{table_header.tex}
      \hline
      % latexFromExcel{example.xlsx}{table_body.tex}{1}{3-*}{  \href{!E}{!B} & {!C} & {!D} \\}
      \input{table_body.tex} 
    \end{tabular} 
```

A Makefile is included in the examples directory to run the script
automatically. 







