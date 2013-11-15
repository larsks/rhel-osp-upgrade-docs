# Upgrading Glance

On your Glance server:

    openstack-service stop glance
    yum -d1 -y upgrade \*glance\*
    glance-manage db_sync
    openstack-service start glance

