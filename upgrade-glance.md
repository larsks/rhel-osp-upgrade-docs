# Upgrading Glance

On your Glance server:

    openstack-service stop glance
    yum -d1 -y upgrade \*glance\*
    openstack-db --service glance --update
    openstack-service start glance

