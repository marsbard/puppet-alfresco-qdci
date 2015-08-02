#!/bin/bash

MACHINES="centos42f centos50x ubuntu42f ubuntu50x"

cd "`dirname $0`"

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


function banner {
	echo
	echo ===============
	echo $*
	echo ==========
}

function cleanup {
	mkdir -p reports
	REPNAME=reports/`date +%Y-%m-%d_%H:%M`_QA_report.txt

	banner Cleaning up and producing report $REPNAME

	# kill off bg process
	for p in $PIDS
	do
		kill -9 $p
		sleep 1
	done

	banner QA Report for `cat git-branch.yaml`  `date +Y-%m-%d %H:%M` > $REPNAME

	for machine in $MACHINES testrig
	do
		banner $machine >> $REPNAME

		if [ -f .$machine.log ]
		then
			cat .${machine}.log >> $REPNAME
			rm .${machine}.log
		else
			echo .${machine}.log not found >> $REPNAME
		fi

		vagrant destroy -f $machine
	done

	exit 0
}

trap cleanup INT TERM EXIT

banner Working with these machines: $MACHINES

# save the branch in a temporary file that the Vagrantfile can find
echo Saving branch name $1 to .git-branch.yaml
echo branch: $1 > .git-branch.yaml

LOGS=
PIDS=
#banner Bringing VMs up
for machine in $MACHINES
do
	#banner $machine
	LOGS="${LOGS} .${machine}.log"
(
	vagrant up --provider=digital_ocean $machine
	ADDR=`vagrant ssh $machine -- hostname -I`
	echo $ADDR
) > .${machine}.log &
PIDS="$PIDS $!"
done

(
SLEEPTIME=300
#banner Sleeping $SLEEPTIME seconds before bringing up testrig
sleep $SLEEPTIME
banner Bringing up testrig VM
vagrant up --provider=digital_ocean testrig > .testrig.log
) &
PIDS="$PIDS $!"

tail -F .ubuntu42f.log | awk '{print "\033[32m" $0 "\033[39m"}' &
PIDS="$PIDS $!"
tail -F .ubuntu50x.log | awk '{print "\033[33m" $0 "\033[39m"}' &
PIDS="$PIDS $!"
tail -F .centos42f.log | awk '{print "\033[34m" $0 "\033[39m"}' &
PIDS="$PIDS $!"
tail -F .centos50x.log | awk '{print "\033[35m" $0 "\033[39m"}' &
PIDS="$PIDS $!"
tail -F .testrig.log | awk '{print "\033[36m" $0 "\033[39m"}' &
PIDS="$PIDS $!"


# sleep forever (cleanup is run on signal trap)
while /bin/true
do
	sleep 60
done
