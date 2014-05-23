# Upgrading Nova

1. On all hosts running Nova services:

       openstack-service stop nova
       yum -d1 -y upgrade \*nova\*

1. On your Nova API host:

       openstack-db --service nova --update

1. On all your hosts running Nova services:
 
        openstack-service start nova

## Configuration changes

When upgrading from Havana to Icehouse, you should remove the
`DEFAULT/libvirt_vif_driver` or `libvirt/vif_driver` configuration
options from `/etc/nova/nova.conf`.

The `DEFAULT/libvirt_vif_driver` and `libvirt/vif_driver`
configuration options are deprecated in the Icehouse release and
will be removed in subsequent releases. If you have either of these
options set to something other than
`nova.virt.libvirt.vif.LibvirtGenericVIFDriver` you will see
warnings in your logs when running Nova.

You should remove these options from your nova.conf file.

