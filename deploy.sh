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

echo $GH_TOKEN | md5sum
cd $HOME
git clone --branch=gh-pages "https://${GH_TOKEN}@github.com/euanh/deploy-test" out 
set -x
echo Cloned
pwd
ls
ls out
cd out
ls
git branch
git config user.name "travis"
git config user.email "travis@travis-ci.org"
date > commits
git add commits
git commit -m "test commit"
git log --oneline -10
ls
git show
# --quiet and &> /dev/null seem to make push silently fail (succesfully!) if the token is rubbish
set +x
git push --quiet origin gh-pages &> /dev/null
set -x
echo $?
echo Pushed
