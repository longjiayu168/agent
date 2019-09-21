#!/bin/bash
printf "btctop-agent FRP安装："
if [[ ! -f frp_0.28.2_linux_amd64.tar.gz ]]; then
    echo -n " downloading frp: "
    wget http://122.112.156.142/frp_0.28.2_linux_amd64.tar.gz
fi
tar -zxvf frp_0.28.2_linux_amd64.tar.gz
cd frp_0.28.2_linux_amd64
sed -i '2s/127.0.0.1/122.112.156.142/g' frpc.ini
./frpc 
