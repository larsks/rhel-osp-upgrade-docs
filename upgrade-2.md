# Scenario 2: One service at a time

In this scenario, you upgrade one service at a time.

The procedure for upgrading an OpenStack service generally looks
something like:

1. [Stop the service][stop]:

         # openstack-service stop <service>

1. Upgrade the packages that provide that service:

         # yum upgrade \*<service>\*

1. Update the database schema for that service:

         # openstack-db --service <service> --update

     See the [Database Upgrades][dbsync] document for the specific
     command used by each individual service to perform the database
     schema upgrade.

1. [Restart the service][start]:

         # openstack-service start <service>

[stop]: service.html#stop
[start]: service.html#start

## Pre-upgrade

On all of your hosts:

1. Install the Havana yum repository.

## Service upgrades

Upgrade each of your services.  The following is a reasonable order in
which to perform the upgrade:

1. [Keystone][]
1. [Swift][]
1. [Cinder][]
1. [Glance][]
1. [Neutron][] (only if you are using Neutron
   networking in your Havana environment)
1. [Horizon][]
1. [Nova][]

After you have upgraded each service, you should test to make sure
that the service is functioning properly.  You will also want to
review any new (`*.rpmnew`) configuration files installed by the
upgraded package.

[keystone]: upgrade-keystone.html
[swift]: upgrade-swift.html
[cinder]: upgrade-cinder.html
[glance]: upgrade-glance.html
[neutron]: upgrade-neutron.html
[nova]: upgrade-nova.html
[horizon]: upgrade-horizon.html

# Post-upgrade

You will want to perform a [final package upgrade][final] to ensure
that all your installed packages are at the latest version.

[final]: final-package-upgrade.html

