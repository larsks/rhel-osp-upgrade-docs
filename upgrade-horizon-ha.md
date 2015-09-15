# Upgrade Horizon

1. Stop the Horizon resource in Pacemaker:

        pcs resource disable horizon-clone

1. Wait until the output of `pcs status` shows that the service has
   stopped running.

1. Upgrade the relevant packages:

        yum upgrade httpd 'openstack-dashboard*' \
          'python-django*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. [Correct the Horizon configuration](config-horizon.html)

1. Restart the Horizon resource in Pacemaker:

        pcs resource enable horizon-clone

1. Wait until the output of `pcs status` shows that the above
   resource is running.
