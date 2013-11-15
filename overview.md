# Upgrading from Grizzly to Havana: Overview

## Scenario 1: All at once

In this scenario, you will take down all of your OpenStack
services at the same time, and will not bring them back up until the
upgrade process is complete.

**Pros**: This process is very simple.  Because everything is down
there is no orchestration involved.

**Cons**: In a large environment, this can result in a potentially
extensive downtime as you wait for database schema upgrades to
complete.

Read about this scenario in [Upgrade Scenario 1][1].

## Scenario 2: Service-by-service

In this scenario, you upgrade one service at a time.

**Pros**: Rather than a single large service outage you are able to
restrict outages to specific services.  You schedule potentially
longer upgrades -- such as the compute service upgrade in a large
environment -- seperately from upgrades that take less time.

**Cons**: You may still have an extended outage for your compute
service at some point.

Read about this scenario in [Upgrade Scenario 2][2].

## Scenario 3: Service-by-service with parallel compute

For most services this scenario is identical to scenario 2, with the
exception of the compute service.  Rather than upgrading your existing
compute nodes as part of this process, you deploy new compute nodes
running the Havana compute service.  You wait for existing workloads
on your Grizzly compute nodes to complete (or migrate them by hand),
and when a Grizzly compute node is no longer hosting any instances you
upgrade the computer service on that node.

**Pros**: This minimizes interruptions to your compute service.

**Cons**: This requires additional hardware resources to bring up the
Havana compute nodes.

Read about this scenario in [Upgrade Scenario 3][3].

[1]: upgrade-1.html
[2]: upgrade-2.html
[3]: upgrade-3.html

