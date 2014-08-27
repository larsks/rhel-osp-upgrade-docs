# Migrating from Qpid to Rabbitmq

## Option 1: All at once

1. Shut down all your OpenStack services.  On all hosts in your
   OpenStack deployment, run:

         openstack-service stop

1. Shut down and disable qpidd:

         service qpidd stop
         chkconfig rabbitmq-server off

1. On your controller, install `rabbitmq`:

         yum install rabbitmq-server

1. Start `rabbitmq` and enable:

         service rabbitmq-server start
         chkconfig rabbitmq-server on

1. For each service, update the relevant configuration file to use
   `rabbitmq` instead of `qpid`.  You can follow the procedures in
   [this document](https://access.redhat.com/articles/1167113).

1. When you have finished configuring all the services on all your
   OpenStack hosts, restart your OpenStack services.  On each host
   in your deployment, run:

         openstack-service start

## Option 2: Service by service

It is possible to run the `rabbitmq` server in parallel with (and on a
different port from) `qpid`.  This permits you to make changes to one
service at a time without disrupting your entire environment.

1. On your controller, install the `rabbitmq-server` package:

         yum install rabbitmq-server

1. Edit `/etc/rabbitmq/rabbitmq-env.conf` and change:

         RABBITMQ_NODE_PORT=5672       

     To:

         RABBITMQ_NODE_PORT=5672       

     This will configure `rabbitmq-server` to bind to port 5673 instead
   of the normal AMQP port, 5672.

1. Start and enable `rabbitmq`:

         service rabbitmq-server start
         chkconfig rabbitmq-server on

1. For each service, modify the appropriate configuration files as
   per [this document](https://access.redhat.com/articles/1167113),
   and then restart the service.

     Note that you will need to configure each service to use port 5673
   for `rabbitmq` rather than the default port.  This may also require
   appropriate firewall changes to permit access to port 5673 on your
   controller.

     For example, to migrate your Nova services from `qpid` to
     `rabbitmq`:

     1. Edit `/etc/nova/nova.conf` on both the controller and compute
          hosts.

     1. Restart Nova services on the controller and compute hosts:

              controller# openstack-service restart nova

          And:
          
              compute# openstack-service restart nova

1. After completing the configuration changes for all of your
   services, stop and disable the `qpid` service on your controller:

            service qpidd stop
            chkconfig qpidd off

At this point, all of your services are now talking to `rabbitmq` on
port 5673.

You can verify that you have completed the migration by using the
`netstat` or `ss` command to look for `ESTABLISHED` connections to
port 5672.  E.g:

    # netstat -tan | grep 5672 | grep ESTABLISHED

After completing the above steps, there should be no output from this
command.  All of your services should now be using port 5673:

    # netstat -tan | grep 5673 | grep ESTABLISHED

Which will generate output like:

    tcp        0      0 127.0.0.1:37110         127.0.0.1:5673          ESTABLISHED
    tcp        0      0 127.0.0.1:37108         127.0.0.1:5673          ESTABLISHED
    tcp        0      0 192.168.122.162:54024   192.168.122.162:5673    ESTABLISHED
    tcp        0      0 127.0.0.1:37100         127.0.0.1:5673          ESTABLISHED
    tcp        0      0 192.168.122.162:54595   192.168.122.162:5673    ESTABLISHED
    tcp        0      0 127.0.0.1:37109         127.0.0.1:5673          ESTABLISHED

