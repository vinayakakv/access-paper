FILES = paper.md
templatedir = templates
classdir = classes
images = images
authorImages = authorImages
csldir = csl
FLAGS = -f markdown+yaml_metadata_block+smart+abbreviations\
		--lua-filter image.lua \
		--filter pandoc-xnos \
		--template=$(templatedir)/ieee-access-template.tex \
		--resource-path=$(classdir):$(images): \
		--natbib \
                --bibliography=refs.bib \
		-t latex \
		-s

all: pandoc latex

pandoc: 
	pandoc $(FILES) $(FLAGS) > build/paper.tex
	sed -i 's/\\cite[t,p]{/\\cite{/g' build/paper.tex

latex:
	cp $(authorImages)/* build/
	cp refs.bib build/refs.bib
	-export TEXINPUTS=$(classdir): ; pdflatex -shell-escape -output-directory build -interaction=nonstopmode build/paper.tex
	-cd build; bibtex paper

clean:
	rm -r build/*
