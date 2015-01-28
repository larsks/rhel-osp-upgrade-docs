# Upgrading from RHEL 6/RHEL-OSP 5 to RHEL 7/RHEL-OSP 6

While RHEL-OSP 5 is supported on RHEL 6, RHEL-OSP 6 is not.  If you
want to upgrade an Icehouse environment running on RHEL 6, you will
first need to bring all of your systems up to RHEL 7 as part of the
upgrade process.

There is no in-place upgrade option when going from RHEL 6 to RHEL 7,
so you will need to completely reinstall all of the components in your
OpenStack environment.  This document suggests one possible strategy
for approaching this ugprade process.

## Requirements

### Application data

All OpenStack application data (MySQL database storage, cinder
volumes, glance images) must not be stored on your root filesystem.
That is, it must be stored either on dedicated local devices or on
filesystems/volumes provided by a remote server.

You must ensure that this data is not erased or overwritten as part of
the RHEL 7 installation.

If the data cannot be preserved across the upgrade, make sure to back
it up first.  A simple solution is to mount an NFS share from another
system and copy the appropriate directories:

    # mkdir -p $BACKUP/var/lib/{glance,nova,mysql}/
    # rsync -a /var/lib/mysql/ $BACKUP/var/lib/mysql/
    # rsync -a /var/lib/glance/ $BACKUP/var/lib/glance/
    # rsync -a /var/lib/nova/ $BACKUP/var/lib/nova/

Here (and in the rest of this document), `$BACKUP` is shorthand for
wherever you have your backup directory mounted.

### Configuration files

Ensure that you have complete backups of your OpenStack configuration
files.  This includes everything in `/etc`, as well as any stored
credentials (for Keystone, MySQL, etc) located in `/root` or other
local user home directories.

### Hostnames and addresses

In order to simplify the ugprade process, these instructions require
that your configure your new RHEL 7 hosts at the same ip address and
hostname as the RHEL 6 hosts you are replacing.  You have a few
options for doing this:

- You can give you RHEL 6 hosts a new IP address so that the original
  address is available for your replacement RHEL 7 hosts.  This
  ensures that you will continue to have any access to configuration
  files and other data hosted on your existing controllers, but it
  does require that you have the additional hardware available to set
  up new hosts while preserving your old ones.

- You can perform the RHEL 7 installation on your RHEL 6 hosts.  While
  this does not require additional hardware, you will need to ensure
  that you have backups of all your configuration files and other
  data.

### If you are using the Cinder LVM backend

If you are using the Cinder LVM backend, you will need to detach any
Cinder volumes prior to starting the upgrade process.  RHEL7
introduces the LIO iSCSI backend, which replaces the TGT backend used
in RHEL6, and this change means that the iSCSI target configuration
will not be preserved across the upgrade.

## Upgrade the control plane

The first step in the upgrade process is to upgrade your control plane
from Icehouse to Juno.

### Deploy RHEL 7 controller nodes

Deploy RHEL 7 onto a new set of servers, and restore your basic system
configuration (interface definitions, storage attachments, etc).

Install some prerequisite packages:

    # yum -y install \
        openstack-selinux \
        openvswitch

Activate the `openvswitch` service:

    # systemctl enable openvswitch
    # systemctl start openvswitch

If you are using the LVM backend for Cinder, you will also need to
install and activate the `targetcli` package for managing the [LIO][]
suybsystem:

[lio]: http://linux-iscsi.org/wiki/LIO

    # yum -y install targetcli
    # systemctl enable target
    # systemctl start target

You will also want to activate the LVM volume groups that contain
your Cinder volumes:

    # vgchange -ay

### Restore your network configuraiton

Ensure that you restore the `/etc/sysconfig/network-scripts` files
required by your Neutron configuration, such as `ifcfg-br-ex`:

    # cp $BACKUP/etc/sysconfig/network-scripts/ifcfg-br-ex \
      /etc/sysconfig/network-scripts/ifcfg-br-ex

And ensure that these interfaces are up:

    # ifup br-ex

### Restore your iptables rules

Ensure that any local firewall configuration that was defined on your
RHEL6 controllers is imported into your RHEL7 controllers by copying
your RHEL 6 `/etc/sysconfig/iptables` into `/etc/sysconfig/iptables`
on your RHEL 7 host.  You will need to install the `iptables-services`
package if it is not already installed:

    # yum -y install iptables-services

Make sure iptables is stopped:

    # systemctl stop iptables

Restore your iptables configuration from backups:

    # cp $BACKUP/etc/sysconfig/iptables /etc/sysconfig/iptables

And activate the iptables service:

    # systemctl enable iptables
    # systemctl start iptables

### Install rabbitmq-server

Install the `rabbitmq-server` package:

    # yum -y install rabbitmq-server

Migrate any `rabbitmq` configuration files from your RHEL6 controllers
into `/etc/rabbitmq` on your RHEL7 controller:

    # rsync -a $BACKUP/etc/rabbitmq/ /etc/rabbitmq

And activate the `rabbitmq-server` service:

    # systemctl enable rabbitmq-server
    # systemctl start rabbitmq-server

### Install mariadb-server

Install the `mariadb-server` package:

    # yum -y install mariadb-server

Either re-mount your `/var/lib/mysql` directory (and modify
`/etc/fstab` appropriately), or restore the contents of
`/var/lib/mysql` from your backups:

    # rsync -a $BACKUP/var/lib/mysql/ /var/lib/mysql/

Restore `/root/.my.conf` from your backups, if it exists:

    # cp $BACKUP/root/.my.cnf /root/.my.cnf

Ensure correct ownership of files in /var/lib/mysql:

    # chown -R mysql:mysql /var/lib/mysql
    # fixfiles restore /var/lib/mysql/

And activate the `mariadb` service:

    # systemctl enable mariadb
    # systemctl start mariadb

Perform any necessary database updates:

    # mysql_upgrade

Verify that you are able to connect to the database server with the
`mysql` command line client; a successful connection looks like this:

    # mysql
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 419
    Server version: 5.5.40-MariaDB MariaDB Server

    Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]> 

### Install Keystone

Install the `openstack-keystone` package:

    # yum -y install openstack-keystone

Copy the Keystone configuration files from your RHEL6 controller into
`/etc/keystone` on your RHEL7 controller:

    # rsync -a $BACKUP/etc/keystone/ /etc/keystone/

Upgrade the Keystone database schema:

    # openstack-db --service keystone --update

Activate the Keystone service:

    # systemctl enable openstack-keystone
    # systemctl start openstack-keystone

Load your Keystone administrative credentials and verify that Keystone
is operating correctly:

    # . /root/keystonerc_admin
    # keystone endpoint-list

**NB**: The remaining instructions assume that you have your keystone
credentials available in your environment.

### Install Cinder

Install the `openstack-cinder` package:

    # yum -y install openstack-cinder

Copy the Cinder configuration files from your RHEL6 controller into
`/etc/cinder` on your RHEL7 controller:

    # rsync -a $BACKUP/etc/cinder/ /etc/cinder/

If you are using the LVM backend, you will need to update
`cinder.conf` to use the new LIO driver.  Edit
`/etc/cinder/cinder.conf` and make the following changes:

- Set `iscsi_helper=lioadm` in the `DEFAULT` section.

Upgrade the Cinder database schema:

    # openstack-db --service cinder --update

Activate the Cinder services:

    # systemctl enable openstack-cinder-{api,volume,scheduler}
    # systemctl start openstack-cinder-{api,volume,scheduler}

Verify that the Cinder API is responding correctly and that your
volumes are available:

    # cinder list

### Install Glance

Install the `openstack-glance` package:

    # yum -y install openstack-glance

Copy the Glance configuration files from your RHEL6 controller into
`/etc/glance` on your RHEL7 controller:

    # rsync -a $BACKUP/etc/glance/ /etc/glance/

Remount or restore the contents of `/var/lib/glance`:

    # rsync -a $BACKUP/var/lib/glance/ /var/lib/glance/

Or edit your `/etc/fstab` appropriately and:

    # mount /var/lib/glance

Upgrade the Glance database schema:

    # openstack-db --service glance --update

Ensure correct ownership on the Glance data directory:

    # chown -R glance:glance /var/lib/glance
    # fixfiles restore /var/lib/glance

Start glance:

    # systemctl enable openstack-glance-{api,registry}
    # systemctl start openstack-glance-{api,registry}

Verify that Glance is operating correctly:

    # glance image-list --all-tenants

### Install Neutron

Install the `openstack-neutron` package as well as packages for any
Neutron plugins you are using (such as `openstack-neutron-ml2` and
`openstack-neutron-openvswitch`):

    # yum -y install openstack-neutron{,-ml2,-openvswitch}

Copy the Neutron configuration files from your RHEL6 controller into
`/etc/neutron` on the RHEL7 controller:

    # rsync -a $BACKUP/etc/neutron/ /etc/neutron/

You will need to correct permissions on these files, because the
`neutron` UID and GID on your RHEL7 system may differ from the values
on your RHEL6 system.  The following `find` command will make the
appropriate changes:

    # find /etc/neutron \! -group root -exec chgrp neutron {} \;

Upgrade the Neutron database schema:

    # openstack-db --service neutron --update

And start Neutron:

    # systemctl enable \
      neutron-{netns-cleanup,ovs-cleanup,dhcp-agent,l3-agent,metadata-agent,openvswitch-agent,server}
    # systemctl start \
      neutron-{dhcp-agent,l3-agent,metadata-agent,openvswitch-agent,server}

You may need to activate additional Neutron agents to support things
like LBaaS and VPNaaS.

Verify that Neutron agents have started and are reporting properly:

    # neutron agent-list

The output of this command should show the `openvswitch` agents on
your compute hosts:

    +--------------------------------------+--------------------+------------------+-------+----------------+---------------------------+
    | id                                   | agent_type         | host             | alive | admin_state_up | binary                    |
    +--------------------------------------+--------------------+------------------+-------+----------------+---------------------------+
    .
    .
    .
    | 15736a0a-acc2-4227-b0e3-3bb720351870 | Open vSwitch agent | compute-1.local  | :-)   | True           | neutron-openvswitch-agent |
    | f87cc391-5263-4808-bf80-8b7d3caf8716 | Open vSwitch agent | compute-0.local  | :-)   | True           | neutron-openvswitch-agent |
    +--------------------------------------+--------------------+------------------+-------+----------------+---------------------------+

These listings should show `:-)` in the `alive` column (note that this
information may take a minute to update, so be patient).

### Install Nova

Install the `openstack-nova` package:

    # yum -y install openstack-nova

Copy the Nova configuration files from your RHEL6 controller into
`/etc/nova` on your RHEL7 controller:

    # rsync -a $BACKUP/etc/nova/ /etc/nova/

Remount or restore the contents of `/var/lib/nova`:

    # rsync -a $BACKUP/var/lib/nova/ /var/lib/nova/

Or edit your `/etc/fstab` appropriately and:

    # mount /var/lib/nova

Modify `nova.conf` to cap the compute API at an Icehouse-compatible
version by adding the following to the `upgrade-levels` section of the
config file:

    [upgrade-levels]
    compute = 3.23.1
    conductor = 3.23.1

This is necessary in order for our Juno controller to inter-operate
with our Icehouse compute nodes.

Upgrade the Nova database schema:

    # openstack-db --service nova --update

Activate Nova services on your controller:

    # systemctl enable \
      openstack-nova-{api,cert,conductor,consoleauth,novncproxy,scheduler}
    # systemctl start \
      openstack-nova-{api,cert,conductor,consoleauth,novncproxy,scheduler}

Verify that your Nova services have started correctly:

    # nova service-list

You should see both the services on your controller as well as the
`nova-compute` services running on your compute nodes:

    +----+------------------+------------------+----------+---------+-------+----------------------------+-----------------+
    | Id | Binary           | Host             | Zone     | Status  | State | Updated_at                 | Disabled Reason |
    +----+------------------+------------------+----------+---------+-------+----------------------------+-----------------+
    .
    .
    .
    | 5  | nova-compute     | compute-0.local  | nova     | enabled | up    | 2015-01-16T14:23:48.000000 | -               |
    | 6  | nova-compute     | compute-1.local  | nova     | enabled | up    | 2015-01-16T14:23:43.000000 | -               |
    +----+------------------+------------------+----------+---------+-------+----------------------------+-----------------+

The `nova-compute` services should show `up` in the `State` column.

### Install Horizon

Install the `openstack-dashboard` package:

    # yum -y install openstack-dashboard

Copy the Horizon configuration files from your RHEL6 controller to
`/etc/openstack-dashboard' on your RHEL7 controller:

    # rsync -a $BACKUP/etc/openstack-dashboard/ \
      /etc/openstack-dashboard/

Until [BZ 1174977][] is resolved, you will also need to enable the
`httpd_can_network_connect` selinux boolean:

[BZ 1174977]: https://bugzilla.redhat.com/show_bug.cgi?id=1174977

    # setsebool httpd_can_network_connect=true

Activate the Apache service:

    # systemctl enable httpd
    # systemctl start httpd

At this point, you should have a fully operational OpenStack
environment running Juno on your controller and Icehouse on your
compute nodes.

## Upgrade the compute nodes

### Migrate Nova instances

Prior to reinstalling a compute node with RHEL7 you should migrate any
running instances onto other compute nodes.  

If your environment supports live migration, you can use the `nova
live-migration` command (as a user with administrative credentials):

    # nova live-migration <uuid>

This will move the instance to another available compute node.

If your environment does not support live migration, you can use the
`nova migrate` command:

    # nova migrate <uuid>

This will pause the virtual server and resume it on another available
compute host.  Note that this is a two-step process; once the
migration completes, your servers will be in the `CONFIRM_RESIZE`
state and for each server you will need to run:

    # nova resize-confirm <server uuid>

**NB**: For the `nova migrate` command to work, the `nova` user on the
source host must be able to connect using `ssh` to the `nova` user on
the remote host.

### Deploy a RHEL7 compute node

Install RHEL7 on your compute node.

Install some prerequisite packages:

    # yum -y install \
        openstack-selinux
        openvswitch

Activate the `openvswitch` service:

    # systemctl enable openvswitch
    # systemctl start openvswitch

### Install virtualization support

Install the `libvirt` and `qemu-kvm` packages:

    # yum -y install libvirt qemu-kvm

Restore your libvirtd configuration from backups:

    # cp $BACKUP/etc/libvirt/libvirtd.conf \
      /etc/libvirtd.conf

Activate the `libvirtd` service:

    # systemctl enable libvirtd
    # systemctl start libvirtd

### Restore your iptables rules

Ensure that any local firewall configuration that was defined on your
RHEL6 compute node is imported into your RHEL7 compute node.  You will
need to install the `iptables-services` package if it is not already
installed:

    # yum -y install iptables-services

Make sure iptables is stopped:

    # systemctl stop iptables

Restore your iptables configuration from backups:

    # cp $BACKUP/etc/sysconfig/iptables /etc/sysconfig/iptables

And activate the iptables service:

    # systemctl enable iptables
    # systemctl start iptables

### Install Neutron

Install the Neutron OpenVswitch agent:

    # yum -y install openstack-neutron-openvswitch

Restore your Neutron configuration from your backups:

    # rsync -a $BACKUP/etc/neutron/ /etc/neutron/

Reset permissions on the neutron config files (as we did for the
controller):

    # find /etc/neutron \! -group root -exec chgrp neutron {} \;

Activate Neutron services on the host:

    # systemctl enable neutron-openvswitch-agent neutron-ovs-cleanup
    # systemctl start neutron-openvswitch-agent

On your controller, use the `neutron agent-list` command to verify
that the agent on your compute node is reporting correctly.

### Install Nova

Install the `openstack-nova-compute` package:

    # yum -y install openstack-nova-compute

Restore your Nova configuration from your backups:

    # rsync -a $BACKUP/etc/nova

Remount or restore the contents of `/var/lib/nova`:

    # rsync -a $BACKUP/var/lib/nova/ /var/lib/nova/

Or edit your `/etc/fstab` appropriately and:

    # mount /var/lib/nova

Edit `nova.conf` to cap the compute API at an icehouse compatible
version:

    [upgrade-levels]
    compute = 3.23.1

This is required in order for this Juno compute node to inter-operate
with other compute nodes still running the Icehouse release.
    
Start Nova services on the compute host:

    # systemctl enable openstack-nova-compute
    # systemctl start openstack-nova-compute

On your controller, use the `nova service-list` command to verify
that the `nova-compute` service on your compute host is reporting
correctly:

    # nova service-list

## Remove API version restrictions

When you have finished upgrading all your compute hosts, remove any
`upgrade_levels` restrictions installed on your controllers and
compute hosts during the upgrade process and restart all Nova
services:

    # openstack-service restart nova

