# Upgrading Quantum to Neutron

On your Quantum network hosts and compute nodes:

    openstack-service stop quantum
    userdel quantum
    yum upgrade \*quantum\*

On your Neutron network host:

    openstack-db --service neutron --update

On your Neutron network host and compute nodes:

    openstack-service start neutron

