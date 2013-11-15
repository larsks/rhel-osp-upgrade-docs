# Managing OpenStack services

## The openstack-service command

These instructions make use of the `openstack-service` command,
available from the `openstack-utils` package in RDO Havana (and RHOS 4).  After install the appropriate repositories, you can upgrade to the latest version by running:

    # yum install openstack-utils

<!-- You'll need at least version ?? of this package in order for the
`openstack-service` command to be available. -->

## <a name="stop">Stopping services</a>

To stop all the OpenStack services running on a host:

    # openstack-service stop

To stop a specific suite of services (e.g., all Nova services)
running on a host:

    # openstack-service stop nova

Which on a Nova controller might result in:

    Stopping openstack-nova-api: [  OK  ]
    Stopping openstack-nova-cert: [  OK  ]
    Stopping openstack-nova-conductor: [  OK  ]
    Stopping openstack-nova-consoleauth: [  OK  ]
    Stopping openstack-nova-scheduler: [  OK  ]

## <a name="start">Starting services</a>

To start all the OpenStack services running on a host:

    # openstack-service start

To start a specific suite of services (e.g., all Nova services)
running on a host:

    # openstack-service stop nova

Which on a Nova controller might result in:

    Starting openstack-nova-api: [  OK  ]
    Starting openstack-nova-cert: [  OK  ]
    Starting openstack-nova-conductor: [  OK  ]
    Starting openstack-nova-consoleauth: [  OK  ]
    Starting openstack-nova-scheduler: [  OK  ]

