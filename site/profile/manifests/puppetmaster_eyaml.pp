class profile::puppetmaster_eyaml {

  $hiera_yaml = "${::settings::confdir}/hiera.yaml"

  file { '/etc/puppetlabs/puppet/ssl/eyaml/private_key.pkcs7.pem':
    ensure  => file,
    mode    => '0600',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    source  => 'puppet:///modules/profile/eyaml/private_key.pkcs7.pem',
  }
  ->
  file { '/etc/puppetlabs/puppet/ssl/eyaml/public_key.pkcs7.pem':
    ensure  => file,
    mode    => '0644',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    source  => 'puppet:///modules/profile/eyaml/public_key.pkcs7.pem',
  }
  ->
  class { '::hiera':
    hierarchy  => [
      'common',
      'eyaml_common',
    ],
    logger             => 'console',
    eyaml              => true,
    keysdir            => '/etc/puppetlabs/puppet/ssl/eyaml/',
    eyaml_version      => 'absent', #using control repo to manage
    backends           => ['yaml', 'eyaml'],
    datadir            => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    eyaml_datadir      => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    datadir_manage     => false,
    create_keys        => false,
    puppet_conf_manage => false,
    notify             => Service['pe-puppetserver'],
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
