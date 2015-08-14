# Scenario 1: All-at-once upgrade

In this scenario, you will take down all of your OpenStack
services at the same time, and will not bring them back up until the
upgrade process is complete.

On all of your hosts:

1. Install the Kilo yum repository.

1. [Stop all your OpenStack services][stop].

1. Perform a complete upgrade of all packages:

        # yum upgrade

1. Perform any necessary [configuration updates][config] for each of
   your services.

1. Perform [database schema upgrades][dbsync] for each of your services.

1. Review newly installed configuration files.

     The upgraded packages will have installed `.rpmnew` files
     appropriate to the Juno version of the service.  In general,
     the Juno services will run using the configuration files from
     your Icehouse deployment, but you will want to review the
     `.rpmnew` files for any required changes.

     New versions of OpenStack services may deprecate certain
     configuration options.  You should also review your OpenStack
     logs for any deprecation warnings, because these may cause
     problems during a future upgrade.

1. [Start all your OpenStack services][start].

[stop]: service.html#stop
[start]: service.html#start
[config]: config-upgrades.html
[dbsync]: database-upgrades.html
[horizon]: upgrade-horizon.html
[neutron]: upgrade-neutron.html

