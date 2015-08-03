class testrig {

  define ensure_packages ($ensure = "present") {
    if defined(Package[$title]) {}
    else {
      package { $title : ensure => $ensure, }
    }
  }

  $packages = [
    'git',
    'python-pip',
    'python-dev',
    'xvfb',
    'build-essential',
    'python-setuptools',
    'python-numpy',
    'python-scipy',
    'libatlas-dev',
    'libatlas3gf-base',
    'firefox',
  ]

  ensure_packages { $packages: }
  -> exec{'/usr/bin/pip install configure'}
}

class { 'testrig': }
