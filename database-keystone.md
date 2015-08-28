# Keystone database upgrades

## Cleaning expired tokens

Earlier versions of our installer may not have configured your system
to automatically purge expired Keystone tokens.  It is possible that
your token table has a large number of expired entries.  This can
dramatically increase the time it takes to complete the database
schema upgrade.

You can alleviate this problem by running the following command before
beginning the Keystone database upgrade process:

    keystone-manage token_flush

This will flush expired tokens from the database.  You should arrange
to run this command periodically (e.g., daily) using `cron`.

