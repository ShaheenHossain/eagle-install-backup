This script is based on the install script from André Schenkels (https://github.com/aschenkels-ictstudio/openerp-install-scripts)
but goes a bit further. This script will also give you the ability to define an xmlrpc_port in the .conf file that is generated under /etc/
This script can be safely used in a multi-odoo code base server because the default Odoo port is changed BEFORE the Odoo is started.


<h2>Dependency Pandas </h2>

<h3>Installation procedure 11</h3>


sudo wget https://raw.githubusercontent.com/ShaheenHossain/eagle-install-backup/dev1233/eagle-dev1233-install.sh

sudo chmod +x eagle-dev1233-install.sh

sudo ./eagle-dev1233-install.sh

----------------------------------------------

sudo /etc/init.d/deveagle1233-server stop


```
