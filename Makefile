MARKDOWN = marked

MDDOCS= \
	database-upgrades.md \
	config-upgrades.md \
	overview.md \
	service.md \
	service-ha.md \
	restart-mariadb-ha.md \
	upgrade-1.md \
	upgrade-1-ha.md \
	upgrade-2.md \
	upgrade-3.md \
	upgrade-cinder.md \
	upgrade-glance.md \
	upgrade-horizon.md \
	upgrade-keystone.md \
	upgrade-nova.md \
	upgrade-neutron.md \
	upgrade-swift.md \
	final-package-upgrade.md \
	parallel-nova.md \
	upgrade-4.md \
	neutron-nova-notifications.md \
	qpid-to-rabbitmq.md \
	rhel6-rhel7.md

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

