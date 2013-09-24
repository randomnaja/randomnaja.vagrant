Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin"] }

class updateapt {
  exec {"apt-get_update":
    command => "apt-get update"
  }
}

class installpackage {

#ssh, 
  include updateapt, graphite, runit, statsd, gunicorn, nginx
  #sudo, apt, postfix, mysql, apache,

  package { ["vim", "lynx"]:
    ensure => present,
  }

  file { "/opt/deploy":
    owner => "root",
    group => "root",
    mode => 0644,
    ensure => directory,
  }

#  nginx::resource::upstream { 'unicorn-upstream':
#    ensure  => present,
#    members => ['localhost:3000'],
#    require => Class["statsd", "graphite", "gunicorn", "runit"],
#  }

#  nginx::resource::vhost { '10.0.51.3':
#    ensure => present,
#    proxy  => 'http://unicorn-upstream',
#    require => Class["statsd", "graphite", "gunicorn", "runit"],
#  }

}

class postsetupdb {
  exec { "syncdb":
    command => "sudo -u graphite python /opt/deploy/graphite/webapp/graphite/manage.py syncdb --noinput && sudo touch /opt/deploy/syncdb.graphite.done",
    creates => "/opt/deploy/syncdb.graphite.done"
  }
}

include installpackage
#include postsetupdb
