#!/bin/bash

TZ=${TZ:-Etc/UTC}

echo --------------------------------------------------
echo "Setting up Timzone: \"${TZ}\""
echo --------------------------------------------------
echo $TZ | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

set -ex

CRON_TIMING=${CRON_TIMING:-'* * * * *'}

# Reload Cron
echo "${CRON_TIMING} /usr/bin/php5 /var/www/html/front/cron.php &>/dev/null" | crontab -
/etc/init.d/cron reload
/etc/init.d/cron restart

exec "$@"
