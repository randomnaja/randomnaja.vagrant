class postgres {

	define install() {
		exec { 'install-repo' :
			command => 'rpm -ivh http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm',
			creates => '/etc/yum.repos.d/pgdg-92-redhat.repo',
			path => $path,
		}

		package { 'postgresql92-server.x86_64':
			require => Exec['install-repo'],
			ensure => present,
		}

		exec { 'initdb' :
			command => 'service postgresql-9.2 initdb',
			creates => '/var/lib/pgsql/9.2/data/PG_VERSION',
			path => $path,
			require => Package['postgresql92-server.x86_64'],
		}

		exec { 'enable-service' :
			command => 'chkconfig postgresql-9.2 on',
			creates => '/etc/rc2.d/S64postgresql-9.2',
			path => $path,
			require => Package['postgresql92-server.x86_64'],
		}

		service { 'postgresql-9.2' :
			ensure => 'running',
			require => [ Exec['initdb'] , Exec['enable-service'] ],
		}
	}
}