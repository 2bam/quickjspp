#!/bin/bash

set -e
cd $(dirname $0)/..

git subtree pull --squash --prefix=quickjs/quickjs https://github.com/bellard/quickjs.git master
