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
        echo
        echo "************************************************************************"
        echo "Cleaning $folder..."
        echo "************************************************************************"
        cd "$folder"
        terraform destroy -auto-approve || true
        echo "Cleaning state..."
        terraform state rm $(terraform state list) > /dev/null 2>&1 || true
        cd -
    done
}

test() {
    for folder in $(ls -d -- scenarios/*/); do
        echo
        echo "************************************************************************"
        echo "Running $folder..."
        echo "************************************************************************"
        cd "$folder"
        terraform init -upgrade
        terraform apply -auto-approve
        if [ -f "run.sh" ]; then
            bash run.sh
        fi
        terraform destroy -auto-approve
        terraform state rm $(terraform state list) || true
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
        echo "*** TEST-ALL SUCCESSFULL ***"
    ;;
    *) ## help
        echo "Usage: $(basename "$0") [init|clean|test-all]"
        exit 1
    ;;
esac
