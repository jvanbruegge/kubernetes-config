let config = ./config.dhall

in ''
ui = true

storage "file" {
  path = "'' ++ config.path ++ ''"
}

listener "tcp" {
  address = "0.0.0.0:'' ++ Natural/show config.port ++''"
  tls_key_file = "'' ++ config.sslPath ++ ''/vault.key"
  tls_cert_file = "'' ++ config.sslPath ++ ''/vault.crt"
}
''

