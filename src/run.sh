#! /bin/sh

set -eu

touch crontab.tmp \
    && echo "$SCHEDULE /backup.sh" >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

/usr/sbin/crond -f -d 0
