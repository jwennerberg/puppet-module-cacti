### Puppet module to manage cacti

class cacti (
    $standalone         = 'false',
    $auth_basic         = 'false',
    $auth_basic_group   = 'NONE',
    $db_name            = 'cacti',
    $db_host            = 'localhost',
    $db_user            = 'cacti',
    $db_pass            = 'password',
    $db_port            = '3306',
    $db_use_ssl         = 'false',
) {

    $standalone_type = type($standalone)
    if $standalone_type == "string" {
        $run_standalone = str2bool($standalone)
    }else{
        $run_standalone = $standalone
    }
    if $run_standalone == true {
        include 'apache'
    }
    
    $auth_basic_type = type($auth_basic)
    if $auth_basic_type == "string" {
        $use_auth_basic = str2bool($auth_basic)
    }else{
        $use_auth_basic = $auth_basic
    }
    if $use_auth_basic == true {
        $auth_pkgs = ['libapache2-mod-authnz-external', 'pwauth', 'libapache2-mod-authz-unixgroup']
        package {$auth_pkgs :
            ensure => installed,
        }
    }

    case $::operatingsystem {
        /^(Debian|Ubuntu)$/: {
            $pkg_name = "cacti"
        }
        default: {
            fail("Unsupported operating system ${::operatingsystem}")
        }
    }

    package { "cacti_pkg" :
        name => $pkg_name,
        ensure => installed,
        require => [ Class['apache'], Exec['populate-db'] ],
    }

    file {'/usr/share/cacti/site/include/config.php' : 
        ensure => present,
        content => template("cacti/config.php.erb"),
        require => Package['cacti_pkg'],
    }

    file {'/etc/apache2/conf.d/cacti.conf' :
        ensure => link,
        target => '/etc/cacti/apache.conf',
        require => File['/etc/cacti/apache.conf'],
    }

    file {'/etc/cacti/' :
        ensure => directory,
    }

    file {'/etc/cacti/apache.conf' :
        ensure => present,
        content => template('cacti/apache.conf.erb'),
        notify => Service['httpd'],
        require => File['/etc/cacti/'],
    }

    file {'/etc/cacti/debian.php' :
        ensure => present,
        content => template('cacti/debian.php.erb'),
        require => File['/etc/cacti/'],
    }

    file {'/usr/src/cactiInstall.sql' :
        ensure => present,
        source => "puppet:///modules/cacti/cactiInstall.sql",
    }

    file {'/usr/src/cactiWebbasic-settings.sql' :
        ensure => present,
        source => "puppet:///modules/cacti/cactiWebbasic-settings.sql",
    }

    file {'/usr/share/cacti' :
        ensure => directory,
    }

    exec {'populate-db' :
        command => "/usr/bin/mysql -p${db_pass} -u${db_user} -h ${db_host} -P ${db_port} ${db_name} < /usr/src/cactiInstall.sql; /usr/bin/mysql -p${db_pass} -u${db_user} -h ${db_host} -P ${db_port} ${db_name} < /usr/src/cactiInstall.sql && touch /usr/share/cacti/.dbInstalled",
        creates => "/usr/share/cacti/.dbInstalled",
        require => [ File['/usr/src/cactiInstall.sql'], File['/usr/src/cactiWebbasic-settings.sql'], File['/usr/share/cacti'] ],
    }

}
