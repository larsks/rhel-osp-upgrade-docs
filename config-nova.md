# Nova configuration changes

## API compatibility limits

If you will be performing a rolling upgrade of your compute hosts you
will need to set explicit API version limits to ensure compatibility
between your Juno and Kilo environments.

### <a name="add">Configuring limits</a>

Before starting Kilo controller or compute services, we need to set
the `compute` option in the `upgrade_levels` section of `nova.conf` to
`juno`:

    crudini --set /etc/nova/nova.conf upgrade_levels compute juno

You will need to make this change on your controllers and on your
compute hosts.

You will undo this operation after upgrading all of your compute
hosts to OpenStack Kilo.

### <a name="remove">Removing limits</a>

After you have upgraded all of your hosts to Kilo, you will want to
remove the API limits configured in the previous step.  On all of your
hosts:

    crudini --del /etc/nova/nova.conf upgrade_levels compute

After making the configuration change, you will need to restart your
Nova services.  On your compute hosts, run:

    openstack-service restart nova

And then restart Nova services on your controllers.  In a non-HA
environment, you can simply run the following on all of your
controllers:

    openstack-service restart nova

In a Pacemaker controlled HA environment, you will need to first
unmanage the Nova resources by running `pcs resource unmanage` on one
of your controllers:

    pcs resource unmanage openstack-nova-novncproxy-clone
    pcs resource unmanage openstack-nova-consoleauth-clone
    pcs resource unmanage openstack-nova-conductor-clone
    pcs resource unmanage openstack-nova-api-clone
    pcs resource unmanage openstack-nova-scheduler-clone

Restart the services on *all* controllers:

    openstack-service restart nova

And then return control to Pacemaker:

    pcs resource manage openstack-nova-scheduler-clone
    pcs resource manage openstack-nova-api-clone
    pcs resource manage openstack-nova-conductor-clone
    pcs resource manage openstack-nova-consoleauth-clone
    pcs resource manage openstack-nova-novncproxy-clone

