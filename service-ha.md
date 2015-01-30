# Managing OpenStack services using Pacemaker

<!--
I am explicitly not using maintenance-mode=true in this document,
because that introduces a timing issue with respect to setting
stop-all-resources=true (specifically, if you set maintance-mode=true
immediately after setting stop-all-resources=true, Pacemaker will not
actually stop your resources).
-->

## <a name="stop">Stopping services</a>

To stop all the Pacemaker managed resources on your cluster, run:

    # pcs property set stop-all-resources=true

This setting (`stop-all-resources=true`) causes Pacemaker to stop
any active resources.

## <a name="start">Starting services</a>

To restart all the Pacemaker managed resources on your cluster, run:

    # pcs property set stop-all-resources=false

