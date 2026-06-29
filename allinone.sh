#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Esse script precisa de privilégios de administrador."
  # re-executa o programa pedindo sudo.
  exec sudo "$0" "$@"
fi

apt install --no-install-recommends xinit openbox chromium curl xdotool scrot -y

if [systemctl get-default -ne multi-user.target]; then
    echo "GUI ainda habilitada; Reconfigurando na força"
    systemctl disable lightdm
    systemctl mask lightdm
    systemctl set-default multi-user.target
    systemctl daemon-reload

mkdir -p /etc/systemd/system/getty@tty1.service.d
echo <<'EOF'> /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
EOF

echo <<'EOF' > loginmanagerlogic.sh
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
EOF

cat ~/.bash_profile loginmanager.sh | echo ~/.bash_profile

echo "exec openbox-session" > ~/.xinitrc

mv /etc/X11/xinit/xinitrc /etc/X11/xinit/xinitrc.bak

mkdir -p ~/.config/openbox

echo <<'EOF'> ~/.config/openbox/autostart
xset s off
xset s noblank
xset -dpms
/home/pi/djangotv.sh &
EOF

chmod +x ~/.config/openbox/autostart

echo <<'EOF'>~/djangotv.sh
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
EOF

chmod +x ~/djangotv.sh

echo "Processo finalizado com sucesso! Gostaria de reiniciar para implementar a aplicação?"

read -p "S/N: " ifReboot

if ifReboot = S || s || y || Y; then 
  reboot
else
  echo "Lembre-se que o programa só funcionará a partir do reboot."
  echo "finalizando programa"

