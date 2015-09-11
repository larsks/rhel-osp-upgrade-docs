# Upgrade Ceilometer

1. Stop all Ceilometer resources in Pacemaker:

        pcs resource disable openstack-ceilometer-central
        pcs resource disable openstack-ceilometer-api-clone
        pcs resource disable openstack-ceilometer-alarm-evaluator-clone
        pcs resource disable openstack-ceilometer-collector-clone
        pcs resource disable openstack-ceilometer-notification-clone
        pcs resource disable openstack-ceilometer-alarm-notifier-clone
        pcs resource disable ceilometer-delay-clone

1. Wait until the output of `pcs status` shows that the above services
   have stopped running.

1. Upgrade the relevant packages:

        yum upgrade 'openstack-ceilometer*' 'python-ceilometer*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. If you are using the MySQL backend for Ceilometer, [update the Ceilometer database schema](database-upgrade.html).  This step is not necessary of you are using the MongoDB backend.

1. Restart all Ceilometer resources in Pacemaker:

        pcs resource enable ceilometer-delay-clone
        pcs resource enable openstack-ceilometer-alarm-notifier-clone
        pcs resource enable openstack-ceilometer-notification-clone
        pcs resource enable openstack-ceilometer-collector-clone
        pcs resource enable openstack-ceilometer-alarm-evaluator-clone
        pcs resource enable openstack-ceilometer-api-clone
        pcs resource enable openstack-ceilometer-central

1. Wait until the output of `pcs status` shows that the above
   resources are running.
