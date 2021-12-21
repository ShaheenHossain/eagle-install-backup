OE_USER="ecent1561"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
INSTALL_WKHTMLTOPDF="True"

OE_PORT="8061"
# IMPORTANT! This script contains extra libraries that are specifically needed for Eagle 15.0
OE_VERSION="15.0"

OE_SUPERADMIN="admin"
# Set to "True" to generate a random password, "False" to use the variable in OE_SUPERADMIN
OE_CONFIG="${OE_USER}-server"
# Set the website name
WEBSITE_NAME="_"
LONGPOLLING_PORT="8072"
# Provide Email to register ssl certificate
ADMIN_EMAIL="rapidgrps@gmail.com"

#sudo yum -y install https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.centos7.x86_64.rpm

#WKHTMLTOX_X64=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.centos7.x86_64.rpm
#WKHTMLTOX_X32=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.centos7.i386.deb
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo yum -y install epel-release

# libpng12-0 dependency for wkhtmltopdf
# sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"

sudo yum update -y
sudo yum upgrade -y

sudo yum install epel-release wget git gcc libxslt-devel bzip2-devel openldap-devel libjpeg-devel freetype-devel -y

sudo yum install python-pip -y
#sudo pip install --upgrade pip
sudo pip install --upgrade setuptools
sudo pip install Babel decorator docutils ebaysdk feedparser gevent greenlet jcconv Jinja2 lxml Mako MarkupSafe mock ofxparse passlib Pillow psutil psycogreen psycopg2-binary pydot pyparsing pyPdf pyserial Python-Chart python-dateutil python-ldap python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug wsgiref XlsxWriter xlwt xlrd
sudo pip install -r https://raw.githubusercontent.com/odoo/odoo/15.0/requirements.txt
sudo yum install python39 -y

sudo yum install python36 python36-devel

sudo yum -y install git gcc wget nodejs libxslt-devel bzip2-devel openldap-devel libjpeg-devel freetype-devel

sudo yum install python36-devel libxslt-devel libxml2-devel openldap-devel python36-setuptools python-devel -y
python3.6 -m ensurepip
sudo pip3 install pypdf2 Babel passlib Werkzeug decorator python-dateutil pyyaml psycopg2-binary psutil html2text docutils lxml pillow reportlab ninja2 requests gdata XlsxWriter vobject python-openid pyparsing pydot mock mako Jinja2 ebaysdk feedparser xlwt psycogreen suds-jurko pytz pyusb greenlet xlrd num2words
sudo pip3 install -r https://raw.githubusercontent.com/odoo/odoo/15.0/requirements.txt

echo -e "\n--- Install other required packages"
sudo yum install nodejs npm -y
sudo npm install -g less
sudo npm install -g less-plugin-clean-css
sudo npm install -g rtlcss

sudo yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
sudo yum install postgresql13 postgresql13-server postgresql13-contrib postgresql13-libs -y
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb

sudo systemctl start postgresql-13.service
sudo systemctl enable postgresql-13.service

sudo su - postgres -c "createuser -s $OE_USER"
sudo useradd -m -U -r -d $OE_HOME -s /bin/bash $OE_USER

sudo yum install wkhtmltopdf -y

#sudo yum -y install https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.centos7.x86_64.rpm

sudo mkdir /var/log/$OE_USER


#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_HOME_EXT/


sudo mv $OE_HOME_EXT/odoo.py $OE_HOME_EXT/odoo-bin
sudo mkdir $OE_HOME/custom
sudo mkdir $OE_HOME/custom/addons


sudo su root -c "touch '$OE_CONFIG'"

sudo su root -c "echo "[options]" >> $OE_CONFIG"
sudo su root -c "echo ';This is the password that allows database operations:' >> $OE_CONFIG"
sudo su root -c "echo 'admin_passwd = $OE_MASTER_PASSWD' >> $OE_CONFIG"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> $OE_CONFIG"
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_USER.log' >> $OE_CONFIG"

sudo chmod 640 $OE_CONFIG

echo -e "\n---- Creating systemd config file"
sudo touch /etc/systemd/system/$OE_USER.service

sudo su root -c "echo "[Unit]" >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'Description=Odoo server' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo '#Requires=postgresql-9.6.service' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo '#After=network.target postgresql-9.6.service' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo "[Service]" >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'Type=simple' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'SyslogIdentifier=odoo15' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'PermissionsStartOnly=true' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'User=$OE_USER' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'Group=$OE_USER' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'ExecStart=$OE_HOME/$OE_USER/odoo-bin -c /etc/$OE_USER.conf' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'StandardOutput=journal+console' >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo "[Install]" >> /etc/systemd/system/$OE_USER.service"
sudo su root -c "echo 'WantedBy=multi-user.target' >> /etc/systemd/system/$OE_USER.service"


echo -e "\n---- Start OE on Startup"
sudo chmod +x /etc/systemd/system/$OE_USER.service
sudo systemctl daemon-reload

sudo chown -R $OE_USER: $OE_HOME
sudo chown $OE_USER: $OE_CONFIG

echo -e "\n---- Starting Odoo Service"

sudo systemctl start $OE_USER.service
sudo systemctl enable $OE_USER.service
sudo systemctl status $OE_USER.service

echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "-----------------------------------------------------------"
echo "Port: $OE_PORT"
echo "Master password: $OE_MASTER_PASSWD"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Addons folder: $OE_HOME_EXT/addons and $OE_HOME/custom/addons"
echo "Start Odoo service: service $OE_USER start"
echo "Stop Odoo service: service $OE_USER stop"
echo "Restart Odoo service: service $OE_USER restart"


