
TARFILE = ../variable-fonts-deposit-$(shell date +'%Y-%m-%d').tar.gz

ifndef Rscript
# For building on my office desktop
Rscript = ~/R/r-devel/BUILD/bin/Rscript
# For building in docker container
## Rscript = /R/bin/Rscript
endif

%.xml: %.cml %.bib
	# Protect HTML special chars in R code chunks
	$(Rscript) -e 't <- readLines("$*.cml"); writeLines(gsub("str>", "strong>", gsub("<rcode([^>]*)>", "<rcode\\1><![CDATA[", gsub("</rcode>", "]]></rcode>", t))), "$*-protected.xml")'
	$(Rscript) toc.R $*-protected.xml
	$(Rscript) bib.R $*-toc.xml
	$(Rscript) foot.R $*-bib.xml

%.Rhtml : %.xml
	# Transform to .Rhtml
	xsltproc knitr.xsl $*.xml > $*.Rhtml

%.html : %.Rhtml
	# Use knitr to produce HTML
	$(Rscript) knit.R $*.Rhtml
	# Check that figures have not changed
	$(Rscript) gdiff.R

docker:
	cp ../../xdvir_0.2-0.tar.gz .
	sudo docker build -t pmur002/variable-fonts-report .
	sudo docker run -e Rscript=/R/bin/Rscript -v "$(shell pwd)":/home/work/ -w /home/work --rm pmur002/variable-fonts-report make variable-fonts.html

web:
	make docker
	cp -r ../variable-fonts-report/* ~/Web/Reports/dvir/variable-fonts/

zip:
	make docker
	tar zcvf $(TARFILE) ./*
