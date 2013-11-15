# Scenario 2: One service at a time

In this scenario, you upgrade one service at a time.

The procedure for upgrading an OpenStack service generally looks
something like:

1. [Stop the service][stop]:

         # openstack-service stop <service>

1. Upgrade the packages that provide that service:

         # yum upgrade \*<service>\*

1. Update the database schema for that service:

         # <service>-manage db_sync

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
1. [Quantum/Neutron][quantum] (only if you are using Quantum
   networking in your Grizzly environment)
1. [Nova][]
1. [Horizon][]

After you have upgraded each service, you should test to make sure
that the service is functioning properly.  You will also want to
review any new (`*.rpmnew`) configuration files installed by the
upgraded package.

[keystone]: upgrade-keystone.html
[swift]: upgrade-swift.html
[cinder]: upgrade-cinder.html
[glance]: upgrade-glance.html
[quantum]: upgrade-quantum.html
[nova]: upgrade-nova.html
[horizon]: upgrade-horizon.html

## Final package upgrade

After completing all of your service upgrades, you must perform a
complete package upgrade on all of your systems:

    # yum upgrade

This will upgrade the client packages on all of your systems (i.e.,
packages like `python-keystoneclient`, `python-glanceclient`, etc) as
well as generally ensuring that you have the appropriate versions of
all supporting tools.

**NB**: After this upgrade you will need to restart the `nova-compute`
service, which otherwise will encounter errors due to the upgrade of
the Glance client package.

If this results in a new kernel being installed on your systems you
will probably want to schedule a reboot at some point in the future in
order to activate the kernel.

[dbsync]: database-upgrades.html

