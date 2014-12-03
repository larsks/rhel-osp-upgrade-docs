# Upgrading Neutron

The following steps assume that you are running `neutron-server` on
your controller(s) along with other control services.  If you are
running `neutron-server` on a separate network host, you will need to
run the database schema upgrade on that server instead.

1. On your Neutron network hosts, compute nodes, and controller:

        openstack-service stop neutron
        yum upgrade \*neutron\*

1. On your controller:

      openstack-db --service neutron --update

1. On your Neutron network host, compute nodes, and controller:

        openstack-service start neutron

