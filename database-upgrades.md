# Database upgrades

## Keystone

On the Keystone host, run:

    # keystone-manage db_sync

## Cinder

On the Cinder host, run:

    # cinder-manage db sync

## Swift

Swift does not require an explicit schema upgrade.

## Glance

On the Glance API host, run:

    # glance-manage db_sync

## Nova

On the Nova API host, run:

    # nova-manage db sync

## Quantum/Neutron

On the Neutron host, run:

    # neutron-db-manage \
      --config-file /etc/neutron/neutron.conf \
      --config-file /etc/neutron/plugin.ini upgrade head

**NB**: These instructions require at least version ?? of the
`openstack-neutron` package.  If you have an older version of this
package, see these [extended upgrade instructions][q-to-n].

[q-to-n]: quantum-to-neutron.html

