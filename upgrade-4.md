# Scenario 4: One service at a time with live Compute upgrade

For most services this scenario is identical to scenario 2, with the
exception of the compute service.  This scenario takes advantage of
the fact that, with appropriate configuration, a `nova-compute`
service from Icehouse can talk to a Juno control plane.

## Upgrade Nova controllers

[s2]: upgrade-2.html
[final]: final-package-upgrade.html

1. Follow the procedure for [scenario 2][s2], but stop after completing
   the Horizon upgrade (do not upgrade Nova).

      You will want to run the [final package upgrade][final] on
      systems that are not running Nova services.

1. Upgrade the Nova controller services.  On each controller node,
   stop the running Nova services:

         openstack-service stop nova

     and upgrade the Nova packages:

         yum -y upgrade \*nova\*

     At this point, you will want to examine any `*.rpmnew` files
     installed by the packages and update your existing configuration
     files appropriately.

1. On one of the controller nodes, run the database upgrade script:

         openstack-db --service nova --update

1. On all the controller nodes, cap the compute and conductor RPC API
   at a version that will still be understood by your Icehouse compute
   nodes.  Look for the `[upgrade_levels]` section in
   `/etc/nova/nova.conf` and set the `compute` option like this:

         [upgrade_levels]
         compute = 3.23.1
         conductor = 3.23.1

1. Restart the controller services.  On each controller node:

         openstack-service start nova

## Upgrade Nova compute nodes

At this point, your controller nodes are all running the Juno
version of Nova and your compute nodes are still running the Icehouse
version.

For each compute node:

1. Mark the `nova-compute` service as disabled to prevent Nova from
   scheduling any new servers on this node:

         nova service-disable --reason upgrade myhost nova-compute

     Where `myhost` is the name of the compute host as it is known to
     Nova.  You can see a list of compute hosts using the `nova
     service-list` command:

         nova service-list --binary nova-compute

1. Stop the `nova-compute` service on the node:

         openstack-service stop nova

1. Upgrade all the Nova packages:

         yum upgrade \*nova\*

1. Restart Nova services:

         openstack-service start nova

1. Re-enable the compute service:

         nova service-enable myhost nova-compute

## Migrating instances

If you need to perform hardware or operating system upgrades on the
compute nodes, you can migrate running instances off the nodes as part
of the upgrade process.

If you will be migrating instances between Icehouse and Juno compute
nodes, you will need to ensure that your Juno nodes have the same
`upgrade_levels` setting as your controllers:

       [upgrade_levels]
       compute = 3.23.1

### Live migration

If you have configured live migration in your environment, you can use
the `nova live-migration` command to move instances to another compute
host with zero downtime:

    nova live-migration myinstance

Where `myinstance` is the name or UUID of a running server.

### Cold migration

If live migration is not available, you can use cold migration to move
instances to another node with minimal downtime:

    nova migrate myinstance

# Post-upgrade tasks

After you have complete the upgrade to all of your Nova compute nodes,
you should remove the RPC API version limit from your Nova
configuration.  In `/etc/nova/nova.conf` on your controllers and
compute nodes, comment out the `compute` setting in the
`upgrade_levels` section:

       [upgrade_levels]
       # compute = icehouse

You will need to restart Nova services on each host where you make
this change:

    openstack-service restart nova

At this point, you should perform a [final package upgrade][final] on
your compute and controller nodes to ensure that all your installed
packages are at the latest version.

