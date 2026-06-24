#!/bin/bash
URL="http://tools.sensorweb.com.br:8080/monitor/2"
ORIGIN="http://tools.sensorweb.com.br:8080"
PROFILE="/tmp/chromium-kiosk"
export DISPLAY=:0
export XAUTHORITY=~/.Xauthority

until curl -s -I "$URL" > /dev/null 2>&1; do
  sleep 5
done

pkill -f chromium || true
rm -rf "$PROFILE"

/usr/lib/chromium/chromium \
  --user-data-dir="$PROFILE" \
  --no-first-run \
  --noerrdialogs \
  --disable-infobars \
  --block-new-web-contents \
  --disable-notifications \
  --deny-permission-prompts \
  --password-store=basic \
  --incognito \
  --kiosk \
  --disable-gpu \
  --disable-software-rasterizer \
  --disable-dev-shm-usage \
  --disable-skia-graphite \
  --use-gl=swiftshader \
  --allow-running-insecure-content \
  --unsafely-treat-insecure-origin-as-secure="$ORIGIN" \
  "$URL" > /dev/null 2>&1 &

sleep 15

# Dismiss Bootstrap modal every 10 seconds
# Close button coordinates based on 1920x1080 resolution
while true; do
  sleep 10
  DISPLAY=:0 XAUTHORITY=~/.Xauthority xdotool mousemove 916 179 click 1
  sleep 1
  DISPLAY=:0 XAUTHORITY=~/.Xauthority xdotool key Escape
done
