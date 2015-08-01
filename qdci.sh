#!/bin/bash

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

# save the branch in a temporary file that the Vagrantfile can find
echo branch: $1 > .git-branch.yaml

vagrant up --provider=digital_ocean 
