class profile::puppetmaster_eyaml {

  $hiera_yaml = "${::settings::confdir}/hiera.yaml"

  class { '::hiera':
    hierarchy  => [
      'common',
      'eyaml_common',
    ],
    logger            => 'console',
    eyaml             => true,
    eyaml_version     => 'absent', #using control repo to manage
    backends          => ['yaml', 'eyaml', 'redis'],
    datadir           => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    eyaml_datadir     => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    datadir_manage    => false,
    create_keys       => false,
    eyaml_private_key => 'puppet:///modules/profiles/keys/private_key.pkcs7.pem',
    eyaml_public_key  => 'puppet:///modules/profiles/keys/public_key.pkcs7.pem',
    notify            => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config main section' :
    ensure  => present,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'main',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config master section' :
    ensure  => absent,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'master',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  #remove the default hiera.yaml from the code-staging directory
  #after the next code manager deployment it should be removed
  #from the live codedir
  file { '/etc/puppetlabs/code-staging/hiera.yaml' :
    ensure => absent,
  }

}
