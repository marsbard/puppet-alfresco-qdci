#!/bin/bash


TYPE=$1
BRANCH=$2

echo Running start.sh TYPE=$TYPE BRANCH=$BRANCH

cd /root

git clone https://github.com/marsbard/puppet-alfresco.git --single-branch -b $BRANCH

cd puppet-alfresco


gem install librarian-puppet
/usr/local/bin/librarian-puppet install --verbose


# ensure that our module is in the right place
if [ ! -d modules/alfresco ]
then
        mkdir modules/alfresco -p
        for d in lib files manifests templates
        do
                #ln -s ${PWD}/${d} ${PWD}/modules/alfresco/${d}
                cp -r ${PWD}/${d} ${PWD}/modules/alfresco/${d}

        done
fi


cp /vagrant/manifests/${TYPE}.pp .

puppet apply --color=false --modulepath=modules ${TYPE}.pp
