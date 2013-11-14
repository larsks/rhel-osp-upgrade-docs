<!DOCTYPE html>
<html>
<title>Upgrading RHOS 3.0 to RHOS 4.0</title>

<!--
  ## Comments marked BUG: indicate situations in which the given
  ## instruction will not work as described.  When available
  ## the comment should include the relevant bugzilla link.
  -->

<xmp theme="journal" style="display:none;">
Prerequisites
=============

Upgrade RHEL 6.4 to RHEL 6.5
----------------------------

RHOS 4.0 will not run on RHEL 6.4.  Before beginning the RHOS upgrade
process you must upgrade to RHEL 6.5.

Upgrading from RHOS 3.0 to RHOS 4.0
===================================

Assumptions
-----------

This document assumes that your RHOS 3.0 environment was deployed
using the `packstack` deployment tool and that you have access to
the answers file (`packstack-answers-....txt`) generated by
`packstack`.

Option 1: In place upgrade with service downtime
------------------------------------------------

**Summary**: In this option, you will shut down all of your OpenStack
services, upgrade all of the components, and then bring up the updated
environment in one piece.

**Pros**: This is the simplest upgrade mechanism to implement.

**Cons**: Your OpenStack services will be unavailable for the duration of
the upgrade process.

### On all of your nodes

1. [Shut down your OpenStack services](#shutdown).

### On your compute nodes

1. Enable the RHOS 4.0 software repository.

<!-- BUG: There may be an issue upgrading python-urllib3.
    https://bugzilla.redhat.com/show_bug.cgi?id=1021991
    -->

1. Perform a complete upgrade:

        # yum update

### On your controller nodes

1. If you are using Quantum networking under RHOS 3.0, please follow
   [Neutron pre-upgrade instructions](quantum-to-neutron.html) to
   prepare for the upgrade to Neutron.

1. Enable the RHOS 4.0 software repository.

1. Perform a complete upgrade:

        # yum update

   <!-- BUG: There may be an issue upgrading python-urllib3.
        https://bugzilla.redhat.com/show_bug.cgi?id=1021991
        -->

1. Upgrade your OpenStack databases to the new schemas:

       # nova-manage db sync
       # glance-manage db_sync
       # cinder-manage db sync
       # keystone-manage db_sync

1. If you are using Quantum networking under RHOS 3.0, please follow
   [Neutron post-upgrade instructions](quantum-to-neutron.html) to
   complete the upgrade to Neutron.

1. Upgrade your `packstack` answers file.

  - Replace all references to `QUANTUM` with `NEUTRON`:

         # sed -i 's/CONFIG_QUANTUM/CONFIG_NEUTRON/' $ANSWERFILE

  - Add the following lines to `$ANSWERFILE`:

         CONFIG_MYSQL_INSTALL=y
         CONFIG_CEILOMETER_INSTALL=n
         CONFIG_HEAT_INSTALL=n
         CONFIG_CINDER_BACKEND=lvm
         CONFIG_HEAT_CLOUDWATCH_INSTALL=n
         CONFIG_HEAT_CFN_INSTALL=n
         CONFIG_NOVA_NETWORK_HOSTS=...
         CONFIG_NOVA_NETWORK_MANAGER=nova.network.manager.FlatDHCPManager
         CONFIG_PROVISION_DEMO_FLOATRANGE=172.24.4.224/28

    (These are either defaults assumed by the RHOS 3.0 version of
    `packstack` or new features that were not available under RHOS
    3.0.)

   <!-- BUG: This may also fail due to parsing bugs in the Keystone
        puppet provider provided by the openstack-puppet modules.
        https://bugzilla.redhat.com/show_bug.cgi?id=1022686
        -->

1. Run `packstack` to upgrade your configuration:

       # packstack --answer-file $ANSWERFILE

### On all your nodes

1. Restart your OpenStack services. 

If running `yum update` installed a new kernel package, you will need
to reboot your servers in order to activate the new kernel.  Rebooting
your compute nodes will interrupt any instances currently running on
those nodes.  You can [reboot your instances](#reboot_instance) to
recover from this situation.

Option 2:  Rolling (component-by-component) upgrades
----------------------------------------------------

**Summary**: In this option, you will upgrade components of your OpenStack
environment one at a time.

**Pros**: This will in theory allow you to continue to provide access to
your OpenStack environment throughout much of the upgrade process. For
example, while you are upgrading the Cinder component volume
operations will be unavailable, but the nova api, horizon, keystone,
and other services would still be up.

**Cons**: Some services have more impact than others. Clients will not be
able to authenticate against any of the APIs while your are upgrading
keystone, and clients will not be able to create, destroy, or
otherwise manage instances while you are upgrading nova.

Option 3: Rolling upgrades with a parallel compute region
---------------------------------------------------------

**Summary**: In this option, you will build up a separate pool of compute
nodes, allowing you to minimize downtime to the compute service.

**Pros**: This will allow you to stage upgrades to your compute nodes
in order to avoid interrupting critical workloads, while allowing you
to take advantage of stability and features in the newer OpenStack
release.

**Cons**: In addition to the interruptions identified in 
Option 2, you will also need to have hardware available on which to
deploy your new compute nodes.

### On your controller nodes

Proceed as in step 1.


Notes on controlling OpenStack services
=======================================

OpenStack is a complex system with a large number of components.
Several steps in this document instruct you to shut down or start up
"all your OpenStack services".  Exactly what this means is going to
depend on your individual configuration.

These are some general suggestions for controlling services on a
single node.

<a name="shutdown">Shutting down services</a>
---------------------------------------------

Most OpenStack service names are prefix by `openstack-`, so something
like this will shut down most OpenStack services:

    # cd /etc/init.d
    # for svc in openstack-*; do service $svc stop; done

If you are running `quantum` or `neutron`, you will need to add the
appropriate prefix to your command line, for example:

    # cd /etc/init.d
    # for svc in openstack-* quantum-*; do service $svc stop; done

<a name="starting">Starting services</a>
---------------------------------------------

In simple cases, replacing `stop` with `start` in the previous
instructions will get you what you want.  If the set of services
*installed* on your server is different from the set of services that
should be *running* on your server, then you'll want to be a little
more careful.

You can use the output of `chkconfig --list` to see what services are
enabled on your system.  Assuming a typical system that has booted
into runlevel 3, you could use the following command to to get a list
of enabled service names:

    # chkconfig --list | awk '/(openstack|quantum|neutron).*3:on/ {print $1}'

And you could start these services up with a command line like:

    # chkconfig --list | awk '/(openstack|quantum|neutron).*3:on/ {print $1}' |
      xargs -iSVC service SVC start


<a name="reboot_instance">Restarting instances after a server reboot</a>
========================================================================

If you reboot a nova compute node, any instances running on that node
will stop running and will not be restarted automatically when the
system boots.  When the compute node comes back up, you will find the
instances it was hosting in state `SHUTOFF`:

    $ nova list
    +--------------------------------------+-------+---------+--------------------------+
    | ID                                   | Name  | Status  | Networks                 |
    +--------------------------------------+-------+---------+--------------------------+
    | 2eb35cd5-53bb-4cb0-a35a-d0617fb64975 | test  | SHUTOFF | novanetwork=192.168.32.2 |
    +--------------------------------------+-------+---------+--------------------------+

You can bring these instances back online with the `nova reboot`
command:

    $ nova reboot 2eb35cd5-53bb-4cb0-a35a-d0617fb64975
    $ nova list
    +--------------------------------------+-------+--------+--------------------------+
    | ID                                   | Name  | Status | Networks                 |
    +--------------------------------------+-------+--------+--------------------------+
    | 2eb35cd5-53bb-4cb0-a35a-d0617fb64975 | test  | ACTIVE | novanetwork=192.168.32.2 |
    +--------------------------------------+-------+--------+--------------------------+

</xmp>
<script src="strapdown/v/0.2/strapdown.js"></script>
</html>

<!-- vim: set ft=markdown : -->
