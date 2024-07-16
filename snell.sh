#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

CONF="/etc/snell/snell-server.conf"
SYSTEMD="/etc/systemd/system/snell.service"

apt-get install unzip -y
wget --no-check-certificate -O snell.zip https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-amd64.zip
unzip -o snell.zip
rm -f snell.zip
chmod +x snell-server
mv -f snell-server /usr/local/bin/

if [ ! -f ${CONF} ]; then
  mkdir -p /etc/snell/
  snell-server --wizard -c ${CONF}
  cat ${CONF}
fi

if [ -f ${SYSTEMD} ]; then
  echo "Found existing service..."
  systemctl daemon-reload
  systemctl restart snell
else
  echo "Generating new service..."
  tee ${SYSTEMD} > /dev/null <<EOL
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
LimitNOFILE=32768
ExecStart=/usr/local/bin/snell-server -c /etc/snell/snell-server.conf

[Install]
WantedBy=multi-user.target
EOL
  systemctl daemon-reload
  systemctl enable snell
  systemctl start snell
fi
