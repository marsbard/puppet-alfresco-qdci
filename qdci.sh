#!/bin/bash

MACHINES="centos42f centos50x ubuntu42f ubuntu50x"

cd "`dirname $0`"

function banner {
	echo
	echo ===============
	echo $*
	echo ==========
}

function cleanup {
	mkdir -p reports
	REPNAME=`date +%Y-%m-%d_%H:%M`_QA_report.txt


	banner QA Report for `date +Y-%m-%d %H:%M` > $REPNAME

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
		vagrant destroy -f $machine &
	done

	exit 0
}

trap cleanup INT TERM EXIT

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

# TAIL=9t
# if [ -z `which 9t` ]
# then
# 	echo For the best log experience: https://github.com/gongo/9t
# 	echo and make sure '9t' is in your path.
# 	echo
# 	echo Attempting fallback to multitail
# fi
#
# TAIL="multitail -c"
# if [ -z `which multitail` ]
# then
# 	echo Install multitail for a nicer log experience
# 	echo Falling back to tail
# 	TAIL=tail
# fi

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

$TAIL -f $LOGS .testrig.log

tail -F .ubuntu42f.log | awk '1 {print "\033[32m" $0 "\033[39m"}' &
tail -F .ubuntu50x.log | awk '1 {print "\033[33m" $0 "\033[39m"}' &
tail -F .centos42f.log | awk '1 {print "\033[34m" $0 "\033[39m"}' &
tail -F .centos50x.log | awk '1 {print "\033[35m" $0 "\033[39m"}' &
tail -F .testrig.log | awk '1 {print "\033[36m" $0 "\033[39m"}' &
