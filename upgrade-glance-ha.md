# Upgrade Glance

1. Stop the Glance resources in Pacemaker:

        pcs resource disable glance-registry-clone
        pcs resource disable glance-api-clone

1. Wait until the output of `pcs status` shows that both services have
   stopped running.

1. Upgrade the relevant packages:

        yum upgrade 'openstack-glance*' 'python-glance*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Update the Glance database schema](database-upgrades.html)

1. Restart Glance resources in Pacemaker:

        pcs resource enable glance-api-clone
        pcs resource enable glance-registry-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
