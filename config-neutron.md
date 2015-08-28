# Neutron configuration changes

## dnsmasq rootwrap filter

The `rootwrap` filter for the Neutron dhcp agent needs updating in
Kilo.  In `/usr/share/neutron/rootwrap/dhcp.filters`, replace any
lines starting with `dnsmasq:`, for example:

    dnsmasq: EnvFilter, env, root, CONFIG_FILE=, NETWORK_ID=, dnsmasq

With:

    dnsmasq: CommandFilter, dnsmasq, root

[2]: https://wiki.openstack.org/wiki/ReleaseNotes/Kilo#Upgrade_Notes_6

