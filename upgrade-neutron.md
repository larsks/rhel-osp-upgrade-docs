# Upgrading Neutron

1. On your Neutron network hosts and compute nodes:

        openstack-service stop neutron
        yum upgrade \*neutron\*

1. On your Neutron network host:

      openstack-db --service neutron --update

1. On your Neutron network host and compute nodes:

        openstack-service start neutron

[notifications]: neutron-nova-notifications.html

## Configuration changes

Neutron is now able to provide active notifications to Nova in
response to requests to configure new interfaces.  This requires
providing Neutron with a set of credentials in
`/etc/neutron/neutron.conf`; if you do not provide these credentials
you will not be able to boot any new servers.

After an upgrade, you will find the following section in
`/etc/neutron/neutron.conf.rpmnew`:

    # ======== neutron nova interactions ==========
    # Send notification to nova when port status is active.
    # notify_nova_on_port_status_changes = True
    # Send notifications to nova when port data (fixed_ips/floatingips) change
    # so nova can update it's cache.
    # notify_nova_on_port_data_changes = True
    # URL for connection to nova (Only supports one nova region currently).
    # nova_url = http://127.0.0.1:8774/v2
    # Name of nova region to use. Useful if keystone manages more than one region
    # nova_region_name =
    # Username for connection to nova in admin context
    # nova_admin_username =
    # The uuid of the admin nova tenant
    # nova_admin_tenant_id =
    # Password for connection to nova in admin context.
    # nova_admin_password =
    # Authorization URL for connection to nova in admin context.
    # nova_admin_auth_url =
    # Number of seconds between sending events to nova if there are any events to send
    # send_events_interval = 2
    # ======== end of neutron nova interactions ==========

When merging the new configuration into your existing `neutron.conf`,
you will need to add the following to the `DEFAULT` section:

    notify_nova_port_status_change=true
    notify_nova_on_port_data_changes=true
    nova_url=http://mynova:8774/v2
    nova_admin_username=myserviceuser
    nova_admin_password=myservicepass
    nova_admin_tenant_id=uuid-of-services-tenant
    nova_admin_auth_url=http://mykeystone:myport/v2.0

Where:

- `mynova` is the address of your Nova API service
- `myserviceuser` and `myservicepass` are a username and password with
  admin privileges in your OpenStack environment (for example, the
  `nova` user).
- `uuid-of-services-tenant` is the UUID of the primary tenant
  associated with `myserviceuser`.

