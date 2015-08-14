# Managing OpenStack services

## <a name="stop">Stopping OpenStack services</a>

### In an HA environment

On your controllers:

1. Disable OpenStack services on the compute nodes.  On each compute
   node, run:

         openstack-service stop

1. Disable all Pacemaker managed resources.  You can do this by
   setting the `stop_all_services` property on the cluster.  Run the
   following on a single member of your Pacemaker cluster:

         pcs property set stop_all_resources=true

   Then wait until the output of `pcs status` shows that all resources
   have stopped.

### In a non-HA environment

Run the following command on all of your OpenStack hosts:

    # openstack-service stop

## <a name="start">Starting OpenStack services</a>

### In an HA environment

1. Allow Pacemaker to restart your resources by resetting the
   `stop_all_resources` property.  On a single member of your
   Pacemaker cluster, run:

         pcs property set stop_all_resources=false

    Then wait until the output of `pcs status` shows that all
    resources have started.

1. Restart OpenStack services on the compute nodes.  On each compute
   node, run:

         openstack-service start

### In a non-HA environment

On all of the systems in your OpenStack environment, run:

    # openstack-service start

## A note regarding the openstack-service command

These instructions make use of the `openstack-service` command,
available from the `openstack-utils` package.  After configuring the
appropriate repositories, you can upgrade to the latest version by
running:

    # yum install openstack-utils

