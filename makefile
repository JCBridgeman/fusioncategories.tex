# Define the makefile targets

package = fusioncategories

DOC_FILES = $(package).pdf

TEST_FILES = test_fusioncategories.pdf

ADDITIONAL_EXPL = '\\bool_if:NT' '\\cs:w' '\\cs_if_exist_use:NF' '\\int_if_zero:nF' '\\dim_compare:nNnT' '\\str_if_empty:nF'

all: cleantargets $(DOC_FILES) $(TEST_FILES) DoNotIndex clean
X: cleantargets clean $(DOC_FILES)

%.pdf : %.dtx
	@echo "\n\n"
	@echo "Compiling $<"
	@echo "===================="
	$(COMPILE_PDF)
	@echo "\n\n"

%.pdf : %.tex
	@echo "\n\n"
	@echo "Compiling $<"
	@echo "===================="
	$(COMPILE_PDF)
	@echo "\n\n"

clean:
	rm -f *.aux *.log *.out *.idx *.ilg *.ind *.toc *.lof *.lot *.glo *.hd *.gls *.bak *.cng *.comments *.todo *.bcf *.run.xml *.bbl *.bbg *.blg

cleantargets:
	rm -f *.ins *.cls *.sty *.pdf matches_*.txt

DoNotIndex:
	@echo "Extracting list of indexed commands that should not be indexed"
	
	@perl -ne 'm/!\\verb\*&(.*?)&\}/ && print "$$1\n"' fusioncategories.idx > matches.txt
	@perl -ne 'm/^!([^&]*)$$/ && print "$$1\n"' matches.txt > matches2.txt
	@sed '/\\cs:w/d' matches2.txt > matches.txt
	@sort -u matches.txt > matches_classic.txt
	@perl -ne 'm/!\\verb\*&(.*?)&\}/ && print "$$1\n"' fusioncategories.idx > matches.txt
	@# @perl -ne 'm/^!\\([^l])(.*)/ && print "\\$$1$$2\n"' matches.txt > matches2.txt
	@sed -nr 's/(\\verb|&|!|\*)//pg' matches.txt > matches2.txt
	@sed -nr 's/\\\_/_/pg' matches2.txt > matches.txt
	@for i in $(ADDITIONAL_EXPL); do echo $$i >> matches.txt; done
	@sort -u matches.txt > matches_expl.txt
	@rm matches.txt matches2.txt


.PHONY: all cleanx

define COMPILE_PDF =
	pdflatex $<
	@[ -f $(notdir $(basename $@)).glo ] && makeindex -s gglo.ist -o $(notdir $(basename $@)).gls $(notdir $(basename $@)).glo || echo not indexing
	@[ -f $(notdir $(basename $@)).idx ] && makeindex -s gind.ist -o $(notdir $(basename $@)).ind $(notdir $(basename $@)).idx || echo not indexing
	@[ -f $(notdir $(basename $@)).bcf ] && echo "Compiling bibliography" && biber $(notdir $(basename $@)) || echo not compiling bibliography
	@pdflatex -interaction=batchmode $<
	@pdflatex -interaction=batchmode $<
	@unset TEXMFHOME;
endef
