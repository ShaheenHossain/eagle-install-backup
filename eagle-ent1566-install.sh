
OE_USER="eagle1566"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_PORT="8066"
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"
OE_VERSION="master"

OE_MAIN_SERVER="eagleent1457"
OE_MAIN_SERVER_CONF="${OE_MAIN_SERVER}-server"

LONGPOLLING_PORT="8072"
ADMIN_EMAIL="rapidgrps@gmail.com"

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
# universe package is for Ubuntu 18.x
sudo add-apt-repository universe
# libpng12-0 dependency for wkhtmltopdf
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql postgresql-server-dev-all -y

echo -e "\n---- Creating the Eagle PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true


echo -e "\n---- Create EAGLE system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'EAGLE1568' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install EAGLE
#--------------------------------------------------
echo -e "\n==== Installing EAGLE Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/ShaheenHossain/eagleblank $OE_HOME_EXT/


echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"


sudo touch /etc/${OE_CONFIG}.conf
echo -e "* Creating server config file"
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = ${OE_PORT}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'logfile = /var/log/${OE_USER}/${OE_CONFIG}.log\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'addons_path=${OE_HOME_EXT}/unozio/addons,${OE_HOME}/custom/addons\n' >> /etc/${OE_CONFIG}.conf"

sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/unozio-bin --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Adding Eagle as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: Eagle Business Applications
### END INIT INFO
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
DAEMON=$OE_HOME_EXT/unozio-bin
NAME=$OE_CONFIG
DESC=$OE_CONFIG
# Specify the user name (Default: odoo).
USER=$OE_USER
# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"
# pidfile
PIDFILE=/var/run/\${NAME}.pid
# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}
case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;
restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
sleep 1
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;
esac
exit 0
EOF

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Start EAGLE on Startup"
sudo update-rc.d $OE_CONFIG defaults


echo -e "* Starting Eagle Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Eagle server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "Configuraton file location: /etc/${OE_CONFIG}.conf"
echo "Logfile location: /var/log/$OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/unozio/addons/"
echo "Password superadmin (database): $OE_SUPERADMIN"
echo "Start Eagle service: sudo service $OE_CONFIG start"
echo "Stop Eagle service: sudo service $OE_CONFIG stop"
echo "Restart Eagle service: sudo service $OE_CONFIG restart"

echo "-----------------------------------------------------------"
