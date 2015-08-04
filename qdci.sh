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
	echo Beware that if you get this wrong here you will not find out
	echo until after the VMs have been loaded, so take the time to get it
	echo right ":-)"
	exit
fi

if [ ! -f config.yaml ]
then
    echo Please copy config.yaml.example to config.yaml and edit it with your Digital Ocean token
    exit
fi

#PRIVKEYPATH=`cat config.yaml | grep private_key_path | cut -f2 -d' '`
#if [ ! -f "$PRIVKEYPATH" ]
#then
#    echo "You have specified '$PRIVKEYPATH' for your private key path but no file was found there"
#    exit
#fi

# set the command stubs we will use and also search for when
# killing processes
VAG_CMD="/usr/bin/vagrant up --provider=digital_ocean"
TAIL_CMD="tail -F"


# generate a separate key for vagrant
if [ ! -f vagrant.key ]
then
  ssh-keygen -f vagrant.key
fi

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

	TS=`date +%Y%m%d%H%M`

	mkdir -p reports/$TS

	BRANCH=`cat .git-branch.yaml`
	banner Cleaning up and producing reports for $BRANCH

	for machine in $MACHINES testrig
	do
		REPNAME=reports/$TS/${machine}_build_report.txt
		banner Build Report for ${machine}, ${BRANCH} `date +%Y-%m-%d\ %H:%M` > $REPNAME
		banner Producing $machine report for $BRANCH
		banner $machine >> $REPNAME

		if [ -f .${machine}.log ]
		then
			cat .${machine}.log >> $REPNAME
		else
			echo .${machine}.log not found >> $REPNAME
		fi

		banner Appending catalina.out from $machine to report
		banner catalina.out on $machine >> $REPNAME
		vagrant ssh $machine -c "cat /opt/alfresco/tomcat/logs/catalina.out" >> $REPNAME


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

# remove old IP addresses
rm -f .ip.*
rm -f .addresses.yaml

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
	echo $ADDR > .ip.$machine
) > .${machine}.log &
PIDS="$PIDS $!"
sleep 2 # try to let the first request settle to get round errors about the key being in use already
done

(
# wait for all machines to have told us their IP addresses before starting
# testrig machine
COUNT=0
MACH_LIST=( $MACHINES )
IPS=""
while [ $COUNT -lt ${#MACH_LIST[@]} ]
do
	COUNT=`ls .ip.* 2> /dev/null | wc -l`
	echo "Found addresses of $COUNT machines, waiting for ${#MACH_LIST[@]}"
	sleep 20
done
banner Got all IP addresses - bringing up testrig VM
# we need the machine list in the testrig - it gets copied up with the
# rsync from vagrant
export MACHINES
for machine in $MACHINES
do
	IPS="$IPS ${machine}=`cat .ip.${machine}`"
	export IPS
	echo $IPS > .machine_ips.txt
done
vagrant up --provider=digital_ocean testrig > .testrig.log
) &
PIDS="$PIDS $!"

# set up different coloured tails per machine build log
for machine in $MACHINES
do
	case $machine in
		ubuntu42f)
			tail -qF .${machine}.log 2> /dev/null | awk '{print "\033[34m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		ubuntu50x)
			tail -qF .${machine}.log 2> /dev/null | awk '{print "\033[33m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		centos42f)
			tail -qF .${machine}.log 2> /dev/null | awk '{print "\033[35m" $0 "\033[39m"}' &
			PIDS="$PIDS $!"
			;;
		centos50x)
			PIDS="$PIDS $!"
			tail -qF .${machine}.log 2> /dev/null | awk '{print "\033[32m" $0 "\033[39m"}' &
			;;
	esac
done
# and a tail for the testrig build log
tail -qF .testrig.log 2> /dev/null | awk '{print "\033[36m" $0 "\033[39m"}' &
PIDS="$PIDS $!"

# sleep forever (cleanup is run on signal trap)
wait
