MARKDOWN = markdown_py 

MDDOCS= \
	database-upgrades.md \
	overview.md \
	quantum-to-neutron.md \
	service.md \
	upgrade-1.md \
	upgrade-2.md \
	upgrade-3.md \
	upgrade-cinder.md \
	upgrade-glance.md \
	upgrade-horizon.md \
	upgrade-keystone.md \
	upgrade-nova.md \
	upgrade-quantum.md \
	upgrade-swift.md \
	parallel-nova.md

HTMLDOCS= $(MDDOCS:.md=.html)

%.1.html: %.md
	$(MARKDOWN) $< > $@ || rm -f $@

%.2.html: %.1.html
	(echo '<html>'; cat $<; echo '</html>') > $@

%.html: %.2.html
	title="$(shell xmllint --xpath '//h1/text()' $<)"; \
	( \
		sed "s/TITLE/$$title/g" head; \
		cat $<; \
		cat foot; \
	) > $@

all: $(HTMLDOCS)

clean:
	rm -f $(HTMLDOCS)

