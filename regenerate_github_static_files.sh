#!/bin/bash

set -e

if [[ `git symbolic-ref HEAD` != "refs/heads/gh-pages" ]]; then
    echo "$0: cowardly refusing to commit generated docs on a branch other than gh-pages"
    exit 1
fi

set -o verbose

git merge master
sphinx-build -b singlehtml docs .
git add --all
git commit -m 'generate'

