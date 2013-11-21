# Upgrading Cinder

On your Cinder host:

    openstack-service stop cinder
    yum -d1 -y upgrade \*cinder\*
    openstack-db --service cinder --update
    openstack-service start cinder

