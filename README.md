___DO NOT USE THIS YET___

A test rig for running multiple variants of the build as a kind of poor-man's CI

We use Digital Ocean's plugin https://www.digitalocean.com/community/projects/vagrant

You need to do this if you want to play along at home:

* `git clone https://github.com/marsbard/puppet-alfresco-qdci test-rig; cd test-rig`
* `vagrant plugin install vagrant-digitalocean`
* Copy `config.yaml.example` to `config.yaml` and edit it to your requirements
* `./qdci.sh <git public branch name>`

When it looks like all the logs have finished tailing, press Ctrl-C to clean up and
generate the build reports for each machine.

The build report will be in a file like reports/\<timestamp\>/<machine name>_build_report.txt

The timestamp is a string of numbers in the form: 'YYYYMMDDhhmm'
