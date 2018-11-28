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

if [[ $2 == "--dry-run" ]]; then
    echo "$yaml"
else
    cmd=""
    if [ -z $2 ]; then
        cmd="apply"
    else
        cmd="$2"
    fi

    echo "$yaml" | kubectl "$cmd" -f -
fi
