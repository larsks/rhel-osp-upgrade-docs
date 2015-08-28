# Scenario 2: One service at a time (HA version)

## Pre-upgrade

Perform the necessary [pre-upgrade][] steps.

[pre-upgrade]: pre-upgrade.md

## Service upgrades

Upgrade each of your services.  The following is a reasonable order in
which to perform the upgrades on your controllers:

1. [MariaDB][]
1. [MongoDB][]
1. [Keystone][]
1. [Glance][]
1. [Cinder][]
1. [Heat][]
1. [Ceilometer][]
1. [Nova][]
1. [Neutron][]
1. [Horizon][]

Finally:

1. [Upgrade the compute hosts][compute]

[keystone]: upgrade-keystone-ha.html
[cinder]: upgrade-cinder-ha.html
[glance]: upgrade-glance-ha.html
[neutron]: upgrade-neutron-ha.html
[ceilometer]: upgrade-ceilometer-ha.html
[nova]: upgrade-nova-ha.html
[horizon]: upgrade-horizon-ha.html
[mariadb]: upgrade-mariadb-ha.html
[mongodb]: upgrade-mongodb-ha.html
[heat]: upgrade-heat-ha.html
[compute]: upgrade-compute.html

# Post-upgrade

Perform the necessary [post-upgrade][] steps.

[post-upgrade]: post-upgrade.md

