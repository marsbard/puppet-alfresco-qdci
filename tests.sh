#!/bin/bash

git clone https://github.com/marsbard/alfresco-tests.git
cd alfresco-tests

cat <<EOF > config.yml
user: admin
passwd: admin 
sharehost: localhost
shareport: 8443
repohost: localhost
repoport: 8443
https: true
loginurl: /share
browser: firefox
photopath: images
cmisurl: /alfresco/api/-default-/public/cmis/versions/1.1/browser
cmisatom: /alfresco/cmisatom
ftpport: 2021
imap_host: localhost
imap_port: 8143
EOF

./install.sh
./runtests.sh ./testing_virt/venv/bin
