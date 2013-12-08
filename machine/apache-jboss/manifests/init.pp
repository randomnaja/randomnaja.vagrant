apache::mod_jk {'localhost': }

include openjdk

#$path="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"

jboss7_1_3::download_and_setup { 'jboss-download-and-setup':
	url => "file:///vagrant/files/jboss-as-7.1.3.Final.tar.bz2", 
	target_dir => '/usr/local/jboss', 
	root_dir => 'jboss-as-7.1.3.Final', 
	src_target => '/tmp',
	extension => 'tar.bz2', 
	jbossuser => "jboss",
}

postgres::install {	'postgres-install': }

# archive { 'jboss-7-1-3':
#   ensure => present,
#   url    => 'file:///vagrant/files/jboss-as-7.1.3.Final.tar.bz2',
#   target => '/usr/local/jboss',
#   root_dir => 'jboss-as-7.1.3.Final',
#   checksum => false,
#   src_target => '/tmp',
#   extension => 'tar.bz2',
#   require => Jbosssetup['jboss-setup'],
#   path => "$path",
# }

# file { 'jboss-init-script':
# 	path => '/etc/init.d/jboss',
# 	ensure => 'link',
# 	target => '/usr/local/jboss/jboss-as-7.1.3.Final/bin/init.d/jboss-as-standalone.sh',
# 	require => Archive['jboss-7-1-3'],
# }

# exec { 'set-jboss-service':
# 	command => 'chkconfig jboss',
# 	require => File['jboss-init-script'],
# 	path => "$path",
# }

# file { 'jboss-owner':
# 	path => '/usr/local/jboss/jboss-as-7.1.3.Final',
# 	ensure => 'present',
# 	recurse => true,
# 	owner => 'jboss',
# 	require => Archive['jboss-7-1-3'],
# }

# jbosssetup { 'jboss-setup':

# }

# define jbosssetup {
# 	user { 'jboss':
# 		ensure => 'present',
# 		groups => ['users'],
# 		home => '/usr/local/jboss',
# 		shell => '/sbin/nologin',
# 		uid => '9000',
# 	}

# 	$jboss_config_content = "
# JBOSS_HOME=/usr/local/jboss/jboss-as-7.1.3.Final
# JBOSS_PIDFILE=/var/run/jboss/jboss-as-standalone.pid
# JBOSS_CONSOLE_LOG=/var/log/jboss/console.log
# JBOSS_CONFIG=standalone-full-ha.xml
# JBOSS_USER=jboss
# 	"

# 	file { 'jboss-conf':
# 		path => '/etc/jboss-as/jboss-as.conf',
# 		ensure => 'file',
# 		content => "$jboss_config_content",
# 		require => [ User['jboss'] , File['jboss-conf-dir'] ],
# 	}

# 	file { 'jboss-pid-dir':
# 		path => '/var/run/jboss/',
# 		ensure => 'directory',
# 		owner => 'jboss',
# 		require => User['jboss'],
# 	}

# 	file { 'jboss-log-dir':
# 		path => '/var/log/jboss/',
# 		ensure => 'directory',
# 		owner => 'jboss',
# 		require => User['jboss'],
# 	}

# 	file { 'jboss-conf-dir':
# 		path => '/etc/jboss-as',
# 		ensure => 'directory',
# 		require => User['jboss'],
# 	}
# }