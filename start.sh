#!/bin/bash

TYPE=$1

cd /root

git clone https://github.com/marsbard/puppet-alfresco.git

cd puppet-alfresco

cp /vagrant/manifests/${TYPE}.pp .

puppet apply --modulepath=modules ${TYPE}.pp
