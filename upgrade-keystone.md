# Upgrading Keystone

Because Keystone in Grizzly never purged expired tokens it is possible
that your token table has a large number of expired entries.  This can
dramatically increase the time it takes to complete the database
schema upgrade.

You can alleviate this problem by running the following command before
beginning the Keystone upgrade process:

    keystone-manage token_flush

This will flush expired tokens from the database.

On your Keystone server:

    openstack-service stop keystone
    yum -d1 -y upgrade \*keystone\*
    openstack-db --service keystone --update
    openstack-service start keystone

