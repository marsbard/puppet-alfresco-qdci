#!/bin/bash

set -x

cd "`dirname $0`/.."

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
	acho branch: $BRANCH > .git-branch.yaml

	vagrant up $mach

  CNF=`vagrant ssh-config $mach | cut -c3-`
	HOST=`echo "$CNF" | grep HostName | cut -f2 -d' '`
	PORT=`echo "$CNF" | grep Port | cut -f2 -d' '`
	USER=`echo "$CNF" | grep "User " | cut -f2 -d' '`
	KEYP=`echo "$CNF" | grep IdentityFile | cut -f2 -d' ' | sed "s/\"//g"`

	CMD="scp -P $PORT -i $KEYP ${USER}@${HOST}:/tmp/testres/* ../.suite/$mach"
	echo $CMD
	$CMD

	vagrant destroy -f $mach
	
	popd

done


ls -l .suite
