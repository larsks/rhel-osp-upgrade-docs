# Upgrading Swift

On your Swift servers:

    openstack-service stop swift
    yum -d1 -y upgrade \*swift\*
    openstack-service start swift

