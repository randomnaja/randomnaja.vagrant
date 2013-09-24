randomnaja.vagrant
==================

## Prerequisite
* Vagrant [http://downloads.vagrantup.com/](http://downloads.vagrantup.com/)
* Virtualbox [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)

## Packages
* mongodb
    
    MongoDB + enable rest interface

* varnish

    Varnish + pre-configure of __hydra__ load balancing, this module might be too specific for certain application
     but you can extend it or customize it to suit your own need

* graphite
	
	To test the puppet manually
		puppet apply --verbose --debug --modulepath '/etc/puppet/modules:/tmp/vagrant-puppet/modules-0' --detailed-exitcodes /tmp/vagrant-puppet/manifests/graphite.pp || [ $? -eq 2 ]