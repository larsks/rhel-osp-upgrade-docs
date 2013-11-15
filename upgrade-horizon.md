# Upgrading Horizon

On your Horizon host:

    yum upgrade \*horizon\* \*openstack-dashboard\*

## Fixing local_settings

The Horizon configuration file
(`/etc/openstack-dashboard/local_settings`) has changed
substantially between versions, so you will need to:

- Back up your existing `local_settings` file.
- Replace `local_settings` with `local_settings.rpmnew`
- Update your new `local_settings` file with any necessary
 information from your old configuration (such as `SECRET_KEY`,
 `OPENSTACK_HOST`, etc).

If you are running Django 1.5 (or later), you will need to make
sure that there is a correctly configured `ALLOWED_HOSTS` setting
in your `local_settings` file.  You can read more about this setting
in the [Django documentation][allowed_hosts].

[allowed_hosts]: https://docs.djangoproject.com/en/1.5/ref/settings/#allowed-hosts

