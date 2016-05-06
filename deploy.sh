#!/bin/sh

set +x
set -o errexit -o nounset

if [ "$TRAVIS_BRANCH" != "master" ]
then
  echo "This commit was made against the $TRAVIS_BRANCH and not the master! No deploy!"
  exit 0
fi

# Error out if $GH_TOKEN is empty or unset
: ${GH_TOKEN:?"GH_TOKEN needs to be uploaded via travis-encrypt"}

# Clone the destination repository into $HOME/out without echoing the token
GH_TOKEN_MD5=$(echo $GH_TOKEN | md5sum)
echo Token MD5: $GH_TOKEN_MD5
cd $HOME
git clone --branch=gh-pages "https://${GH_TOKEN}@github.com/euanh/deploy-test" out | sed -e "s/$GH_TOKEN/!REDACTED!/g"
set -x
echo Cloned

# Commit changes in the destination branch
cd out
ls
git branch
git config user.name "travis"
git config user.email "travis@travis-ci.org"
date >> commits
git add commits
git commit -m "test commit"
git log --oneline -10
ls
git show

# Push changes back to GitHub, redacting the token
set +x
git push origin gh-pages 2>&1 | sed -e "s/$GH_TOKEN/!REDACTED!/g"
set -x
