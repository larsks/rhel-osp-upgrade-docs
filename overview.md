# Upgrading from Juno to Kilo: Overview

Note that the following holds true for all of the described upgrade scenarios:

- All scenarios involve some service interruptions.
- Running instances will not be affected by the upgrade process unless
  you (a) reboot a compute node or (b) explicitly shut down an
  instance.

## Scenario 1: All at once

In this scenario, you will take down all of your OpenStack
services at the same time, and will not bring them back up until the
upgrade process is complete.

**Pros**: This process is very simple.  Because everything is down
there is no orchestration involved.

**Cons**: All of your services are unavailable all at once. In a large
environment, this can result in a potentially extensive downtime as
you wait for database schema upgrades to complete.

Read about this scenario in [Upgrade Scenario 1][1].

## Scenario 2: Service-by-service with live compute upgrade

In this scenaior, you upgrade one service at a time.  You perform
rolling upgrades of your compute hosts, taking advantage of the fact
that `nova-compute` from Juno can communicate with a Kilo control
plane.

**Pros**: This process minimizes the downtime to your existing
compute workloads.

This is our recommended upgrade procedure for most environments.

**Cons**: This is a more complex procedure, and mistakes or
undiscovered compatibility issues can unexpectedly turn it into
Scenario 1.

Read about this scenario in [Upgrade Scenario 2 (HA)][2] if you are
running an HA environment, or [Upgrade Scenaior 2 (non-HA)][3] if you
are running in a non-HA environment.

[1]: upgrade-1.html
[2]: upgrade-2-ha.html
[3]: upgrade-2.html

