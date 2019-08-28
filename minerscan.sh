#!/bin/bash

sudo apt-get update 
sudo apt-get install curl git vim
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install log4js
npm install command-line-args
npm install ali-oss
git clone https://gitee.com/btcqsb/collect-miner-stat.git
cd collect-miner-stat/
touch path_to_ip_files.txt
echo '*/30 * * * * time /usr/bin/node /home/ubuntu/collect-miner-stat/collect.js -a 50 -k LTAI8HYNFWJyUHbG -s b1pRWAUxGOLC7NZ314tKw4EhauDGLU -p 4028 -c pools,stats,summary -t 128 -f /home/ubuntu/collect-miner-stat/path_to_ip_files.txt > /tmp/collect.log' >> /var/spool/cron/crontabs/ubuntu