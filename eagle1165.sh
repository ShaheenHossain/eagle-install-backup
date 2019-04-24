#!/bin/bash
# Copyright 2018 odooerpcloud.com 

OE_USER="eagle1165"
DIR_PATH=$(pwd)
VCODE=11
VERSION=11.0
PORT=8069
PATHBASE=/$OE_USER
PATH_LOG=/$OE_USER/log
PATHREPOS=/$OE_USER/custom/addons
PATHREPOS_OCA=/$OE_USER/custom/addons/oca

wk64="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -cs)_amd64.deb"
wk32="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -cs)_i386.deb"

sudo adduser --system --quiet --shell=/bin/bash --home=$PATHBASE --gecos 'EAGLE1165' --group $OE_USER
sudo adduser $OE_USER sudo

# add universe repository & update (Fix error download libraries)
sudo add-apt-repository universe
sudo apt-get update
# sudo apt-get -y upgrade
sudo apt-get install -y git
# Update and install Postgresql
sudo apt-get install postgresql -y
sudo su - postgres -c "createuser -s $OE_USER"

sudo mkdir $PATHBASE
sudo mkdir $PATH_LOG
sudo mkdir $PATHREPOS
sudo mkdir $PATHREPOS_OCA
cd $PATHBASE
# Download Odoo from git source
sudo git clone --depth 1 --branch $VERSION https://github.com/ShaheenHossain/eagle11 $OE_USER

# sudo git clone --depth 1 --branch $VERSION https://github.com/ShaheenHossain/eagle11

# Install python3 and dependencies for Odoo
sudo apt-get -y install gcc python3-dev libxml2-dev libxslt1-dev \
 libevent-dev libsasl2-dev libldap2-dev libpq-dev \
 libpng-dev libjpeg-dev

sudo apt-get -y install python3 python3-pip python-pip
sudo pip3 install libsass vobject qrcode num2words setuptools

# FIX wkhtml* dependencie Ubuntu Server 18.04
sudo apt-get -y install libxrender1

# Install nodejs and less
sudo apt-get install -y npm node-less
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less

# Download & install WKHTMLTOPDF
sudo rm $PATHBASE/wkhtmltox_0.12.5-1*.deb
sudo rm wkhtmltox_0.12.5-1*.deb
if [[ "`getconf LONG_BIT`" == "32" ]];

then
	sudo wget $wk32
	wkhtmltox_0.12.5-1.bionic_amd64.deb
else
	sudo wget $wk64
fi

sudo dpkg -i --force-depends wkhtmltox_0.12.5-1*.deb
sudo ln -s /usr/local/bin/wkhtml* /usr/bin


# install python requirements file (Odoo)
sudo pip3 install -r $PATHBASE/$VERSION/eagle1165/requirements.txt
sudo apt-get -f -y install

cd $DIR_PATH

sudo mkdir /opt/config
sudo rm /opt/config/odoo$VCODE.conf
sudo touch /opt/config/odoo$VCODE.conf

echo "
[options]
; This is the password that allows database operations:
;admin_passwd =
db_host = False
db_port = False
;db_user =
;db_password =
data_dir = $PATHBASE/data
logfile= $PATHBASE/log/odoo$VCODE-server.log

############# addons path ######################################

addons_path = $PATHREPOS,$PATHBASE/$VERSION/odoo/addons

#################################################################

xmlrpc_port = $PORT
;dbfilter = odoo
logrotate = True
limit_time_real = 1000
limit_time_cpu = 1000
" | sudo tee --append /opt/config/odoo$VCODE.conf

sudo rm /etc/systemd/system/odoo$VCODE.service
sudo touch /etc/systemd/system/odoo$VCODE.service
sudo chmod +x /etc/systemd/system/odoo$VCODE.service
echo "
[Unit]
Description=odoo11
After=postgresql.service

[Service]
Type=simple
User=odoo
ExecStart=$PATHBASE/$VERSION/odoo/odoo-bin --config /opt/config/odoo$VCODE.conf

[Install]
WantedBy=multi-user.target
" | sudo tee --append /etc/systemd/system/odoo$VCODE.service
sudo systemctl daemon-reload
sudo systemctl enable odoo$VCODE.service
sudo systemctl start odoo$VCODE

sudo chown -R $user: $PATHBASE
sudo chown -R $user: /opt/config


echo "Odoo $VERSION Installation has finished!! ;) by odooerpcloud.com"

