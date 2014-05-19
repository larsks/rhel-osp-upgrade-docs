# Upgrading Neutron

1. On your Neutron network hosts and compute nodes:

        openstack-service stop neutron
        yum upgrade \*neutron\*

1. On your Neutron network host:

      openstack-db --service neutron --update

1. Update your Neutron configuration to support [Neutron/Nova
  notifications][notifications].

1. On your Neutron network host and compute nodes:

        openstack-service start neutron

[notifications]: neutron-nova-notifications.html

