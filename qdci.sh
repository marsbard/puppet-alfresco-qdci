
cd "`dirname $0`"

if [ ! -d "puppet-alfresco/modules" ]
then
	pushd puppet-alfresco
	install/modules-for-vagrant.sh
	popd
fi

vagrant up --provider=digital_ocean centos42f
