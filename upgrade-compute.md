# Upgrade compute hosts

On each compute host:

1. Stop all OpenStack services on the host:

        openstack-service stop

1. Upgrade all packages:

        yum upgrade

1. If you wish to perform a rolling upgrade of your compute servers,
   [set Nova API version limits](config-nova.md#add) to allow your
   Juno compute hosts to inter-operate with your Kilo compute hosts
   and controllers.

1. Start all openstack services on the host:

        openstack-service start

When you have upgraded all of your compute hosts, [remove the API
limits](config-nova.md#remove) on both your compute hosts and on your controllers.

