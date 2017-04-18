# == Class codedeploy::install
#
# This class is called from codedeploy for install.
#
class codedeploy::install {

  case $::osfamily {
    'RedHat', 'Amazon': {
      package { $::codedeploy::package_name:
        ensure   => present,
        provider => 'rpm',
        source   => $::codedeploy::package_url,
      }
    }
    'windows': {
      package { $::codedeploy::package_name:
        ensure => present,
        source => $::codedeploy::package_url,
      }
    }
    'Debian': {
      exec { 'download_codedeploy_installer':
        command => '/usr/bin/wget http://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install -O /tmp/install',
        cwd     => '/tmp',
        creates => '/tmp/install',
      }
      file { '/tmp/install':
        ensure    => file,
        owner     => 'root',
        group     => 'root',
        mode      => '0740',
        subscribe => Exec['download_codedeploy_installer'],
        notify    => Exec['install_codedeploy_agent'],
      }
      exec { 'install_codedeploy_agent':
        command     => '/bin/bash /tmp/install auto',
        cwd         => '/tmp',
        refreshonly => true,
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
