#! /bin/bash

pip install --user markdown2

WORKSPACE="$1"

if [ "$WORKSPACE" = "" ]; then
    echo "ERROR: Must specify workspace."
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
)

export PATH=$(pwd):$PATH

rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

cd "$WORKSPACE"

SAFE_RELEASE_NUMBER="$(echo "$RELEASE_NUMBER" | tr -dc '[:alnum:]' | tr '[:upper:]' '[:lower:]' | fold -w 32 | head -n 1)"
RELEASE_BRANCH_NAME="release/$SAFE_RELEASE_NUMBER"
RELEASE_TAG_NAME="release-$SAFE_RELEASE_NUMBER"


echo "# Release Notes #$SAFE_RELEASE_NUMBER $(date -u)" > ../RELEASE_NOTES.md
for application in "${APPLICATIONS[@]}"
do
  SHORTCODE=$(echo -n "$application" | cut -d, -f1)
  NAME=$(echo -n "$application" | cut -d, -f2)

  git clone --quiet "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/$NAME.git" > /dev/null
  cd "$NAME"
    NEXT_VERSION="$(semverit | cut -d, -f1)"
    CHANGE="$(semverit | cut -d, -f2)"

    git checkout --quiet develop > /dev/null
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
      git tag -a "$NEXT_VERSION-rc1" -m "$NEXT_VERSION-rc1"
      git push origin "$NEXT_VERSION-rc1"

      for id in $(git log origin/master.. --oneline | grep -Eo "[A-Z]+(-|_)[0-9]+"| sort | uniq );
      do
        echo $id
        summary=$(curl -s -u $JIRA_CREDS -X GET -H "Content-Type: application/json" "https://uk-gov-dft.atlassian.net/rest/api/2/issue/${id/_/-}" | jq '.fields.summary')
        echo "- **$id** : $summary" >> ../../RELEASE_NOTES.md
      done 
    fi
    echo >> ../../RELEASE_NOTES.md
  cd ../
done

~/.local/bin/markdown2 ./RELEASE_NOTES.md > RELEASE_NOTES.html

cd ../
