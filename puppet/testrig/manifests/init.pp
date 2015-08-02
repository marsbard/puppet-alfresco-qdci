class testrig {

# it's not a module >.<
#  file { '/root/wait-for-server.sh':
#    source => 'puppet:///modules/testrig/wait-for-server.sh',
#    ensure => present,
#  }



  package { 'git': ensure => present, } ->
  file { '/root/alfresco-tests': ensure => absent, } ->
  exec { 'git-clone-tests':
    command => '/usr/bin/git clone https://github.com/digcat/alfresco-tests.git',
    cwd => '/root',
  }

}

class { 'testrig': }
