# Upgrade MariaDB

Perform the follow steps on each host running MariaDB.  Complete the
steps on one host before starting the process on another host.

1. Stop the service from running on the local node:

        pcs resource ban galera-master $(crm_node -n)

1. Wait until `pcs status` shows that the service is no longer running
   on the local node.  This may take a few minutes.  The local node
   will first transition to `slave` mode:

         Master/Slave Set: galera-master [galera]
             Masters: [ pcmk-mac525400aeb753 pcmk-mac525400bab8ae ]
             Slaves: [ pcmk-mac5254004bd62f ]

    It will eventually transition to `stopped`:

         Master/Slave Set: galera-master [galera]
             Masters: [ pcmk-mac525400aeb753 pcmk-mac525400bab8ae ]
             Stopped: [ pcmk-mac5254004bd62f ]

1. Upgrade the relevant packages.

        yum ugprade '*mariadb*' '*galera*'

1. Allow Pacemaker to schedule the galera resource on the local node:

        pcs resource clear galera-master

1. Wait until `pcs status` shows that the `galera` resource is running
   on the local node as a master.  The output from `pcs status` should
   include something like:

         Master/Slave Set: galera-master [galera]
             Masters: [ pcmk-mac5254004bd62f pcmk-mac525400aeb753 pcmk-mac525400bab8ae ]

