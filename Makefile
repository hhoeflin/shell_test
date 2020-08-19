.PHONY: bash install

install:
	mkdir -p $(CURDIR)/RLIB && \
	R_LIBS=$(CURDIR)/RLIB Rscript -e 'install.packages("knitr", repos="https://cloud.r-project.org")'

bash:
	cd bash && \
	R_LIBS=$(CURDIR)/RLIB Rscript -e 'knitr::knit("README.Rmd", output="README.md")'

bash_old:
	jupyter nbconvert --to html bash/README.ipynb

