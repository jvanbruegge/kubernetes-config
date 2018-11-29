let cfg =
    { path = "/vault"
    , sslPath = "/ssl/rootCA"
    , port = 8200
    }

let mkConfig = \(_params : { path : Text, port : Natural, sslPath : Text }) ->
''ui = true

storage "file" {
  path = "'' ++ _params.path ++ ''"
}

listener "tcp" {
  address = "0.0.0.0:'' ++ Natural/show _params.port ++''"
  tls_key_file = "'' ++ _params.sslPath ++ ''/vault.key"
  tls_cert_file = "'' ++ _params.sslPath ++ ''/vault.crt"
}
''

in
    cfg
    //
    { file = mkConfig cfg }
