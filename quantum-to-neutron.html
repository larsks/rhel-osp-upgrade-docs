<!DOCTYPE html>
<html>
<title>Upgrading from Quantum to Neutron</title>
<xmp theme="bootstrap" style="display:none;">

Pre-upgrade
===========

Before upgrading to RHOS 4.0:

1. Prepare the `ovs_quantum` database for migration:

       # quantum-db-manage --config-file /etc/quantum/quantum.conf \
         --config-file /etc/quantum/plugin.ini stamp grizzly

1. Preserve `/etc/quantum/quantum.conf` and `/etc/quantum/plugin.ini`:

       # cp /etc/quantum/quantum.conf /etc/quantum/plugin.ini \
         /root/

1. Remove the `quantum` user from your system:

       # userdel quantum

Post-upgrade
============

After upgrading to RHOS 4.0, but before running `packstack`:

1. Upgrade the `ovs_quantum` database schema for OpenStack Havana:

       # neutron-db-manage --config-file /root/quantum.conf \
         --config-file /root/plugin.ini upgrade havana

   (Note that we are using the configuration files preserved in the
   pre-upgrade step.)

1. Create a new `ovs_neutron` database:

       # mysqladmin create ovs_neutron

1. Dump the `ovs_quantum` database to the new `ovs_neutron` database:

       # mysqldump ovs_quantum | mysql ovs_neutron

</xmp>
<script src="strapdown/v/0.2/strapdown.js"></script>
</html>

<!-- vim: set ft=markdown : -->
