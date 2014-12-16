# Upgrading from RHEL 6/RHEL-OSP 5 to RHEL 7/RHEL-OSP 6

While RHEL-OSP 5 is supported on RHEL 6, RHEL-OSP 6 is not.  If you
want to upgrade an Icehouse environment running on RHEL 6, you will
first need to bring all of your systems up to RHEL 7 as part of the
upgrade process.

There is no in-place upgrade option when going from RHEL 6 to RHEL 7,
so you will need to completely reinstall all of the components in your
OpenStack environment.  This document suggests one possible strategy
for approaching this ugprade process.

## Prerequisites

These instructions assume that are rebuilding your RHEL6 hosts into
RHEL7 hosts.  In particular, they assume that your RHEL7 hosts will
have the same ip addresses and hostnames of the hosts that they are
replacing.

**NB** Be absolutely sure the system hostname (as returned by the
`hostname` command) is identical.  Some OpenStack services (in
particular Cinder and Neutron) identify agents by hostname, and a
hostname mismatch during this upgrade process can cause unexpected
failures.

Any data that needs to survive the upgrade process (such as your
database backing store, OpenStack service state data in
`/var/lib/nova`, `/var/lib/glance`, etc) must be stored somewhere
other than on your root filesystem.

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

You will also want to activate the LVM volume groups that container
your Cinder volumes:

    # vgchange -ay

### Mount or restore your application data

Restore at least `/var/lib/mysql`, `/var/lib/glance`, and
`/var/lib/nova` from your Icehouse environment.

### Restore your iptables rules

Ensure that any local firewall configuration that was defined on your
RHEL6 controllers is imported into your RHEL7 controllers.  You will
need to install the `iptables-services` package:

    # yum -y install iptables-services

And activate the iptables service:

    # systemctl enable iptables
    # systemctl start iptables

### Install rabbitmq-server

Install the `rabbitmq-server` package:

    # yum -y install rabbitmq-server

Migrate any `rabbitmq` configuration files from your RHEL6 controllers
into `/etc/rabbitmq` on your RHEL7 controller, and then activate the
`rabbitmq-server` service:

    # systemctl start rabbitmq-server

### Install mariadb-server

Install the `mariadb-server` package:

    # yum -y install mariadb-server

Ensure correct ownership of files in /var/lib/mysql:

    # chown -R mysql:mysql /var/lib/mysql

And activate the `mariadb` service:

    # systemctl enable mariadb
    # systemctl start mariadb

Perform any necessary database updates:

    # mysql_upgrade

Verify that you are able to connect to the database server with the
`mysql` command line client.  If your RHEL6 controller has a
`/root/.my.conf` file, copy it to your RHEL7 system, otherwise,
manually enter your datbase admin password.

### Install Keystone

Install the `openstack-keystone` package:

    # yum -y install openstack-keystone

Copy the Keystone configuration files from your RHEL6 controller into
`/etc/keystone` on your RHEL7 controller.

Upgrade the Keystone database schema:

    # sudo -u keystone keystone-manage db_sync

Ensure proper ownership on the Keystone log files:

    # chown -R keystone:keystone /var/log/keystone

Activate the Keystone service:

    # systemctl enable openstack-keystone
    # systemctl start openstack-keystone

Load your Keystone administrative credentials and verify that Keystone
is operating correctly:

    # keystone endpoint-list

(The remaining steps assume that your Keystone credentials have
been loaded into your environment.)

### Install Cinder

Install the `openstack-cinder` package:

    # yum -y install openstack-cinder

Copy the Cinder configuration files from your RHEL6 controller into
`/etc/cinder` on your RHEL7 controller.  You will need to make the
following changes if you are using the LVM backend:

- Set `iscsi_helper=lioadm` in the `DEFAULT` section.

Upgrade the Cinder database schema:

    # sudo -u cinder cinder-manage db sync

Ensure correct ownership of the Cinder log directory:

    # chown -R cinder:cinder /var/log/cinder

Activate the Cinder services:

    # systemctl enable openstack-cinder-{api,volume,scheduler}
    # systemctl start openstack-cinder-{api,volume,scheduler}

Verify that the Cinder API is responding correctly and that your
volumes are available:

    # cinder list

### Install Glance

Install the `openstack-glance` package:

    # yum -y install `openstack-glance`

Copy the Glance configuration files from your RHEL6 controller into
`/etc/glance` on your RHEL7 controller.

Upgrade the Glance database schema:

    # sudo -u glance glance-manage db sync

Ensure correct ownership on the Glance log and data directories:

    # chown -R glance:glance /var/log/glance /var/lib/glance

Start glance:

    # systemctl enable glance-{api,registry}
    # systemctl start glance-{api,registry}

Verify that Glance is operating correctly:

    # glance image-list

### Install Neutron

Install the `openstack-neutron` package as well as packages for any
Neutron plugins you are using (such as `openstack-neutron-ml2` and
`openstack-neutron-openvswitch`):

    # yum -y install openstack-neutron{,-ml2,-openvswitch}

Copy the Neutron configuration files from your RHEL6 controller into
`/etc/neutron` on the RHEL7 controller.  You will need to correct
permissions on these files, because the `neutron` UID and GID on your
system may be different:

    # find /etc/neutron \! -group root -exec chgrp neutron {} \;

Upgrade the Neutron database schema:

    # neutron-db-manage --config-file /etc/neutron/neutron.conf \
      --config-file /etc/neutron/plugin.ini \
      upgrade head

And start Neutron:

    # systemctl enable \
      neutron-{dhcp-agent,l3-agent,metadata-agent,openvswitch-agent,server}
    # systemctl start \
      neutron-{dhcp-agent,l3-agent,metadata-agent,openvswitch-agent,server}

You may need to activate additional Neutron agents to support things
like LBaaS and VPNaaS.

Verify that Neutron agents have started and are reporting properly:

    # neutron agent-list

### Install Nova

Install the `openstack-nova` package:

    # yum -y install openstack-nova

Copy the Nova configuration files from your RHEL6 controller into
`/etc/nova` on your RHEL7 controller.  Modify `nova.conf` to cap the
compute API at an Icehouse-compatible version by adding the following
to the `upgrade-levels` section of the config file:

    [upgrade-levels]
    compute = icehouse
    conductor = icehouse

Upgrade the Nova database schema:

    # sudo -u nova nova-manage db sync

Activate Nova services on your controller:

    # systemctl enable \
      nova-{api,cert,conductor,consoleauth,novncproxy,scheduler}
    # systemctl start \
      nova-{api,cert,conductor,consoleauth,novncproxy,scheduler}

Verify that your Nova services have started correctly:

    # nova service-list

You should see both the services on your controller as well as the
`nova-compute` services running on your compute nodes.

At this point, you should have a fully operational OpenStack
environment running Juno on your controller and Icehouse on your
compute nodes.

## Upgrade the compute nodes

### Migrate Nova instances

Prior to reinstalling a compute node with RHEL7 you should migrate any
running instances onto other compute nodes.

**NB** As of this writing, upstream bug [1402813][] prevents live
migrations between Icehouse compute nodes and Juno compute nodes.
Until that bug is resolved, you will need to use the `nova migrate`
command to move instances to other hosts:

[1402813]: https://bugs.launchpad.net/nova/+bug/1402813

    # nova migrate <server uuid>

This will pause the virtual server and resume it on another available
compute host.  Note that this is a two-step process; once the
migration completes, your servers will be in the `CONFIRM_RESIZE`
state and for each server you will need to run:

    # nova resize-confirm <server uuid>

Once [1402813][] is resolved you will be able to use the `nova
live-migration` command to migrate your instances without
interruption.

**NB**: For the `nova migrate` command to work, the `nova` user on the
source host must be able to connect using `ssh` to the `nova` user on
the remote host.

### Deploy a RHEL7 compute node

Install RHEL7 on your compute node.

Install some prerequisite packages:

    # yum -y install \
        openstack-selinux \
        openvswitch \
        libvirt \
        qemu-kvm

Activate the `openvswitch` and `libvirtd` services:

    # systemctl enable openvswitch libvirtd
    # systemctl start openvswitch libvirtd

### Restore your iptables rules

Ensure that any local firewall configuration that was defined on your
RHEL6 compute node is imported into your RHEL7 compute node.  You will
need to install the `iptables-services` package:

    # yum -y install iptables-services

And activate the iptables service:

    # systemctl enable iptables
    # systemctl start iptables

### Install Neutron

Install the Neutron OpenVswitch agent:

    # yum -y install openstack-neutron-openvswitch

Activate Neutron services on the host:

    # systemctl enable neutron-openvswitch-agent neutron-ovs-cleanup
    # systemctl start neutron-openvswitch-agent

On your controller, use the `neutron agent-list` command to verify
that the agent on your compute node is reporting correctly.

### Install Nova

Install the `openstack-nova-compute` package:

   # yum -y install openstack-nova-compute

Edit `nova.conf` to cap the compute API at an icehouse compatible
version:

    [upgrade-levels]
    compute = icehouse
    conductor = icehouse
    
And start Nova services on the compute host:

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

