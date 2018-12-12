# My kubernetes configuration

All configuration is written in [dhall](https://github.com/dhall-lang/dhall-lang), so you need [dhall-json](https://github.com/dhall-lang/dhall-haskell) installed to generate the yaml.

Run
```
stack install dhall-1.19.0 dhall-text-1.0.14 dhall-json-1.2.5 --resolver=nightly-2018-11-12
```
to install everything

# What is done is which order:

1. Generate a root CA and self-sign it
2. (manual) install root CA cert in trusted CA store (on client device)
3. Create a client cert and sign it with the root CA
    - Use client cert to encrypt the communication with vault
4. Initialize vault (print out 5 key shares)
