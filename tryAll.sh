#!/bin/bash

set -e

dir=$(pwd)

for f in ./*/*.yaml.dhall; do
    cd $(dirname "$f")

    dhall-to-yaml --omitNull < $(basename "$f") > /dev/null
    echo "$f: OK"

    cd "$dir"
done
