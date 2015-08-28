# Scenario 2: One service at a time (non-HA version)

In this scenario, you upgrade one service at a time.

## Pre-upgrade

Perform the necessary [pre-upgrade][] steps.

[pre-upgrade]: pre-upgrade.md

## Service upgrades

Upgrade each of your services, following the process described above.
The following is a reasonable order in which to perform the upgrade:

1. Keystone
1. Cinder
1. Glance
1. Cinder
1. Heat
1. Ceilometer
1. [Nova][]
1. [Neutron][]
1. Horizon

[nova]: upgrade-nova.html
[neutron]: upgrade-neutron.html

The procedure for upgrading an individual OpenStack service looks like
this:

1. [Stop the service][stop]:

         # openstack-service stop <service>

1. Upgrade the packages that provide that service:

         # yum upgrade \*<service>\*

1. [Update the database schema for that
   service](database-upgrade.html)

1. [Restart the service][start]:

         # openstack-service start <service>

[stop]: service.html#stop
[start]: service.html#start

Some of the above services need additional steps beyond the standard
process described above; follow the links in the list of services to see
these instructions.

# Post-upgrade

Perform the necessary [post-upgrade][] steps.

[post-upgrade]: post-upgrade.md

