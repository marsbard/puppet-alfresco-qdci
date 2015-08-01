
cd "`dirname $0`"

if [ ! -d "puppet-alfresco" ]
then
	git clone https://github.com/marsbard/puppet-alfresco.git
	puppet-alfresco/install/modules-for-vagrant.sh
	mkdir modules/alfresco
	cp -r puppet-alfresco/manifests/* modules/alfresco
fi
vagrant up --provider=digital_ocean centos42f
