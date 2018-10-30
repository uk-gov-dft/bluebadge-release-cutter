#! /bin/bash

WORKSPACE="$1"

if [ "$WORKSPACE" = "" ]; then
    echo "ERROR: Must specify workspace."
    exit 1
fi

if [ "$RELEASE_NAME" = "" ]; then
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

RELEASE_BRANCH_NAME="release/$RELEASE_NAME"

for application in "${APPLICATIONS[@]}"
do
  SHORTCODE=$(echo -n "$application" | cut -d, -f1)
  NAME=$(echo -n "$application" | cut -d, -f2)

  git clone --quiet "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/$NAME.git" > /dev/null
  cd "$NAME"
    NEXT_VERSION="$(semverit | cut -d, -f1)"
    CHANGE="$(semverit | cut -d, -f2)"

    git checkout --quiet develop > /dev/null
    git checkout -b "$RELEASE_BRANCH_NAME"
    git push origin 

    echo "## $NAME $NEXT_VERSION $(date -u)" >> ../RELEASE_NOTES.md
    echo

    if [ "$CHANGE" = "none" ]; then
      echo "no changes in this release" >> ../RELEASE_NOTES.md
    else

      for id in $(git log "$RELEASE_BRANCH_NAME..$MASTER" --oneline | grep -Eo "[A-Z]+(-|_)[0-9]+"| sort | uniq );
      do
        summary=$(curl -s -u $JIRA_CREDS -X GET -H "Content-Type: application/json" "https://uk-gov-dft.atlassian.net/rest/api/2/issue/${id/_/-}" | jq '.fields.summary')
        echo "- **$id** : $summary" >> ../RELEASE_NOTES.md
      done 
    fi
    echo >> ../RELEASE_NOTES.md
  cd ../
done

cd ../
