# Setting up a parallel Nova environment

These instructions will help you set up a new Nova environment running
Juno, operating as a distinct region from your existing Icehouse Nova
environment.

## Install packages

On the system acting as your Nova API server, you will need:

- `python-novaclient`
- `openstack-nova-common`
- `openstack-nova-conductor`
- `openstack-nova-novncproxy`
- `openstack-nova-api`
- `python-nova`
- `openstack-nova-cert`
- `openstack-nova-console`
- `openstack-nova-scheduler`

On the system(s) acting as your Nova compute servers, you will need:

- `openstack-nova-common`
- `openstack-nova-compute`
- `python-neutron`
- `openstack-neutron`
- `python-neutronclient`
- `python-novaclient`
- `python-nova`
- `openstack-neutron-openvswitch`
- `bridge-utils`

## Create a new database

The new Juno Nova environment will need to use a distinct database
from the one your existing Icehouse Nova environment is using.
On a system where you have administrative access to your SQL server,
create a new database.  This document assumes you've used the name
`nova_juno`.  Using mysql or mariadb, the commands to create the new
database would be something like:

    mysql> create database nova_juno;
    Query OK, 1 row affected (0.00 sec)
    mysql> grant all on nova_juno.* to nova@'%';
    Query OK, 0 rows affected (0.00 sec)

## Configure Nova

Start by replacing `/etc/nova` on your Havana Nova controller with the
contents of `/etc/nova` from your Grizzly controller.  You will need
to make several changes to `/etc/nova/nova.conf`:

1. Update `sql_connection` to point to the database we just created.
   If you old configuration looked like this:

         sql_connection = mysql://nova@192.168.122.110/nova

     The new configuration should look like this:

         sql_connection = mysql://nova@192.168.122.110/nova_juno

1. Update `metadata_host` to point at your new Havana controller.

1. On your compute nodes, make sure that the following settings all
   point to the address of the local compute node:

     - `vncserver_proxyclient_address`
     - `novncproxy_base_url`
     - `vncserver_listen`

1. You need to change the message topics used by Nova when
   communicating via the AMQP server.  Add the following to the
   `[DEFAULT]` section of `nova.conf`:  

         cert_topic=cert_juno
         compute_topic=compute_juno
         console_topic=console_juno
         consoleauth_topic=consoleauth_juno
         notifications_topic=notifications_juno
         scheduler_topic=scheduler_juno

     And add the following to the `[conductor]` section of `nova.conf`
     (you will probably have to add this section):

         [conductor]
         conductor_topic=conductor_juno

## Configure compute nodes

1. Make sure that the following services are enabled and running:

     - `openvswitch`
     - `messagebus`
     - `libvirtd`

     That is, for each service run `chkconfig <service> on` followed
     by `service <service> start`.

<!-- TODO: verify if it is necessary to create OVS bridges manually -->

## Start Nova services

1. Start OpenStack services on the Juno controller:

         # openstack-service start

1. Start OpenStack services on the Juno compute nodes:

         # openstack-service start

1. Verify that the new compute service has registered itself properly
   with the Juno controller.  Run the following with Nova
   administrative credentials:

         # nova service-list

     You should see entries for:

       - `nova-conductor`
       - `nova-consoleauth`
       - `nova-cert`
       - `nova-scheduler`

     As well as one `nova-compute` entry for each Juno compute node.

## Register Keystone endpoints

1. Register your new controller with Keystone in a separate region.
   First, find the service id for the `compute` service:

         $ keystone service-get nova
         +-------------+----------------------------------+
         |   Property  |              Value               |
         +-------------+----------------------------------+
         | description |    Openstack Compute Service     |
         |      id     | befb024666424084b37a84ed5ee1143b |
         |     name    |               nova               |
         |     type    |             compute              |
         +-------------+----------------------------------+

1. Assuming that your Nova API host is 192.168.122.198 and you would like to call the new region `Juno`, create a new endpoint with the following command:

         $ keystone endpoint-create --region Juno \
           --service-id befb024666424084b37a84ed5ee1143b \
           --publicurl http://192.168.122.198:8774/v2/%(tenant_id)s \
           --adminurl http://192.168.122.198:8774/v2/%(tenant_id)s \
           --internalurl http://192.168.122.198:8774/v2/%(tenant_id)s

1. If you will need volume attachment to work in your Juno
   environment, create a new endpoint for the Cinder service in your
   new region.

         $ keystone service-get cinder
         ...
         $ keystone endpoint-list
         ...
         $ keystone endpoint-create --region Juno \
            --service-id 1a6f2343a6f14bc9b5a2c2f4e4a894ca \
            --publicurl 'http://192.168.122.110:8776/v1/%(tenant_id)s' \
            --adminurl 'http://192.168.122.110:8776/v1/%(tenant_id)s' \
            --internalurl 'http://192.168.122.110:8776/v1/%(tenant_id)s'
 
1. Verify that you can communicate with the new region.  After loading
   appropriate keystone credentials, run:

         $ nova --os-region-name Juno host-list
   
     You should see output listing your new Havana Nova hosts.  For
     example:

         +-------------------------------------------+----------------+----------+
         | host_name                                 | service        | zone     |
         +-------------------------------------------+----------------+----------+
         | rdo-juno-nova-api-net0.default.virt     | cert           | internal |
         | rdo-juno-nova-api-net0.default.virt     | conductor      | internal |
         | rdo-juno-nova-api-net0.default.virt     | consoleauth    | internal |
         | rdo-juno-nova-api-net0.default.virt     | scheduler      | internal |
         | rdo-juno-nova-compute-net0.default.virt | compute_juno | internal |
         +-------------------------------------------+----------------+----------+

