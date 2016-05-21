#!/bin/bash

cd "`dirname $0`/.."

. bin/vagscp.inc.sh

MACHINES="centos42f centos50x ubuntu42f ubuntu50x"

if [ "$1" = "" ]
then
	echo "Please provide name of branch to test, e.g. 'dev-1.3' or 'master'"
	exit
fi

BRANCH=$1

rm -rf .suite
for mach in $MACHINES
do
	cp tests.sh bootstrap.sh start.sh vbox
	cp -r manifests vbox

  mkdir -p .suite/$mach

	pushd vbox
	mkdir -p .downloads

	echo branch: $BRANCH > .git-branch.yaml

	# d'oh! machine not up yet!
	#rsync_to $mach ./.downloads /opt/downloads
	# instead going to put 'rsync /vagrant/.downloads /opt/downloads' in bootstrap.sh

	vagrant destroy -f $mach
	vagrant up $mach | tee ../.suite/$mach/buildlog

  CNF=`vagrant ssh-config $mach | cut -c3-`
	HOST=`echo "$CNF" | grep HostName | cut -f2 -d' '`
	PORT=`echo "$CNF" | grep Port | cut -f2 -d' '`
	USER=`echo "$CNF" | grep "User " | cut -f2 -d' '`
	KEYP=`echo "$CNF" | grep IdentityFile | cut -f2 -d' ' | sed "s/\"//g"`

	SCP_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $PORT -i $KEYP"
	CMD="scp $SCP_OPTS ${USER}@${HOST}:/tmp/testres/* ../.suite/$mach"
	echo $CMD
	$CMD

  rsync_from $mach /opt/downloads/* ./.downloads
	# delete the unpacked stuff, may be causing inter-vm erros
	ls -F .downloads/ |grep / | while read line; do echo "Removing $line"; rm -rf ".downloads/$line"; done

	#vagrant destroy -f $mach
	# don't destroy it, we might need to look at it
	vagrant halt $mach
	
	popd

done


ls -l .suite