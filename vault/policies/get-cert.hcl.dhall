let prelude = https://prelude.dhall-lang.org/package.dhall
  sha256:534e4a9e687ba74bfac71b30fc27aa269c0465087ef79bf483e876781602a454

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
    let readPolicies = prelude.`List`.map Text Text (fn "read") readPaths
    let writePolicies = prelude.`List`.map Text Text (fn "update") writePaths

    in List/fold Text readPolicies Text append ""
        ++ List/fold Text writePolicies Text append ""

in List/fold Text pki_names Text (\(a : Text) -> \(b : Text) -> mkPolicies a ++ b) ""
