# Upgrade Keystone

1. Remove Keystone from Pacemaker's control:

        pcs resource unmanage keystone-clone

1. Stop the keystone service by running the following on each of your
   controllers:

        systemctl stop openstack-keystone

1. Upgrade the relevant packages:

        yum upgrade 'openstack-keystone*' 'python-keystone*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Correct the Keystone configuration]config-keystone.html)

1. [Update the Keystone database schema]database-upgrades.html)

1. Restart the service by running the following on each of your
   controllers:

        systemctl start openstack-keystone

1. Return the resource to Pacemaker control:

        pcs resource manage keystone-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
