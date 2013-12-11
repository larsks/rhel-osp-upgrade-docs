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
in your `local_settings` file.  `ALLOWED_HOSTS` is a list hostnames
that can be used to contact your Horizon service; if people will be
accessing Horizon as "http://dashboard.example.com", you would set:

    ALLOWED_HOSTS=['dashboard.example.com']

If you are running Horizon on your local system, you might want:

    ALLOWED_HOSTS=['localhost']

If people will be using ip addresses instead of (or in addition to)
hostnames, you could do something like:

    ALLOWED_HOSTS=['dashboard.example.com', '192.168.122.200']

You can read more about the `ALLOWED_HOSTS` setting in the [Django
documentation][allowed_hosts].

[allowed_hosts]: https://docs.djangoproject.com/en/1.5/ref/settings/#allowed-hosts

