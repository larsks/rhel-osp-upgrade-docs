# Upgrading from Havana to Icehouse: Overview

Note that the following holds true for all of the following scenarios:

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

## Scenario 2: Service-by-service

In this scenario, you upgrade one service at a time.

**Pros**: Rather than a single large service outage you are able to
stage outages to specific services.  You schedule potentially
longer upgrades -- such as the compute service upgrade in a large
environment -- separately from upgrades that take less time.

**Cons**: You will still have an interruption to your Nova APIs and
compute nodes.

Read about this scenario in [Upgrade Scenario 2][2].

## Scenario 3: Service-by-service with parallel compute

For most services this scenario is identical to scenario 2, with the
exception of the Nova controller and compute services.  Rather than
upgrading your existing Nova environment as part of this process, you
deploy new nodes running the Havana Nova services.  You wait for
existing workloads on your Havana compute nodes to complete (or
migrate them by hand), and when a Havana compute node is no longer
hosting any instances you upgrade the compute service on that node.

**Pros**: This minimizes interruptions to your compute service.
Existing workloads can run indefinitely, and you do not need to wait
for a database migration.

**Cons**: This requires additional hardware resources to bring up the
Icehouse Nova nodes.

Read about this scenario in [Upgrade Scenario 3][3].

## Scenario 4: Service-by-service with live compute upgrade

For most services this scenario is identical to scenario 2, with the
exception of the Nova controller and compute services. In this scenario, you
will upgrade the Nova controller services to the Icehouse release and
configure them to support an RPC API version that is compatible with
your existing Havana compute nodes.  This permits you to upgrade your
compute nodes one at a time without little or no downtime.

**Pros**: Like scenario 3, this process minimizes the downtime to your
existing compute workloads, but does not require a parallel
environment to support the process.

**Cons**: The features that support this live upgrade process are very
new and may not be as well tested as other aspects of OpenStack.

Read about this scenario in [Upgrade Scenario 4][4].

[1]: upgrade-1.html
[2]: upgrade-2.html
[3]: upgrade-3.html
[4]: upgrade-4.html

