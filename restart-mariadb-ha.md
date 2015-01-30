# Restarting MariaDB in an HA environment

Before running your database schema upgrades you will need to bring up
enough of your environment to have a functioning database.  The
following commands will bring up the database, associated VIP, and
haproxy on a single host so that the database is available at the
expected address.

1. Edit `/etc/my.cnf.d/galera.conf` on one of your database nodes, and
   replace:

       wsrep_cluster_address="gcomm://XXX.XXX.XXX.X,XXX.XXX.XXX.X,XXX.XXX.XXX.XX"

   With:

       wsrep_cluster_address="gcomm://"

1. Start the database resource:

       pcs resource debug-start mysqld

1. Start the database VIP.

   Look in `/etc/keystone/keystone.conf` for the `connection` setting
   in the `database` section:

       connection=mysql://keystone:secret@192.168.100.11/keystone
       
   The IP address used in that connection string is the database VIP.
   Start that resource:

       pcs resource debug-start ip-192.168.100.11

1. Start HAProxy:

       pcs resource debug-start haproxy

1. Edit `/etc/my.cnf.d/galera.conf` to undo the change you made it
   your first step.

At this point, your database service should be running.  Confirm that
you can connect to it locally:

    # mysql -e 'select 1'

And confirm that you can connect to it using the credentials from your
Keystone configuration:

    # mysql -u keystone -psecret -h 192.168.100.11 -e 'select 1'

## After you have restarted your cluster

Once you have successfully restarted all of your HA resources, you
will need to revert the change you made earlier to
`/etc/my.cnf.d/galera.conf`.

Replace:

    wsrep_cluster_address="gcomm://"

With the original:

    wsrep_cluster_address="gcomm://XXX.XXX.XXX.X,XXX.XXX.XXX.X,XXX.XXX.XXX.XX"

