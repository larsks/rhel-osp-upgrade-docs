# Common pre-upgrade steps

On all of your hosts:

1. Install the Juno yum repository.

1. Upgrade the `openstack-selinux` package, if available:

        yum upgrade openstack-selinux

     This is necessary to ensure that the upgraded services will run
     correctly on a system with [SELinux][] enabled.

[selinux]: http://selinuxproject.org/page/Main_Page

