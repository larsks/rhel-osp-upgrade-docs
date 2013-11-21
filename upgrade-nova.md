# Upgrading Nova

On all hosts running Nova services:

    openstack-service stop nova
    yum -d1 -y upgrade \*nova\*

On your Nova API host:

    openstack-db --service nova --update

On all your hosts running Nova services:

    openstack-service start nova
 
