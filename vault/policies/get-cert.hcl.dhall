let map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map

let pki_names = ["pki_int_inside", "pki_int_outside"]

let writePaths = ["/issue/get-cert", "/revoke"]
let readPaths = ["/ca", "/ca/pem", "/ca_chain"]

let mkPolicy = \(name : Text) -> \(type : Text) -> \(path : Text) -> ''
path "'' ++ name ++ path ++ ''" {
    capabilities = ["'' ++ type ++ ''"]
}
''

let append = \(a : Text) -> \(b : Text) -> a ++ b

let mkPolicies = \(name : Text) ->
    let fn = mkPolicy name
    let readPolicies = map Text Text (fn "read") readPaths
    let writePolicies = map Text Text (fn "update") writePaths

    in List/fold Text readPolicies Text append ""
        ++ List/fold Text writePolicies Text append ""

in List/fold Text pki_names Text (\(a : Text) -> \(b : Text) -> mkPolicies a ++ b) ""
