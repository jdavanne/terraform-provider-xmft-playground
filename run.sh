#!/bin/bash
#
set -euo pipefail

runtime=$(pwd)
installDir=$(dirname "$0")


cd "$installDir"

init() {
    for folder in $(ls -d -- scenarios/*/); do
        echo "Cleaning $folder..."
        cp common/* $folder
    done
}

clean() {
    for folder in $(ls -d -- scenarios/*/); do
        echo "Cleaning $folder..."
        cd "$folder"
        terraform destroy -auto-approve || true
        terraform state rm $(terraform state list) || true
        cd -
    done
}

test() {
    for folder in $(ls -d -- scenarios/*/); do
        echo "Running $folder..."
        cd "$folder"
        terraform init -upgrade
        terraform apply -auto-approve
        if [ -f "run.sh" ]; then
            bash run.sh
        fi
        terraform destroy -auto-approve
        cd -
    done
}

case ${1:-} in
    init) ## Init all scenarios
        init
        ;;
    clean) ## Clean all scenarios
        clean
        ;;
    test-all) ## Test all scenarios
        init
        clean
        test
    ;;
    *) ## help
        echo "Usage: $(basename "$0") [init|clean|test-all]"
        exit 1
    ;;
esac
