# Upgrading Keystone

On your Keystone server:

    openstack-service stop keystone
    yum -d1 -y upgrade \*keystone\*
    keystone-manage db_sync
    openstack-service start keystone

