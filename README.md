puppet-module-cacti
===================

Puppet module to manage Cacti

===

Compatibility
-------------

This module has been tested to work on the following systems using Puppet v3 and Ruby 1.8.7

 * EL 6

Dependencies
------------

Some functionality is dependent on other modules:

- [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
- [puppetlabs/apache](https://github.com/puppetlabs/puppetlabs-apache)

# Parameters

cacti_base_path
---------------
Base installation path for Cacti

- *Default*: '/usr/share/cacti'

cacti_base_mode
---------------
Cacti base path's mode

- *Default*: '0755'

cacti_base_owner
----------------
Cacti base path's owner

- *Default*: 'root'

cacti_base_group
----------------
Cacti base path's group

- *Default*: 'root'

cacti_user
----------
Name of cacti user

- *Default*: 'USE_DEFAULT' (Use OS default)

db_config_path
--------------
Path to database config file

- *Default*: '/etc/cacti/db.php'

db_config_mode
---------------
Database config file mode

- *Default*: 0755

db_config_owner
---------------
Database config file owner

- *Default*: root

db_config_group
---------------
Database config file group

- *Default*: root

db_name
-------
Name of mysql database

- *Default*: 'cacti'

db_host
-------
Mysql server to connect to

- *Default*: 'localhost'

db_user
-------
Mysql username

- *Default*: 'cacti'

db_pass
-------
Mysql password

- *Default*: 'password'

db_port
-------
Mysql port

- *Default*: '3306'

db_use_ssl
----------
Use SSL for mysql

- *Default*: false

httpd_config_path
-----------------
Path to Cacti apache config file

- *Default*: 'USE_DEFAULT' (Use OS default)

httpd_config_mode
-----------------
Cacti apache config file mode

- *Default*: 0644

httpd_config_owner
------------------
Cacti apache config file owner

- *Default*: 'root'

httpd_config_group
------------------
Cacti apache config file group

- *Default*: 'root'

packages
--------
Packages to install

- *Default*: 'USE_DEFAULT' (Use OS default package names)

poller_cron_command
-------------------
Cacti poller command to run in crontab

- *Default*: 'USE_DEFAULT' (Use OS default poller command)

poller_cron_minute
------------------
Minute of hour to run poller cronjob

- *Default*: '*/5'
