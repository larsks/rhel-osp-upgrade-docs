MARKDOWN = marked

MDDOCS= \
	config-keystone.md \
	config-neutron.md \
	config-nova.md \
	config-upgrade.md \
	config-horizon.md \
	database-keystone.md \
	database-nova.md \
	database-upgrade.md \
	final-package-upgrade.md \
	overview.md \
	post-upgrade.md \
	pre-upgrade.md \
	service.md \
	upgrade-1.md \
	upgrade-2-ha.md \
	upgrade-2.md \
	upgrade-ceilometer-ha.md \
	upgrade-cinder-ha.md \
	upgrade-compute.md \
	upgrade-glance-ha.md \
	upgrade-heat-ha.md \
	upgrade-horizon-ha.md \
	upgrade-keystone-ha.md \
	upgrade-mariadb-ha.md \
	upgrade-mongodb-ha.md \
	upgrade-neutron-ha.md \
	upgrade-neutron.md \
	upgrade-nova-ha.md \
	upgrade-nova.md

HTMLDOCS= $(MDDOCS:.md=.html)

%.1.html: %.md
	$(MARKDOWN) $< > $@ || rm -f $@

%.2.html: %.1.html
	(echo '<html>'; cat $<; echo '</html>') > $@

%.html: %.2.html
	title="$(shell xmllint --xpath '//h1/text()' $<)"; \
	( \
		sed "s|TITLE|$$title|g" head; \
		cat $<; \
		cat foot; \
	) > $@

all: $(HTMLDOCS)

clean:
	rm -f $(HTMLDOCS)

$(HTMLDOCS): head foot

