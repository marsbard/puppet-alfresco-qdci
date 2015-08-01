#!/bin/sh

OS=`head -n1 /etc/issue | cut -f1 -d\ `

if [ -f /etc/redhat-release ]
then

    TAILLOG=/var/log/messages

        # TODO need to work this out for RedHat too (perhaps it Just Works?)
        # CentOS like: CentOS release 6.6 (Final)
	EL_MAJ_VER=`head -n1 /etc/redhat-release | cut -f4 -d\ | cut -f1 -d.`
        rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-${EL_MAJ_VER}.noarch.rpm
        yum install -y puppet
	yum install -y git
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

if [ $OS = "Arch" ]
then
  mkdir -p /tmp/puppet
  cd /tmp/puppet
  gem install facter
  gem install hiera
  gem install json_pure
  gem install puppet
fi


