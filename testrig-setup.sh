#!/bin/bash

cd /root

declare -A addrs
for arg in `cat .machine_ips.txt`
do
  # expecting machine=1.2.3.4 
  MACH=`echo $arg | cut -f1 -d=`
  ADDR=`echo $arg | cut -f2 -d=`
  addrs[$MACH]=$ADDR
done

# returns: 0 if server is up, 1 if no response from server, 2 if response
# received but it was not 2xx
function check_httpserv_up {
  URL=$*
  RES=`wget --no-check-certificate --server-response $URL 2>&1 | awk '/^  HTTP/{print $2}' | tail -n 1`
  if [ "$RES" == "" ]
  then
    return 1
  fi
  if [ "$RES" -ge 300 ]
  then
    return 2
  fi
  return 0
}

# declare an associative array
declare -A done
done_count=0
for machine in "${!addrs[@]}"
do
  if [ -z $done[machine] ]
  then
    check_httpserv_up "https://${addrs[machine]}/share/page"
    if [ $? = 0 ]
    then
      # run the tests
    done[$machine]=1
    done_count=$(( $done_count + 1 ))
  fi
  if [ $done_count -ge "${#addrs[@]}" ]
done
