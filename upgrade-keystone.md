# Upgrading Keystone

On your Keystone server:

    openstack-service stop keystone
    yum -d1 -y upgrade \*keystone\*
    openstack-db --service keystone --update
    openstack-service start keystone

