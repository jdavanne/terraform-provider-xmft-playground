#!/bin/bash
#
set -euo pipefail

for folder in $(ls -d -- scenarios/*/); do
    echo "Cleaning $folder..."
    cd "$folder"
    terraform destroy -auto-approve || true
    terraform state rm $(terraform state list) || true
    cd -
done

for folder in $(ls -d -- scenarios/*/); do
    echo "Running $folder..."
    cd "$folder"
    terraform init
    terraform apply -auto-approve
    if [ -f "run.sh" ]; then
        bash run.sh
    fi
    terraform destroy -auto-approve
    cd -
done
