#!/bin/bash

cd /root
IPS_PATH=/vagrant/.machine_ips.txt

WGET_TIMEOUT=20

declare -A addrs
for arg in `cat $IPS_PATH`
do
  # expecting machine=1.2.3.4
  MACH=`echo $arg | cut -f1 -d=`
  ADDR=`echo $arg | cut -f2 -d=`
  addrs[$MACH]=$ADDR
done

# returns: 0 if server is up, 1 if no response from server, 2 if response
# received but it was not 2xx
function check_httpserv_up {
  NAME=$1
  URL=$2
  echo check_httpserv_up: $NAME: $URL
  RES=`wget -T ${WGET_TIMEOUT} --no-check-certificate --server-response $URL 2>&1 | awk '/^  HTTP/{print $2}' | tail -n 1`
  if [ "$RES" == "" ]
    then
    echo check_httpserv_up: No response from server
    return 1
  fi
  if [ "$RES" -ge 300 ]
    then
    echo check_httpserv_up: ERROR: $RES response from server
    return 2
  fi
  echo check_httpserv_up: SUCCESS: $RES response from server
  return 0
}


declare -A tested
tested_count=0
installed_pydeps=
function try_tests {
  #echo keys=${!addrs[@]}
  for machine in ${!addrs[@]}
  do
    echo machine=$machine
    if [ -z ${tested[machine]} ]
      then
      #echo ${addrs[$machine]}
      check_httpserv_up $machine "https://${addrs[$machine]}/share/page"
      if [ $? = 0 ]
        then
        # run the tests
        echo $machine is up and ready, running the tests
        #echo Put code here for running the tests...

        pushd tests-${machine}
        if [ -z $installed_pydeps ]
          then
          ./install.sh | awk -vwhich=tests_${machine} '{print which ": " $0}'
          installed_pydeps=/root/tests-${machine}
        fi
        ./runtests.sh  ${installed_pydeps}/testing_virt/venv/bin | awk -vwhich=tests_${machine} '{print which ": " $0}'
        popd
        # after tests are completed
        tested[$machine]=1
        tested_count=$(( $tested_count + 1 ))
      fi
    fi
  done

  # if we got here then we haven't tested everything
  # return the number remaining to do
  return $(( ${#addrs[@]} - $tested_count))
}

###########################################

# First... really quick and dirty, clone tests once for each machine
# and modify the config file
for machine in ${!addrs[@]}
do
  git clone https://github.com/digcat/alfresco-tests.git tests-${machine}
  cat tests-${machine}/config.yml | sed "s/localhost/${addrs[$machine]}/" > .tmp.config.yml
  mv .tmp.config.yml tests-${machine}/config.yml
done


while true
do
  echo Looping to look for available machines to test
  try_tests
  RES=$?
  if [ $RES == 0 ]
    then
    echo All tests have been run
    exit 0
  fi
  echo Some tests still to do, $RES remaining
  echo sleeping 30 seconds
  sleep 30
done
