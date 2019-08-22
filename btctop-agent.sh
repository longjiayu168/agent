#!/bin/bash
printf "btctop-agent代理安装："

num=039

wget https://raw.githubusercontent.com/longjiayu168/agent/master/agent-switch.zip

sudo apt-get -y install unzip
sudo apt-get -y install iptables-persistent
unzip -o agent-switch.zip
cd agent-switch

sudo mkdir -p /data/logs/btctop-agent-v6
sudo chown ubuntu /data

sudo cp -f btctop-agent-v6 /usr/bin/
sudo chmod +x /usr/bin/btctop-agent-v6

sudo cp -f libglog.so.0.0.0 /usr/local/lib/
sudo ln -s /usr/local/lib/libglog.so.0.0.0 /usr/local/lib/libglog.so.0
  
sudo cp -f libevent-2.0.so.5.1.9 /usr/local/lib/
sudo ln -s /usr/local/lib/libevent-2.0.so.5.1.9 /usr/local/lib/libevent-2.0.so.5
    
sudo cp -f libevent-2.1.so.6 /usr/local/lib/
#sudo ln -s /usr/local/lib/libglog.so.0.0.0 /usr/local/lib/libevent-2.1.so.6

sudo cp -f btctop-agent-v6.json /etc/

sudo apt-get -y install supervisor

[ -z "$(grep 'minfds=65535' /etc/supervisor/supervisord.conf)" ] && sed -i '11a minfds=65535' /etc/supervisor/supervisord.conf

sudo service supervisor restart

sudo cp -f btctop-agent-v6.conf /etc/supervisor/conf.d/


echo '0 * * * * find /data/logs/btctop-agent-v6/ -mtime +10 -exec rm {} \;' >/var/spool/cron/crontabs/ubuntu

#用 shell 获取本机的网卡名称

netname=$(ifconfig | grep  "Link" | awk '{print $1}' | head -n1)


cp /etc/network/interfaces /etc/network/interfaces.bak

#cat >/etc/network/interfaces.d/virt_network << EOF
#auto $netname:1
#iface $netname:1 inet dhcp
#address 192.168.3.150
#netmask 255.255.255.0
#gateway 192.168.3.1
#EOF

#sed -i '/source/d' /etc/network/interfaces

#echo 'source /etc/network/interfaces.d/*' >>/etc/network/interfaces

echo "btctop-agent-$num" >/etc/hostname

#让hostname立即生效
hostname $(cat /etc/hostname)

#判断是否设置本地127.0.0.1主机名解析
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1     $(hostname)@g" /etc/hosts


# -z string   字符长度为零则为真
[ -z "$(grep 'agent-reverse-proxy' /etc/hosts)" ] && echo "47.94.44.142  agent-reverse-proxy" >>/etc/hosts


cat >/etc/btctop-agent-v6.json << EOF
{
    "agent_listen_ip": "0.0.0.0",
    "agent_listen_port": 2222,
    "pools": [
        ["agentswitch.btc.top", 8888, "$(hostname)"]
    ]
}

EOF

chown -R ubuntu:ubuntu /home/ubuntu/

id_rsa="/home/ubuntu/.ssh/id_rsa"
if [ ! -e $id_rsa ];then
    /bin/su - ubuntu -c 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa'
    cat $id_rsa.pub
else
    cat $id_rsa.pub
fi

if [ -z "$(grep 'Asia/Shanghai' /home/ubuntu/.profile)" ];then
    echo "TZ='Asia/Shanghai'; export TZ" >> /home/ubuntu/.profile
fi
source /home/ubuntu/.profile

sudo apt-get -y install autossh

if [ -z "$(grep 'ubuntu' /etc/rc.local)" ];then
    sed -i '/exit/d' /etc/rc.local
	echo "/bin/su - ubuntu -c 'autossh -M 11$num -fN -o \"PubkeyAuthentication=yes\" -o \"StrictHostKeyChecking=false\" -o \"PasswordAuthentication=no\" -o \"ServerAliveInterval 60\" -o \"ServerAliveCountMax 3\" -R 10$num:localhost:22 agent@agent-reverse-proxy'">>/etc/rc.local
	echo "exit 0">>/etc/rc.local
fi



sudo iptables -t nat -F  # 清空nat表的所有链

#switch
sudo iptables -t nat -A PREROUTING -p tcp --dport 3333 -j REDIRECT --to 2222 --random
sudo iptables -t nat -A PREROUTING -p tcp --dport 8888 -j REDIRECT --to 2222 --random

sudo iptables -t nat -L -n
sudo netfilter-persistent save