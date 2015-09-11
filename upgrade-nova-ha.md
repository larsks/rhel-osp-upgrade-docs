# Upgrade Nova

1. Stop all Nova resources in Pacemaker:

        pcs resource disable openstack-nova-novncproxy-clone
        pcs resource disable openstack-nova-consoleauth-clone
        pcs resource disable openstack-nova-conductor-clone
        pcs resource disable openstack-nova-api-clone
        pcs resource disable openstack-nova-scheduler-clone

1. Wait until the output of `pcs status` shows that the above services
   have stopped running.

1. Upgrade the relevant packages:

        yum upgrade 'openstack-nova*' 'python-nova*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Update the Nova database schema](database-upgrades.html)

1. If you wish to perform a rolling upgrade of your compute servers,
   [set Nova API version limits](config-nova.md#add) to allow your
   Juno compute hosts to inter-operate with your Kilo compute hosts
   and controllers.

1. Restart all Nova resources in Pacemaker:

        pcs resource enable openstack-nova-scheduler-clone
        pcs resource enable openstack-nova-api-clone
        pcs resource enable openstack-nova-conductor-clone
        pcs resource enable openstack-nova-consoleauth-clone
        pcs resource enable openstack-nova-novncproxy-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
