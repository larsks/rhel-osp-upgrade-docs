# Upgrading Quantum to Neutron

On your Quantum network hosts and compute nodes:

    openstack-service stop quantum
    userdel quantum
    yum upgrade \*quantum\*

On your Neutron network host:

    neutron-db-manage \
      --config-file /etc/neutron/neutron.conf \
      --config-file /etc/neutron/plugin.ini upgrade head

On your Neutron network host and compute nodes:

    openstack-service start neutron

