# Upgrading Cinder

On your Cinder host:

    openstack-service stop cinder
    yum -d1 -y upgrade \*cinder\*
    cinder-manage db sync
    openstack-service start cinder

