#!/bin/bash
printf "btctop-agent FRP安装："
cd /home/ubuntu
if [[ ! -f frp_0.28.2_linux_amd64.tar.gz ]]; then
    echo -n " downloading frp: "
    wget https://121.40.180.105:6441/longsoft/frp_0.28.2_linux_amd64.tar.gz --no-check-certificate
fi
tar -zxvf frp_0.28.2_linux_amd64.tar.gz
cd frp_0.28.2_linux_amd64
sed -i '2s/127.0.0.1/121.40.180.105/g' frpc.ini
sed -i 's#/usr/bin/#/home/ubuntu/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
sed -i 's#/etc/frp/#/home/ubuntu/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
sudo cp ./systemd/frpc.service /lib/systemd/system
sudo systemctl enable frpc.service
sudo systemctl start frpc.service
#./frpc 
