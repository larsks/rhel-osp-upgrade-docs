# Keystone configuration changes

## Token persistence backends

The location of the token persistence backends [has changed in
Kilo][1].  You will need to update the `driver` option in the `token`
section of `keystone.conf`, replacing any instance of
`keystone.token.backends` with `keystone.token.persistence.backends`.

    sed -i 's/keystone.token.backends/keystone.token.persistence.backends/g' \
      /etc/keystone/keystone.conf

[1]: https://wiki.openstack.org/wiki/ReleaseNotes/Kilo#Upgrade_Notes_5


