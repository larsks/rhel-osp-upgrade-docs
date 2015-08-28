# Nova database upgrades

## Flavor data migration

The upstream [Nova upgrade notes][2] suggest that:

> After fully upgrading to kilo (i.e. all nodes are running kilo
> code), you should start a background migration of flavor information
> from its old home to its new home. Kilo conductor nodes will do this
> on the fly when necessary, but the rest of the idle data needs to be
> migrated in the the background. This is critical to complete before
> the Liberty release, where support for the old location will be
> dropped. Use "nova-manage db migrate_flavor_data" to perform this
> transition.

You should run this command as the `nova` user:

    runuser -u nova -- nova-manage db migrate_flavor_data

[1]: https://wiki.openstack.org/wiki/ReleaseNotes/Kilo#Upgrade_Notes_2

