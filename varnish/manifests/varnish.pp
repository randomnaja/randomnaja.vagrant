class varnish {
  package {'varnish':
    ensure => installed,
  }

  service {'varnish':
    ensure    => running,
    enable    => true,
    subscribe => Package['varnish'],
  }
}

define varnish::instance($address="",
                         $port="80",
                         $admin_address="127.0.0.1", 
                         $admin_port="6082", 
                         $storage="malloc,512m",
                         $nfiles="131072",
                         $memlock="82000",
                         $default_ttl="120",
                         $vcl_template="default.vcl.erb")
{
  include varnish

  file {'/etc/default/varnish':
    ensure  => present,
    content => template('varnish.erb'),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  file {'/etc/varnish/default.vcl':
    ensure  => present,
    content => template($vcl_template),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }
}

varnish::instance {'localhost':
	
}
