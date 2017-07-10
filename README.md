This script is based on the install script from André Schenkels (https://github.com/aschenkels-ictstudio/openerp-install-scripts)
but goes a bit further. This script will also give you the ability to define an xmlrpc_port in the .conf file that is generated under /etc/
This script can be safely used in a multi-odoo code base server because the default Odoo port is changed BEFORE the Odoo is started.

<h3>Installation procedure</h3>
1. Download the script: 

sudo wget https://raw.githubusercontent.com/ShaheenHossain/eagle-install-backup/10.0/eagle__test_install.sh

2. Make the script executable:
sudo chmod +x eagle_test_install.sh

3. Execute the script:
sudo ./eagle_test_install.sh
```
