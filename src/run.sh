#! /bin/sh

set -eu

touch crontab.tmp \
    && echo "$SCHEDULE /backup.sh" >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp


touch /tmp/tmp_log.log

/usr/sbin/crond -f -L /tmp/tmp_log.log -d 0
