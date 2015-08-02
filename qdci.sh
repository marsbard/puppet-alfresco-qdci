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

# set the command stubs we will use and also search for when
# killing processes
VAG_CMD="/usr/bin/vagrant up --provider=digital_ocean"
TAIL_CMD="tail -F"

function banner {
	echo
	echo ===============
	echo $*
	echo ==========
}

function find_destroy_proc {
	echo finding $*
	PID=`ps ax | grep "$*" | grep -v grep | cut -c1-5`
	if [ ! -z $PID ]
	then
		echo killing $PID
		ps ax | grep $PID
		kill $PID 2>&1 > /dev/null
		wait $PID
	fi

}

function cleanup {

	trap "" EXIT

	banner cleanup where the fuck am i `pwd`
	mkdir -p reports
	REPNAME=reports/`date +%Y-%m-%d_%H:%M`_QA_report.txt

	BRANCH=`cat .git-branch.yaml`
	banner Cleaning up and producing report $REPNAME for $BRANCH


	banner QA Report for $BRANCH `date +%Y-%m-%d\ %H:%M` > $REPNAME

	for machine in $MACHINES testrig
	do
		banner $machine >> $REPNAME

		if [ -f .${machine}.log ]
		then
			cat .${machine}.log >> $REPNAME
		else
			echo .${machine}.log not found >> $REPNAME
		fi
	done

	# kill $PIDS
	for p in $PIDS
	do
		if [ ! -z `ps ax | cut -c1-5 | grep $p` ]
		then
			kill $p 2>&1 > /dev/null
		fi
	done
	sleep 8


	for machine in $MACHINES testrig
	do
		rm -f .${machine}.log

		# echo Try to shut down and destroy $machine
		#
		# # # get pid of tail and kill it
		# # find_destroy_proc $TAIL_CMD $machine
		#
		# vagrant halt $machine
		#
		# # # and vagrant
		# # find_destroy_proc $VAG_CMD $machine
		#
		# vagrant destroy -f $machine
	done

	banner No machines were destroyed, running vagrant status:
	vagrant status

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
	$VAG_CMD $machine
	ADDR=`vagrant ssh $machine -- hostname -I`
	echo $machine has address $ADDR
) > .${machine}.log &
PIDS="$PIDS $!"
done

(
# SLEEPTIME=300
# #banner Sleeping $SLEEPTIME seconds before bringing up testrig
# sleep $SLEEPTIME
banner Bringing up testrig VM
vagrant up --provider=digital_ocean testrig > .testrig.log
) &
PIDS="$PIDS $!"

COL=32
for machine in $MACHINES
do
	THIS_COL="\033[${COL}m"
	case $machine in
		ubuntu42f)
			tail -F .${machine}.log | awk '{print "\033[32m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		ubuntu50x)
			tail -F .${machine}.log | awk '{print "\033[33m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		centos42f)
			tail -F .${machine}.log | awk '{print "\033[34m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		centos50x)
			tail -F .${machine}.log | awk '{print "\033[35m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
	esac
	COL=$(( $COL + 1 ))
	if [ $COL -gt 38 ]
	then
		COL=32
	fi
done


# sleep forever (cleanup is run on signal trap)
wait
