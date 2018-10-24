#! /bin/bash

DIR=$1
NEXT_VERSION=$(./semverit $(realpath "$DIR"))
echo "NEXT VERSION: $NEXT_VERSION"
cd "$DIR" 

DEVELOP_VERSION="$(git describe --abbrev=0 remotes/origin/develop)"
MASTER_VERSION="$(git describe --abbrev=0 remotes/origin/master)"

echo "Develop: $DEVELOP_VERSION Master: $MASTER_VERSION"

if [[ "$DEVELOP_VERSION" == "$MASTER_VERSION"  ]]; then 
  if [[ "$(git describe --abbrev=0 remotes/origin/develop)" == "$(git describe remotes/origin/develop)" ]]; then
    echo "No change - nothing to do"
  else
    git checkout master 
    git pull origin master
    git pull --no-edit origin develop
    git push origin master 
    
    git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION" || :
    git push origin "$NEXT_VERSION" || :
  fi
else
  echo "Version mis-match. Develop: $DEVELOP_VERSION Master: $MASTER_VERSION"
fi
