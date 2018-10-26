#! /bin/bash

WORKSPACE="$1"

if [ "$WORKSPACE" = "" ]; then
    echo "Must specify release number."
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

for application in "${APPLICATIONS[@]}"
do
  SHORTCODE=$(echo -n "$application" | cut -d, -f1)
  NAME=$(echo -n "$application" | cut -d, -f2)

  echo "Generating release notes."
  echo 
  git clone --quiet "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/$NAME.git" > /dev/null
  cd "$NAME"
    git checkout --quiet develop > /dev/null
    NEXT_VERSION=$(semverit)
    LAST_VERSION="$(git describe --abbrev=0)"
    COMMIT_COUNT="$(git rev-list $LAST_VERSION.. --count)"

    if [ "$COMMIT_COUNT" -gt 0 ]; then
      echo "## $NAME $NEXT_VERSION $(date -u)" | tee -a RELEASE_NOTES ../RELEASE_NOTES
      for id in $(git log "$LAST_VERSION".. | grep pull | grep -Eo "[A-Z]+(-|_)[0-9]+");
      do
        summary=$(curl -s -u $JIRA_CREDS -X GET -H "Content-Type: application/json" "https://uk-gov-dft.atlassian.net/rest/api/2/issue/${id/_/-}" | jq '.fields.summary')
        echo "- **$id** : $summary" | tee -a RELEASE_NOTES ../RELEASE_NOTES
      done 
    else
      echo "## $NAME $NEXT_VERSION $(date -u)" | tee -a RELEASE_NOTES ../RELEASE_NOTES
      echo "No changes.  Nothing to do." | tee -a RELEASE_NOTES ../RELEASE_NOTES
    fi
    git add RELEASE_NOTES
    git commit -m "$NEXT_VERSION"
    # git push origin develop
    git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION" || :
    # git push origin "$NEXT_VERSION"
    git checkout master
    git merge develop
    # git push origin master
    echo | tee -a RELEASE_NOTES ../RELEASE_NOTES
  cd ../
done

cd ../


# DIR=$1
# NEXT_VERSION=$(./semverit $(realpath "$DIR"))
# echo "NEXT VERSION: $NEXT_VERSION"
# cd "$DIR" 

# DEVELOP_VERSION="$(git describe --abbrev=0 remotes/origin/develop)"
# MASTER_VERSION="$(git describe --abbrev=0 remotes/origin/master)"

# echo "Develop: $DEVELOP_VERSION Master: $MASTER_VERSION"

# if [[ "$DEVELOP_VERSION" == "$MASTER_VERSION"  ]]; then 
#   if [[ "$(git describe --abbrev=0 remotes/origin/develop)" == "$(git describe remotes/origin/develop)" ]]; then
#     echo "No change - nothing to do"
#   else
#     git checkout master 
#     git pull origin master
#     git pull --no-edit origin develop
#     git push origin master 
#     
#     git tag -a "$NEXT_VERSION" -m "$NEXT_VERSION" || :
#     git push origin "$NEXT_VERSION" || :
#   fi
# else
#   echo "Version mis-match. Develop: $DEVELOP_VERSION Master: $MASTER_VERSION"
# fi
