#!/bin/bash

export git=""
export project=""


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -g|--git) git="$2"; shift ;;
        -p|--project) project=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ "$git" ]] 
then
    echo "git: $git"
    echo "project: $project"
else
    echo "A variável não existe"
    exit
fi

echo "git: $git"
echo "project: $project"