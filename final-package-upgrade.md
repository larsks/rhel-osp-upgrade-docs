## Final package upgrade

After completing all of your service upgrades, you must perform a
complete package upgrade on all of your systems:

    # yum upgrade

This will upgrade the client packages on all of your systems (i.e.,
packages like `python-keystoneclient`, `python-glanceclient`, etc) as
well as generally ensuring that you have the appropriate versions of
all supporting tools.

**NB**: After this upgrade you will need to restart the `nova-compute`
service, which otherwise will encounter errors due to the upgrade of
the Glance client package.

If this results in a new kernel being installed on your systems you
will probably want to schedule a reboot at some point in the future in
order to activate the kernel.

