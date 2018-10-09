require 'spec_helper'
describe 'cacti' do

  context 'with default params on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    it { should include_class('cacti')}

    it do
      should contain_package('cacti_pkg').with({
        'ensure' => 'installed',
        'name'   => ['cacti','net-snmp-utils'],
      })
    end

    it do
      should contain_file('db_config').with({
        'ensure' => 'present',
        'path'   => '/etc/cacti/db.php',
        'mode'   => '0644',
        'owner'  => 'cacti',
        'group'  => 'apache',
      })
      should contain_file('db_config').with_content(
%{<?php
/* # This file is being maintained by Puppet. */
/* # DO NOT EDIT */

/* make sure these values refect your actual database/host/user/password */
$database_type = "mysql";
$database_default = "cacti";
$database_hostname = "localhost";
$database_username = "cacti";
$database_password = "password";
$database_port = "3306";
$database_ssl = false;

?>
})
    end

    it do
      should contain_file('db_init_file').with({
        'ensure' => 'present',
        'path'   => '/usr/share/cacti/cacti.sql',
      })
    end

    it do
      should contain_file('cacti_base').with({
        'ensure' => 'directory',
        'path'   => '/usr/share/cacti',
        'mode'   => '0755',
        'owner'  => 'root',
        'group'  => 'root',
      })
    end

    it do
      should contain_file('httpd_cacti_config').with({
        'ensure' => 'present',
        'path'   => '/etc/httpd/conf.d/cacti.conf',
        'mode'   => '0644',
        'owner'  => 'root',
        'group'  => 'root',
      })
      should contain_file('httpd_cacti_config').with_content(/Alias \/cacti \/usr\/share\/cacti/)
    end

    it do
      should contain_file('crond_cacti').with({
        'ensure' => 'absent',
        'path'   => '/etc/cron.d/cacti',
      })
    end

    it do
      should contain_user('cacti_user').with({
        'ensure' => 'present',
        'name'   => 'cacti',
      })
    end

    it do
      should contain_cron('cacti_poller').with({
        'ensure'  => 'present',
        'user'    => 'cacti',
        'command' => '/usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1',
        'minute'  => '*/5',
      })
    end
  end
  context 'with packages set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :packages => 'cacti',
      }
    end
    it do
      should contain_package('cacti_pkg').with({
        'ensure' => 'installed',
        'name'   => 'cacti',
      })
    end
  end
  context 'with db_config_file_path set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :db_config_path => '/etc/cacti/database.php',
        :db_config_mode => '0640',
        :db_config_owner => 'www-data',
        :db_config_group => 'www-data',
      }
    end
    it do
      should contain_file('db_config').with({
        'ensure' => 'present',
        'path'   => '/etc/cacti/database.php',
        'mode'   => '0640',
        'owner'  => 'www-data',
        'group'  => 'www-data',
      })
    end
  end
  context 'with db_host, db_user, db_pass and db_port set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :db_host => 'mysqlhost.example.com',
        :db_user => 'cacti2',
        :db_pass => 'password123',
        :db_port => '3307',
      }
    end
    it do
      should contain_file('db_config').with({
        'ensure' => 'present',
        'path'   => '/etc/cacti/db.php',
        'mode'   => '0644',
        'owner'  => 'cacti',
        'group'  => 'apache',
      })
      should contain_file('db_config').with_content(
%{<?php
/* # This file is being maintained by Puppet. */
/* # DO NOT EDIT */

/* make sure these values refect your actual database/host/user/password */
$database_type = "mysql";
$database_default = "cacti";
$database_hostname = "mysqlhost.example.com";
$database_username = "cacti2";
$database_password = "password123";
$database_port = "3307";
$database_ssl = false;

?>
})
    end
  end
  context 'with httpd_config_path set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :httpd_config_path => '/etc/httpd/conf.d/cacti-site.conf',
        :httpd_config_mode => '0640',
      }
    end
    it do
      should contain_file('httpd_cacti_config').with({
        'ensure' => 'present',
        'path'   => '/etc/httpd/conf.d/cacti-site.conf',
        'mode'   => '0640',
      })
    end
  end
  context 'with poller_cron_command set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :poller_cron_command => 'php /usr/share/cacti/poller.php',
      }
    end
    it do
      should contain_cron('cacti_poller').with({
        'ensure'  => 'present',
        'user'    => 'cacti',
        'command' => 'php /usr/share/cacti/poller.php',
        'minute'  => '*/5',
      })
    end
  end
  context 'with poller_cron_minute set on osfamily RedHat' do
    let :facts do
      {
        :osfamily  => 'RedHat',
      }
    end
    let :params do
      {
        :poller_cron_minute => '*',
      }
    end
    it do
      should contain_cron('cacti_poller').with({
        'ensure'  => 'present',
        'user'    => 'cacti',
        'command' => '/usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1',
        'minute'  => '*',
      })
    end
  end
  context 'fail on unsupported osfamily' do
    let :facts do
      {
        :osfamily => 'Debian',
      }
    end
    it do
      expect {
        should include_class('cacti')
      }.to raise_error(Puppet::Error,/Module cacti is supported on osfamily RedHat. Your osfamily identified as Debian/)
    end
  end
end
