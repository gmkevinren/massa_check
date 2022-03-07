sudo apt install jq bc -y

nano massa_check.sh
#修改节点地址


# 增加权限
chmod +x massa_check.sh

# 添加服务

sudo tee <<EOF >/dev/null /etc/systemd/system/massacheck.service
[Unit]
Description=massa check
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/massa_check.sh
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

# Enable and run

sudo systemctl daemon-reload
sudo systemctl enable massacheck
sudo systemctl restart massacheck

# Logs

sudo journalctl -u massacheck -f
