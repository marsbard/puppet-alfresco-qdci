#!/bin/bash

. ../bin/vagscp.inc.sh

rsync_to centos42f ./.downloads /opt/downloads

vagrant ssh centos42f

rsync_from centos42f /opt/downloads/* ./.downloads
