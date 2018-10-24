#! /bin/bash

DIR=$1
NEXT_VERSION=$(./semverit $(realpath "$DIR"))
echo "NEXT VERSION: $NEXT_VERSION"
cd "$DIR" 
git checkout develop 
git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION"
git push origin "$NEXT_VERSION"
git checkout master
git merge "$NEXT_VERSION"
git push origin master
