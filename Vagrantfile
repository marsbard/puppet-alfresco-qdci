require 'yaml'
cnf = YAML::load_file(File.join(__dir__, 'config.yaml'))


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
        /vagrant/bootstrap.sh"
    end
    centos42f.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet-alfresco/manifests"
      puppet.manifest_file  = "../../centos42f.pp"
      puppet.module_path = ["puppet-alfresco/modules"]
    end
  end
end
