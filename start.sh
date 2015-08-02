#!/bin/bash

TYPE=$1
BRANCH=$2

cd /root

git clone https://github.com/marsbard/puppet-alfresco.git --single-branch -b $BRANCH

cd puppet-alfresco

install/modules-for-vagrant.sh

# ensure that our module is in the right place
if [ ! -d modules/alfresco ]
then
        mkdir modules/alfresco -p
        for d in lib files manifests templates
        do
                ln -s ${PWD}/${d} ${PWD}/modules/alfresco/${d}
        done
fi


cp /vagrant/manifests/${TYPE}.pp .

puppet apply --color=false --modulepath=modules ${TYPE}.pp
