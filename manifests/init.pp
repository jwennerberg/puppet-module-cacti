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
        require 'apache'
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
        install_options => norecommended,
        require => Class['apache']
    }

    file {'/usr/share/cacti/site/include/conf.d/' :
        ensure => directory,
        require => Package['cacti_pkg'], 
    }

    file {'/usr/share/cacti/site/include/conf.d/database.php' :
        ensure => present,
        content => template('cacti/database.php.erb'),
        require => File['/usr/share/cacti/site/include/conf.d/'],
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

}
