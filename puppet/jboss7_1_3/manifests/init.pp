class jboss7_1_3 {

	define download_and_setup($url, $target_dir, $root_dir, $src_target,
		$extension, $jbossuser="jboss") {

		archive { 'jboss-7-1-3':
			ensure => present,
			url    => $url,
			target => $target_dir,
			root_dir => $root_dir,
			checksum => false,
			src_target => $src_target,
			extension => $extension,
			require => Jbosssetup['jboss-setup'],
			path => $path,
		}

		file { 'jboss-init-script':
			path => '/etc/init.d/jboss',
			ensure => 'link',
			target => '/usr/local/jboss/jboss-as-7.1.3.Final/bin/init.d/jboss-as-standalone.sh',
			require => Archive['jboss-7-1-3'],
		}

		exec { 'set-jboss-service':
			command => 'chkconfig --add jboss && chkconfig jboss on',
			require => File['jboss-init-script'],
			creates => '/etc/rc.d/rc3.d/S80jboss',
			path => $path,
		}

		file { 'jboss-owner':
			path => '/usr/local/jboss/jboss-as-7.1.3.Final',
			ensure => 'present',
			recurse => true,
			owner => 'jboss',
			require => Archive['jboss-7-1-3'],
		}

		jboss7_1_3::jbosssetup { 'jboss-setup': 
			jbossuser => $jbossuser,
		}
		
	}

	define jbosssetup($jbossuser='jboss') {
		user { "jboss":
			name => "$jbossuser",
			ensure => 'present',
			groups => ['users'],
			home => '/usr/local/jboss',
			shell => '/sbin/nologin',
			uid => '9000',
		}

		$jboss_config_content = "
JBOSS_HOME=/usr/local/jboss/jboss-as-7.1.3.Final
JBOSS_PIDFILE=/var/run/jboss/jboss-as-standalone.pid
JBOSS_CONSOLE_LOG=/var/log/jboss/console.log
JBOSS_CONFIG=standalone-full-ha.xml
JBOSS_USER=$jbossuser
		"

		file { 'jboss-conf':
			path => '/etc/jboss-as/jboss-as.conf',
			ensure => 'file',
			content => "$jboss_config_content",
			require => [ User['jboss'] , File['jboss-conf-dir'] ],
		}

		file { 'jboss-pid-dir':
			path => '/var/run/jboss/',
			ensure => 'directory',
			owner => 'jboss',
			require => User['jboss'],
		}

		file { 'jboss-log-dir':
			path => '/var/log/jboss/',
			ensure => 'directory',
			owner => 'jboss',
			require => User['jboss'],
		}

		file { 'jboss-conf-dir':
			path => '/etc/jboss-as',
			ensure => 'directory',
			require => User['jboss'],
		}
	}

}