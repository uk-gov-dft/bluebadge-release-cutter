#! /bin/bash

DIR=$1
NEXT_VERSION=$(./semverit $(realpath "$DIR"))
(cd "$DIR" && git checkout develop && git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION")

