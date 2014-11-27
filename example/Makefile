#=============================================================================
#
# Copyright 2012 Matthew Roughan <matthew.roughan@adelaide.edu.au>
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#
#=============================================================================
#
#
# NB: this is called gMakefile to allow R to install without hindrance
#     call this e.g., by make -f gMakefile
#

BIBTEX = bibtex -min-crossrefs=50 
LATEX  = pdflatex -interaction=nonstopmode -halt-on-error -synctex=1 -shell-escape
LATEXFROMEXCEL = latexFromExcel.pl

SRCFILES := $(shell ls *.tex)
SRC = example.tex
ROOT = $(SRC:.tex=)
PDF = $(SRC:.tex=.pdf)

# rules for latex
$(PDF): %.pdf: %.tex FORCE
	${LATEXFROMEXCEL} --file $< -F filters.txt
	${LATEX} $< 
	${LATEX} $< 

# cause latex to run every time I type make
FORCE:

# standard cleanup etc
.PHONY : clean
clean: 
	- $(RM) *.dvi *.out *.log *.aux *.ps *.idx *.lof *.ind *.blg *.toc *.ilg *~

.PHONY : distclean
distclean: 
	- $(RM) *.dvi *.out *.log *.aux *.ps *.idx *.lof *.ind *.blg *.toc *.ilg *~ *.bbl *.bib *.pdf


