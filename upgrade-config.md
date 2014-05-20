Important configuration changes
===============================

While it is always important to review new configuration files
(`*.rpmnew`) installed by upgraded packages, there are a few changes
between RHEL-OSP 4 and RHEL-OSP 5 that deserve special mention.

Neutron/Nova Notifications
--------------------------

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

When merging the new configuration into your existing `neutron.conf`
you will need to uncomment and correctly configure:

- `nova_url` -- the URL for your Nova API
- `nova_admin_username` -- Typically `nova`
- `nova_admin_tenant_id` -- Typically the UUID of the `services`
  tenant
- `nova_admin_password` -- Password for the `nova` user
- `nova_admin_auth_url` -- URL for your Keystone API

Deprecated configuration options
--------------------------------

The `DEFAULT/libvirt_vif_driver` and `libvirt/vif_driver`
configuration options are deprecated in the Icehouse release and will
be removed in subsequent releases.  If you have either of these
options set to something other than
`nova.virt.libvirt.vif.LibvirtGenericVIFDriver` you will see warnings
in your logs when running Nova.

You should remove these options from your `nova.conf` file.

