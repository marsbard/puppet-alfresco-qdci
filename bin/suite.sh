#!/bin/bash

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
  mkdir -p .suite/$mach
	./qdci-vbox.sh $BRANCH $mach
  CNF=`vagrant ssh-config $mach | cut -c3-`
	HOST=`echo $CNF | grep HostName | cut -f2 -d' '`
	PORT=`echo $CNF | grep Port | cut -f2 -d' '`
	USER=`echo $CNF | grep User | cut -f2 -d' '`
	KEYP=`echo $CNF | grep IdentityFile | cut -f2 -d' '`

	scp -P $PORT ${USER}@${HOST} -i $KEYP /tmp/testres/* .suite/$mach

	./qdci-vbox.sh clean

done


ls -l .suite
