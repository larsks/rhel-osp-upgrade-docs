MARKDOWN=markdown2 -x code-friendly -x header-ids

MDDOCS=$(wildcard *.md)
HTMLDOCS=$(MDDOCS:.md=.html)

%.html: %.md
	$(MARKDOWN) $< > $@ || rm -f $@

all: $(HTMLDOCS)

clean:
	rm -f $(HTMLDOCS)

