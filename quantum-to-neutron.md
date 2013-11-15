# Quantum to Neutron Database Upgrade

Note that newer versions of the Neutron packages handle most of this
for you (with the exception of the actual database schema upgrade).

## Pre-upgrade

Before upgrading to Neutron:

1. Stop Quantum services on all of your hosts:

         # openstack-service stop quantum

1. Remove the `quantum` user from all of your hosts:

         # userdel quantum

1. Prepare the `ovs_quantum` database for migration.  On the Quantum
   server, run:

         # quantum-db-manage --config-file /etc/quantum/quantum.conf \
           --config-file /etc/quantum/plugin.ini stamp grizzly


## Post-upgrade

After upgrading to Neutron (but *before* starting Neutron services):

1. Migrate your Quantum configuration files in `/etc/quantum` to
   `/etc/neutron`.  This generally involves replacing `quantum` with
   `neutron` in your settings.  The following script will perform this
   migration:

        find /etc/quantum -name '*.rpmsave' | while read cf; do
          [ -f $cf ] || continue

          newcf=${cf/.rpmsave/}
          newcf=${newcf//quantum/neutron}
          sed '
            /^sql_connection/ b
            /^admin_user/ b
            s/quantum/neutron/g
            s/Quantum/Neutron/g
          ' $cf > $newcf
        done

        if [ -h /etc/quantum/plugin.ini ]; then
          plugin_ini=$(readlink /etc/quantum/plugin.ini)
          ln -sf ${plugin_ini//quantum/neutron} /etc/neutron/plugin.ini
        fi

1. Upgrade the `ovs_quantum` database schema for OpenStack Havana:

        # neutron-db-manage \
          --config-file /etc/neutron/neutron.conf \
          --config-file /etc/neutron/plugin.ini upgrade head

    (Note that we are using the configuration files preserved in the
    pre-upgrade step.)

