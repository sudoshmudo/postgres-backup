#! /bin/sh

set -eu

if [ -z "$SCHEDULE" ]; then
    echo "WARNING: $SCHEDULE is null. Going to sleep."
    tail -f /dev/null # do nothing forever
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
