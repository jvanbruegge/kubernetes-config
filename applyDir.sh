set -e

if [ -z $1 ]; then
    echo "Please specify a folder"
    exit 1
fi

cd "$1"

yaml=""

for f in $(ls . | grep ".yaml.dhall"); do
    if [[ ! -z $yaml ]]; then
        yaml="$yaml

---
$(dhall-to-yaml --omitNull < ./$f)"
    else
        yaml="$(dhall-to-yaml --omitNull < ./$f)"
    fi
done

secrets=("root-ca" "ca-outside" "ca-inside")

if [[ $2 == "--dry-run" ]]; then
    echo "$yaml"
else
    cmd=""
    if [ -z $2 ]; then
        cmd="apply"

        echo "../mkNamespace.dhall \"$1\"" \
            | dhall-to-yaml --omitNull \
            | kubectl apply -f -

        if [[ "$1" != "haproxy" && "$1" != "vault" ]]; then
            for s in "${secrets[@]}"; do
                kubectl get secret "$s" --namespace=default --export -o yaml \
                    | kubectl apply --namespace="$1" -f -
            done
        fi
    else
        cmd="$2"
    fi

    echo "$yaml" | kubectl "$cmd" -f -

    if [[ "$cmd" == "delete" ]]; then
        for s in "${secrets[@]}"; do
            set +e
            kubectl delete secret "$s" --namespace="$1"
            set -e
        done

        kubectl delete namespace "$1"
    fi
fi
