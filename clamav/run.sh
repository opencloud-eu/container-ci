#!/bin/bash

mkdir -p /run/clamav /var/lib/clamav
chown clamav:clamav /run/clamav /var/lib/clamav

if [ ! -f /var/lib/clamav/main.cvd ]; then
    freshclam --stdout
fi

freshclam -d --checks=1 &

exec clamd