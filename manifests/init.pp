### Puppet module to manage cacti

class cacti (
  $cacti_base_path     = '/usr/share/cacti',
  $cacti_base_mode     = '0755',
  $cacti_base_owner    = 'root',
  $cacti_base_group    = 'root',
  $cacti_user          = 'USE_DEFAULT',
  $db_config_path      = 'USE_DEFAULT',
  $db_config_mode      = '0644',
  $db_config_owner     = 'USE_DEFAULT',
  $db_config_group     = 'USE_DEFAULT',
  $db_name             = 'cacti',
  $db_host             = 'localhost',
  $db_user             = 'cacti',
  $db_pass             = 'password',
  $db_port             = '3306',
  $db_use_ssl          = false,
  $httpd_config_path   = 'USE_DEFAULT',
  $httpd_config_mode   = '0644',
  $httpd_config_owner  = 'root',
  $httpd_config_group  = 'root',
  $packages            = 'USE_DEFAULT',
  $poller_cron_command = 'USE_DEFAULT',
  $poller_cron_minute  = '*/5',
) {

  include apache

  case $::osfamily {
    'RedHat': {
      $httpd_config_template = 'cacti/httpd_cacti.conf.erb'
      $default_packages = ['cacti','net-snmp-utils','php-gd']
      $default_cacti_user = 'cacti'
      $default_db_config_path = '/etc/cacti/db.php'
      $default_db_config_owner = 'cacti'
      $default_db_config_group = 'apache'
      $default_httpd_config_path = '/etc/httpd/conf.d/cacti.conf'
      $default_poller_cron_command = '/usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1'
    }
    default: {
      fail("Module cacti is supported on osfamily RedHat. Your osfamily identified as ${::osfamily}")
    }
  }

  if $packages == 'USE_DEFAULT' {
    $my_packages = $default_packages
  } else {
    $my_packages = $packages
  }

  if $cacti_user == 'USE_DEFAULT' {
    $my_cacti_user = $default_cacti_user
  } else {
    $my_cacti_user = $cacti_user
  }

  if $db_config_path == 'USE_DEFAULT' {
    $my_db_config_path = $default_db_config_path
  } else {
    $my_db_config_path = $db_config_path
  }

  if $db_config_path == 'USE_DEFAULT' {
    $my_db_config_owner = $default_db_config_owner
  } else {
    $my_db_config_owner = $db_config_owner
  }

  if $db_config_path == 'USE_DEFAULT' {
    $my_db_config_group = $default_db_config_group
  } else {
    $my_db_config_group = $db_config_group
  }

  if $httpd_config_path == 'USE_DEFAULT' {
    $my_httpd_config_path = $default_httpd_config_path
  } else {
    $my_httpd_config_path = $httpd_config_path
  }

  if $poller_cron_command == 'USE_DEFAULT' {
    $my_poller_cron_command = $default_poller_cron_command
  } else {
    $my_poller_cron_command = $poller_cron_command
  }

  package { 'cacti_pkg':
    ensure  => installed,
    name    => $my_packages,
  }

  file { 'db_config':
    ensure  => present,
    path    => $my_db_config_path,
    mode    => $db_config_mode,
    owner   => $my_db_config_owner,
    group   => $my_db_config_group,
    content => template('cacti/db.php.erb'),
    require => Package['cacti_pkg'],
  }

  file { 'httpd_cacti_config':
    ensure  => present,
    path    => $my_httpd_config_path,
    mode    => $httpd_config_mode,
    owner   => $httpd_config_owner,
    group   => $httpd_config_group,
    content => template($httpd_config_template),
    require => File['cacti_base'],
    notify  => Service['httpd'],
  }

  file { 'cacti_base':
    ensure  => directory,
    path    => $cacti_base_path,
    mode    => $cacti_base_mode,
    owner   => $cacti_base_owner,
    group   => $cacti_base_group,
    require => Package['cacti_pkg'],
  }

  file { 'db_init_file':
    ensure  => present,
    path    => "${cacti_base_path}/cacti.sql",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/cacti/cacti.sql',
    require => File['cacti_base'],
  }

  file { 'crond_cacti':
    ensure  => absent,
    path    => '/etc/cron.d/cacti',
    require => Package['cacti_pkg'],
  }

  user { 'cacti_user':
    ensure  => present,
    name    => $my_cacti_user,
    require => Package['cacti_pkg'],
  }

  cron { 'cacti_poller':
    ensure  => present,
    command => $my_poller_cron_command,
    user    => $my_cacti_user,
    minute  => $poller_cron_minute,
    require => User['cacti_user'],
  }

  exec { 'db_init':
    path    => '/bin:/usr/bin:/usr/local/bin',
    command => "mysql -p${db_pass} -u${db_user} -h ${db_host} -P ${db_port} ${db_name} < ${cacti_base_path}/cacti.sql && touch ${cacti_base_path}/.dbInstalled",
    creates => "${cacti_base_path}/.dbInstalled",
    require => File['db_init_file'],
  }
}
