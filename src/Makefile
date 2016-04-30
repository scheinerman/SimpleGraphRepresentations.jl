caravan.pdf: caravan.tex
	./cropper.sh
	pdflatex caravan

.phony: view
view: caravan.pdf
	launch caravan.pdf

.phony: clean
clean:
	rm -rf *aux *log *~ rain*.pdf graph*.pdf *tex auto

.phony: very-clean
very-clean:
	make clean
	rm -f *.pdf
