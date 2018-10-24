#! /bin/bash

DIR=$1
NEXT_VERSION=$(./semverit $(realpath "$DIR"))
echo "NEXT VERSION: $NEXT_VERSION"
cd "$DIR" 

DEVELOP_VERSION="$(git describe --abbrev=0 remotes/origin/develop)"
MASTER_VERSION="$(git describe --abbrev=0 remotes/origin/develop)"

if [[ "$DEVELOP_VERSION" == "$MASTER_VERSION"  ]]; then 
  git checkout master 
  git pull --no-edit origin develop
  git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION" || :
  git push origin master 
  git push origin "$NEXT_VERSION" || :
else
  echo "Version mis-match. Develop: $DEVELOP_VERSION Master: $MASTER_VERSION"
fi
