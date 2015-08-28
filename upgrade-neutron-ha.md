# Upgrade Neutron

1. Prevent Pacemaker from triggering the Neutron cleanup scripts:

        pcs resource unmanage neutron-ovs-cleanup-clone
        pcs resource unmanage neutron-netns-cleanup-clone

1. Stop Neutron resources in Pacemaker:

        pcs resource disable neutron-server-clone
        pcs resource disable neutron-openvswitch-agent-clone
        pcs resource disable neutron-dhcp-agent-clone
        pcs resource disable neutron-l3-agent-clone
        pcs resource disable neutron-metadata-agent-clone

1. Upgrade the relevant packages:

        yum upgrade 'openstack-neutron*' 'python-neutron*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Update the Neutron database schema](database-upgrades.html)

1. [Update the Neutron rootwrap configuration](config-neutron.html)

1. Restart Neutron resources in Pacemaker:

        pcs resource enable neutron-metadata-agent-clone
        pcs resource enable neutron-l3-agent-clone
        pcs resource enable neutron-dhcp-agent-clone
        pcs resource enable neutron-openvswitch-agent-clone
        pcs resource enable neutron-server-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.

