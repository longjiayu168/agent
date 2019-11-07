#!/bin/bash
printf "btctop-agent FRP安装："
cd /root
if [[ ! -f frp_0.28.2_linux_amd64.tar.gz ]]; then
    curl -L -k -o /root/frp_0.28.2_linux_amd64.tar.gz https://121.40.180.105:6441/longsoft/frp_0.28.2_linux_amd64.tar.gz
fi
tar -zxvf frp_0.28.2_linux_amd64.tar.gz
cd frp_0.28.2_linux_amd64
sed -i '2s/127.0.0.1/121.40.180.105/g' frpc.ini
[ -z "$(grep 'token = btctopscan' frpc.ini)" ] && sed -i '3a token = btctopscan' frpc.ini
sed -i 's#/usr/bin/#/root/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
sed -i 's#/etc/frp/#/root/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
sed -i 's/User=nobody/\#User=nobody/' ./systemd/frpc.service
sudo cp ./systemd/frpc.service /lib/systemd/system
sudo systemctl enable frpc.service
sudo systemctl start frpc.service