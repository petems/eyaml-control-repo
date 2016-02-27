class profile::eyaml_notify {
  $eyaml_message = hiera('encrypted_message')

  notify{$eyaml_message:}
}
