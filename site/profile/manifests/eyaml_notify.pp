class profile::eyaml_notify {
  $eyaml_message = hiera('encrypted_message', 'Eyaml not setup yet')

  notify{$eyaml_message:}
}
