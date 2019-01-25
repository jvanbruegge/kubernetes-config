let config = ./config.dhall

in ''
ui = true
api_addr = "https://vault.cerberus-systems.de"

plugin_directory = "/etc/vault/plugins"

storage "file" {
  path = "'' ++ config.path ++ ''"
}

listener "tcp" {
  address = "0.0.0.0:'' ++ Natural/show config.port ++''"
  tls_key_file = "'' ++ config.sslPath ++ ''/vault.key"
  tls_cert_file = "'' ++ config.sslPath ++ ''/vault.crt"
  tls_client_ca_file = "'' ++ config.sslPath ++ ''/ca.crt"
  tls_require_and_verify_client_cert = true
}

listener "tcp" {
    address = "0.0.0.0:'' ++ Natural/show config.internalPort ++ ''"
    tls_key_file = "'' ++ config.sslPath ++ ''/vault.key"
    tls_cert_file = "'' ++ config.sslPath ++ ''/vault.crt"
}
''
