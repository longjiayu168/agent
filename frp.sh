#!/bin/bash
printf "btctop-agent FRP安装："
if [[ ! -f frp_0.28.2_linux_amd64.tar.gz ]]; then
    echo -n " downloading frp: "
    wget http://py8jwnf5c.bkt.clouddn.com/frp_0.28.2_linux_amd64.tar.gz
fi
tar -zxvf frp_0.28.2_linux_amd64.tar.gz
cd frp_0.28.2_linux_amd64
sed -i '2s/127.0.0.1/121.40.180.105/g' frpc.ini
sed -i 's#/usr/bin/#/home/ubuntu/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
sed -i 's#/etc/frp/#/home/ubuntu/frp_0.28.2_linux_amd64/#' ./systemd/frpc.service
cp ./systemd/frpc.service /lib/systemd/system
systemctl enable frpc.service
#./frpc 
