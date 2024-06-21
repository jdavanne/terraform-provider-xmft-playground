#!/bin/bash
#

for folder in $(ls -d -- scenarios/*/); do
    echo "Cleaning $folder..."
    cp common/* $folder
done
