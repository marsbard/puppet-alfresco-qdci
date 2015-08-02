class testrig {
  file { '/root/wait-for-server.sh':
    source => 'puppet:///modules/testrig/wait-for-server.sh',
    ensure => present,
  }

  vcsrepo { '/root/alfresco-tests':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/digcat/alfresco-tests.git',
  }
}
