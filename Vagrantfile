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
      #provider.image = 'ubuntu-15-04-x64'
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

  config.vm.define "ubuntu50x" do |ubuntu50x|
    ubuntu50x.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = cnf['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = cnf['digital_ocean_token']
      #provider.image = "centos-7-0-x64"
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
end
