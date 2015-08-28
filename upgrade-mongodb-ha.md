# Upgrade MongoDB

1. Remove the `mongod` resource from Pacemaker's control:

        pcs resource unmanage mongod-clone

1. Stop the service on all of your controllers.  On each controller,
   run:

        systemctl stop mongod

1. Upgrade the relevant packages:]

        yum upgrade 'mongodb*' 'python-pymongo*'

1. Reload systemd to account for updated unit files:

        systemctl daemon-reload

1. Restart the `mongod` service on your controllers by running, on
   each controller:

        systemctl start mongod

1. Return the resource to Pacemaker control:

        pcs resource manage mongod-clone

1. Wait until the output of `pcs status` shows that the above
   resources are running.
