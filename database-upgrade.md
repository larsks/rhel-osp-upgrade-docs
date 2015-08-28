# Database upgrades

You can use the `openstack-db` command to data schema upgrades:

    openstack-db --service <service> --update

For example:

    openstack-db --service keystone --update

This will run the database upgrade command appropriate for that
service.  The `openstack-db` command is part of the `openstack-utils`
package.

There are a few services that require additional database maintenance
as part of the Juno -> Kilo upgrade that is not covered by the
`openstack-db` command:

- [keystone](database-keystone.html)
- [nova](database-nova.html)

