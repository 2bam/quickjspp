#!/bin/bash

set -e
cd $(dirname $0)/..

git subtree add --squash --prefix=quickjs/quickjs https://github.com/bellard/quickjs.git 458c34d29d0d262f824ea1c0e01aa0e3790669da

git apply --verbose -- quickjs/patches/*.patch
git add .
git commit -m "Apply patches to initialized quickjs impl"
