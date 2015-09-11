# Common pre-upgrade steps

On all of your hosts:

1. If you are running Puppet as configured by Staypuft, you must
   disable it:

        # systemctl stop puppet
        # systemctl disable puppet

  This ensures that the Staypuft-configured puppet will not revert
  changes made as part of the upgrade process.

1. Install the Juno yum repository.

1. Upgrade the `openstack-selinux` package, if available:

        yum upgrade openstack-selinux

     This is necessary to ensure that the upgraded services will run
     correctly on a system with [SELinux][] enabled.

[selinux]: http://selinuxproject.org/page/Main_Page

