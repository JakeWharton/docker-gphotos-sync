#!/bin/sh

if [ ! -d /tmp/gphotos-cdp ]; then
  echo "ERROR: '/tmp/gphotos-cdp' directory must be mounted"
  exit 1
fi
if [ ! -d /download ]; then
  echo "ERROR: '/download' directory must be mounted"
  exit 1
fi

set -e

if [ ! -z "$TZ" ]; then
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
fi

rm -f /tmp/sync.pid

if [ -z "$CRON" ]; then
  echo "INFO: No CRON setting found. Running sync once."
  echo "INFO: Add CRON=\"0 0 * * *\" to perform sync every midnight"
  /sync.sh
else
  # Set up the cron schedule.
  crontab -d
  echo "$CRON /sync.sh >>/tmp/sync.log 2>&1" > /tmp/crontab.tmp
  crontab /tmp/crontab.tmp
  rm /tmp/crontab.tmp

  echo "INFO: Starting crond ..."
  touch /tmp/sync.log
  touch /tmp/crond.log
  crond -b -l 0 -L /tmp/crond.log
  echo "INFO: crond started"
  tail -F /tmp/crond.log /tmp/sync.log
fi
