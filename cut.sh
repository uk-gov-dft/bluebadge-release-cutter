#! /bin/bash

pip install --user markdown2

WORKSPACE="$1"

if [ "$WORKSPACE" = "" ]; then
    echo "ERROR: Must specify workspace."
    exit 1
fi

if [ "$TARGET_BRANCH" = "" ]; then
    echo "ERROR: Must specify target branch."
    exit 1
fi

if [ "$RELEASE_NUMBER" = "" ]; then
    echo "ERROR: Must specify release name or number."
    exit 1
fi

if [ "$RELEASE_NUMBER" = "EMPTY" ]; then
    echo "ERROR: Must specify release name or number."
    exit 1
fi



APPLICATIONS=( \
  LA,la-webapp \
  CA,citizen-webapp \
  UM,usermanagement-service \
  BB,badgemanagement-service \
  AP,applications-service \
  AZ,authorisation-service \
  MG,message-service \
  RD,referencedata-service \
  PR,print-service
  CS,crypto-service  
)

export PATH=$(pwd):$PATH

rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

cd "$WORKSPACE"

SAFE_RELEASE_NUMBER="$(echo "$RELEASE_NUMBER" | tr -dc '[:alnum:]' | tr '[:upper:]' '[:lower:]' | fold -w 32 | head -n 1)"
RELEASE_BRANCH_NAME="release/$SAFE_RELEASE_NUMBER"
RELEASE_TAG_NAME="release-$SAFE_RELEASE_NUMBER"


# Need to select which branch to create the release from
# Either create a release from the develop branch or the master branch

BRANCH="$TARGET_BRANCH"

# Preliminary Checks
for application in "${APPLICATIONS[@]}"
do
  SHORTCODE=$(echo -n "$application" | cut -d, -f1)
  NAME=$(echo -n "$application" | cut -d, -f2)

  git clone --quiet "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/$NAME.git" > /dev/null
  cd "$NAME"

  # Check if this release has already been tagged
  if git ls-remote --tags origin | grep -q "release-$RELEASE_NUMBER"; then
    echo "This release has already been tagged"
    exit 1
  fi
  if git branch -r | grep -q "release-$RELEASE_NUMBER"; then
    echo "This release has already been branched"
    exit 1
  fi
  
  # Need to also check the number is the next release if it is a number
  # This would be a SHOULD HAVE but not essential
  cd ../
done


echo "# Release Notes #$SAFE_RELEASE_NUMBER $(date -u)" > ../RELEASE_NOTES.md
for application in "${APPLICATIONS[@]}"
do
  SHORTCODE=$(echo -n "$application" | cut -d, -f1)
  NAME=$(echo -n "$application" | cut -d, -f2)

  cd "$NAME"
    NEXT_VERSION="$(semverit | cut -d, -f1)"
    CHANGE="$(semverit | cut -d, -f2)"

    git checkout --quiet "$BRANCH" > /dev/null
    git checkout --quiet -b "$RELEASE_BRANCH_NAME" > /dev/null
    git push --quiet origin "$RELEASE_BRANCH_NAME" > /dev/null

    git status
    pwd

    echo "## $NAME $NEXT_VERSION $(date -u)" >> ../../RELEASE_NOTES.md
    echo

    echo "Checking Change - $CHANGE"
    if [ "$CHANGE" = "none" ]; then
      echo "no changes in this release" >> ../../RELEASE_NOTES.md
    else
      git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION"
      git push origin "$NEXT_VERSION"

      for id in $(git log --oneline $(git tag | sed -r "s/([0-9]+\.[0-9]+\.[0-9]+$)/\1\.99999/"|sort -V|sed s/\.99999$// | tail -n1).."$BRANCH" | grep pull | grep -Eo "[A-Z]+(-|_)[0-9]+"| sort | uniq );
      do
        echo $id
        summary=$(curl -s -u $JIRA_CREDS -X GET -H "Content-Type: application/json" "https://uk-gov-dft.atlassian.net/rest/api/2/issue/${id/_/-}" | jq '.fields.summary')
        echo "- **$id** : $summary" >> ../../RELEASE_NOTES.md
      done 
    fi
    echo >> ../../RELEASE_NOTES.md
  cd ../
done

cd ../
~/.local/bin/markdown2 ./RELEASE_NOTES.md > RELEASE_NOTES.html
