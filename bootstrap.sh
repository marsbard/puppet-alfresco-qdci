#!/bin/sh

echo Running bootstrap.sh

if [ -f /etc/redhat-release ]
then

    TAILLOG=/var/log/messages

        # TODO need to work this out for RedHat too (perhaps it Just Works?)
        # CentOS like: CentOS release 6.6 (Final)
	      EL_MAJ_VER=`rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3`
        rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-${EL_MAJ_VER}.noarch.rpm
        yum install -y puppet git 
fi

if [ -f /etc/debian_version ]
then

    TAILLOG=/var/log/syslog

        apt-get update
        apt-get install apt-utils -y

        export DEBIAN_FRONTEND=noninteractive
        wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
        apt-get install puppet -y

      	apt-get install git -y

        cat > /etc/default/puppet <<EOF
START=yes
DAEMON_OPTS=""
EOF


fi

echo "Copying old .downloads folder in place"
rsync -vrz /vagrant/.downloads /opt/downloads

