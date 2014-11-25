# excel2latex.pl

## Intro: 

the aim is to be able to incorporate spreadsheet information
into LaTeX in a flexible manner.

Tools exists as
  + [**Excel2LaTeX** a macro in Excel to output the spreadsheet in LaTeX
    format](http://www.ctan.org/tex-archive/support/excel2latex/)
  + [**exceltex.sty** a LaTeX style (in conjunction with a script) that will tak part of
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
      % TABLE{<ExcelFile>}{<TableFile}{<SheetNumber>}{<ROWS>}{<FORMAT>}
```
The command will be parsed by the script (when run) which will read
the `<ExcelFile>` and output the results into `<TableFile>`. 

## Examples: 

The examples directory contains a more complete set of examples, but
briefly:







