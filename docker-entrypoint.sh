#!/bin/bash

set -ex

CRON_TIMING=${CRON_TIMING:-'* * * * *'}

# Reload Cron
echo "${CRON_TIMING} /usr/bin/php5 /var/www/html/front/cron.php &>/dev/null" | crontab -
/etc/init.d/cron reload
/etc/init.d/cron restart

exec "$@"
