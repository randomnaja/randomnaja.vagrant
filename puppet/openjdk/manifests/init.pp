# Curently only support CentOS (using `yum` to install)
class openjdk {

	stage { "setup": before => Stage[main] }

	class { "openjdk::setup":
		stage => setup
	}

	class { "openjdk::install":
		stage => main,
        require => Class[ "openjdk::setup" ],
	}
	
}
