# Scenario 3: One service at a time with parallel Compute

For most services this scenario is identical to scenario 2, with the
exception of the compute service.  Rather than upgrading your existing
compute nodes as part of this process, you deploy new compute nodes
running the Juno compute service.  You wait for existing workloads
on your Icehouse compute nodes to complete (or migrate them by hand),
and when a Icehouse compute node is no longer hosting any instances you
upgrade the computer service on that node.

1. Follow the procedure for [scenario 2][s2], but stop after completing
   the Horizon upgrade (do not upgrade Nova).

   You will want to run the [final package upgrade][final] on systems that are
   not running Nova services.

   [final]: final-package-upgrade.html

## Deploy the new compute environment

1. [Set up a parallel compute environment][parallel]: install a new
   Nova controller  and compute nodes using the Juno repositories.

     These systems will use a configuration generally identical to that
     on your Icehouse Nova nodes.  They will be making use of the
     same Keystone, Glance, Cinder, etc. services.

[parallel]: parallel-nova.html

## Move instances to the new environment

1. Migrate instances to the Juno compute nodes

     The simplest method for "migrating" an instance is to simply
     stop the instance running in your Icehouse environment and deploy
     a new one on the Juno infrastructure.

     If re-deployment is not an option, you can move instances from
     your Icehouse compute nodes to your Juno compute nodes with
     minimal downtime via the following process:
     
     1. Snapshot the existing instance.
     1. Delete the existing instance.
     1. Boot a new instance on the Juno compute nodes from the
        snapshot.
     1. Allocate and assign any necessary floating addresses

          In a Neutron environment, you should be able to re-assign
          your previously allocated addresses as soon as the instance
          to which they were assigned is shut down.

          In a Nova networking environment, you will need to create
          new floating ip pools identical to those in your Havana
          environment and then explicitly allocate the necessary
          floating ip addresses before assigning them.

          The `nova floating-ip-bulk-create` command can be used to
          allocate explicit addresses.

1. When you are able to move all the instances from one of your
   existing Icehouse compute nodes, you can redeploy that node in your
   Juno compute environment.

1. When you have moved all your compute nodes into the Juno
   environment, you can retire any remaining Icehouse Nova services.

[s2]: upgrade-2.html

