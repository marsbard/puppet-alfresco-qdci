#!/bin/bash

MACHINES="centos42f centos50x ubuntu42f ubuntu50x"

cd "`dirname $0`"

function banner {
	echo
	echo ===============
	echo $*
	echo ==========
}

if [ "$1" = "" ]
then
	echo Please enter the name of the branch you would like to test
	echo If you actually want to test 'master' then please try that
	echo
	echo Otherwise you are probably looking for a branch name like
	echo 'dev-X.Y or dev-X.Y-some-feature-branch'
	echo 
	exit
fi

TAIL=multitail
if [ -z `which multitail` ]
then
	echo Install multitail for a nicer log experience
	TAIL=tail
fi

banner Working with these machines: $MACHINES

# save the branch in a temporary file that the Vagrantfile can find
echo Saving branch name $1 to .git-branch.yaml
echo branch: $1 > .git-branch.yaml

banner Cleaning up any old VMs
vagrant destroy -f
sleep 9

LOGS=
banner Bringing VMs up
for machine in $MACHINES
do
	banner $machine
	LOGS="${LOGS} .${machine}.log"
(
	vagrant up --provider=digital_ocean $machine 
	ADDR=`vagrant ssh $machine -- hostname -I`
	echo $ADDR
) > .${machine}.log & 
done

(
SLEEPTIME=300
banner Sleeping $SLEEPTIME seconds before bringing up testrig
sleep $SLEEPTIME
banner Bringing up testrig VM
vagrant up --provider=digital_ocean testrig > .testrig.log 
) &

$TAIL $LOGS .testrig.log


