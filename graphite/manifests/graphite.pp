Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin"] }

class addproxy {
  file {"/etc/apt/apt.conf.d/01proxy":
    content => "Acquire::http::Proxy \"http://10.0.51.1:3142\";"
  }
  exec {"apt-get_update":
        command => "apt-get update",
        require => File["/etc/apt/apt.conf.d/01proxy"]
    }
}

class installpackage {
  require addproxy
  
  include graphite, runit, statsd, gunicorn, nginx
  #ssh, 
  #sudo, apt, postfix, mysql, apache,

#  package { ["vim", "lynx"]:
#    ensure => present,
#  }

  file { "/opt/deploy":
    owner => "root",
    group => "root",
    mode => 0644,
    ensure => directory,
  }

  nginx::resource::upstream { 'unicorn-upstream':
    ensure  => present,
    members => ['localhost:3000'],
    require => Class["addproxy","statsd", "graphite", "gunicorn", "runit"],
  }

  nginx::resource::vhost { '10.0.51.3':
    ensure => present,
    proxy  => 'http://unicorn-upstream',
    require => Class["addproxy","statsd", "graphite", "gunicorn", "runit"],
  }

}

class postsetupdb {
  require installpackage
  exec { "syncdb":
    command => "su -c 'python /opt/deploy/graphite/webapp/graphite/manage.py syncdb --noinput' www-data",
#    command => "su -c 'python /opt/deploy/graphite/webapp/graphite/manage.py syncdb --noinput' www-data && touch /opt/deploy/syncdb.graphite.done",
#    creates => "/opt/deploy/syncdb.graphite.done",
    creates => "/opt/deploy/graphite/storage/graphite.db",
  }
}

include addproxy
include installpackage
include postsetupdb
