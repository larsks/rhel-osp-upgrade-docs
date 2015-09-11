# Upgrade Heat

1. Stop Heat resources in Pacemaker:

        pcs resource disable heat-api-clone
        pcs resource disable heat-api-cfn-clone
        pcs resource disable heat-api-cloudwatch-clone
        pcs resource disable heat

1. Wait until the output of `pcs status` shows that the above services have
   stopped running.

1. Upgrade the relevant packages:

        yum upgrade 'openstack-heat*' 'python-heat*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Update the Heat database schema](database-upgrades.html)

1. Restart Heat resources in Pacemaker:

        pcs resource enable heat
        pcs resource enable heat-api-cloudwatch-clone
        pcs resource enable heat-api-cfn-clone
        pcs resource enable heat-api-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
