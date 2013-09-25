### Puppet module to manage cacti

class cacti (
    $standalone         = 'false',
    $mysql_server       = 'localhost',
) {

    $standalone_type = type($standalone)
    if $standalone_type == "string {
        $run_standalone = str2bool($standalone)
    }else{
        $run_standalone = $standalone
    }
    if $run_standalone == true {
        require 'apache'
        require 'mysql'
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
        options => norecommended,
        require => Class['apache']
    }

}
