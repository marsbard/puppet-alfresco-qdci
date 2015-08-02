#!/bin/bash

RES=`wget --no-check-certificate --server-response $URL 2>&1 | awk '/^  HTTP/{print $2}' | tail -n 1`
  echo "$COUNT - $RES" 
  if [ "$RES" == "" ]; then RES=999; fi
  if [ "$RES" -le 299 ]
  then 
    READY=true
  else 
    echo "Response was $RES, waiting $TIMEWAIT secs, showing current top status and last alfresco log tail" 

