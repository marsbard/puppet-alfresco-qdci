#!/bin/bash

#cd /root
IPS_PATH=/vagrant/.machine_ips.txt
IPS_PATH=./.machine_ips.txt

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
function try_tests {
  echo keys=${!addrs[@]}
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
        echo Put code here for running the tests...


        # after tests are completed
        tested[$machine]=1
        tested_count=$(( $tested_count + 1 ))
      fi
      # if [ $tested_count == "${#addrs[@]}" ]
      #   then
      #   # everything has been tested, we can end
      #   return 0
      # fi
    fi
  done

  # if we got here then we haven't tested everything
  # return the number remaining to do
  return $(( ${#addrs[@]} - $tested_count))
}


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
