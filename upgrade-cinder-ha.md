# Upgrade Cinder

1. Stop all Cinder resources in Pacemaker:

        pcs resource disable cinder-api-clone
        pcs resource disable cinder-scheduler-clone
        pcs resource disable cinder-volume

1. Wait until the output of `pcs status` shows that the above services
   have stopped running.

1. Upgrade the relevant packages:

        yum upgrade 'openstack-cinder*' 'python-cinder*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Update the Cinder database schema](database-upgrades.html)

1. Restart all Cinder resources in Pacemaker:

        pcs resource enable cinder-volume
        pcs resource enable cinder-scheduler-clone
        pcs resource enable cinder-api-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
