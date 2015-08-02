require 'yaml'

cnf = YAML::load_file(File.join(__dir__, 'config.yaml'))
git = YAML::load_file(File.join(__dir__, '.git-branch.yaml'))


Vagrant.configure('2') do |config|

  config.vm.define "centos42f" do |centos42f|
    centos42f.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      provider.image = "centos-7-0-x64"
      provider.region = cnf['digital_ocean_region']
      provider.size = '512mb'
    end
    centos42f.vm.provision :shell do |shell|
      shell.inline = "OS=`cat /etc/issue | head -n1 | cut -f1 -d' '`; \
        if [ \"$OS\" == \"Debian\" -o \"$OS\" == \"Ubuntu\" ]; \
          then apt-get update; \
        else \
          yum -y update; \
        fi; \
        /vagrant/bootstrap.sh; \
        /vagrant/start.sh centos42f " + git['branch']
    end
  end

  config.vm.define "centos50x" do |centos50x|
    centos50x.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      provider.image = "centos-7-0-x64"
      provider.region = cnf['digital_ocean_region']
      provider.size = '512mb'
    end
    centos50x.vm.provision :shell do |shell|
      shell.inline = "OS=`cat /etc/issue | head -n1 | cut -f1 -d' '`; \
        if [ \"$OS\" == \"Debian\" -o \"$OS\" == \"Ubuntu\" ]; \
          then apt-get update; \
        else \
          yum -y update; \
        fi; \
        /vagrant/bootstrap.sh; \
        /vagrant/start.sh centos50x " + git['branch']
    end
  end

  config.vm.define "ubuntu42f" do |ubuntu42f|
    ubuntu42f.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      provider.image = 'ubuntu-14-04-x64'
      provider.region = cnf['digital_ocean_region']
      provider.size = '4gb'
    end
    ubuntu42f.vm.provision :shell do |shell|
      shell.inline = "OS=`cat /etc/issue | head -n1 | cut -f1 -d' '`; \
        if [ \"$OS\" == \"Debian\" -o \"$OS\" == \"Ubuntu\" ]; \
          then apt-get update; \
        else \
          yum -y update; \
        fi; \
        /vagrant/bootstrap.sh; \
        /vagrant/start.sh ubuntu42f " + git['branch']
    end
  end

  config.vm.define "ubuntu50x" do |ubuntu50x|
    ubuntu50x.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      provider.image = 'ubuntu-14-04-x64'
      provider.region = cnf['digital_ocean_region']
      provider.size = '4gb'
    end
    ubuntu50x.vm.provision :shell do |shell|
      shell.inline = "OS=`cat /etc/issue | head -n1 | cut -f1 -d' '`; \
        if [ \"$OS\" == \"Debian\" -o \"$OS\" == \"Ubuntu\" ]; \
          then apt-get update; \
        else \
          yum -y update; \
        fi; \
        /vagrant/bootstrap.sh; \
        /vagrant/start.sh ubuntu50x " + git['branch']
    end
  end

  config.vm.define "testrig" do |testrig|
    testrig.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      provider.image = 'ubuntu-14-04-x64'
      provider.region = cnf['digital_ocean_region']
      provider.size = '2gb'
    end
    testrig.vm.provision :shell do |shell|
      shell.inline = "apt-get update; /vagrant/bootstrap.sh"
    end
    testrig.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/testrig/manifests"
      puppet.manifest_file  = "init.pp"
      #puppet.module_path = ["modules"]
    end
  end


end
