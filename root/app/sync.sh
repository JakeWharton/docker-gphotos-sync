#!/usr/bin/with-contenv sh

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "https://hc-ping.com/$HEALTHCHECK_ID/start"
fi

set -e

gphotos-cdp -v -dev -headless -dldir /download -run /app/fix_time.sh

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "https://hc-ping.com/$HEALTHCHECK_ID"
fi
