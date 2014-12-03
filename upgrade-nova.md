# Upgrading Nova

1. On all hosts running Nova services:

       openstack-service stop nova
       yum -d1 -y upgrade \*nova\*

1. On your Nova API host:

       openstack-db --service nova --update

1. On all your hosts running Nova services:
 
        openstack-service start nova


