#!/bin/sh

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

commit_updated_module_files() {
    git checkout master

    # Stage the modified module files
    git add -f .

    # Create a new commit with a custom build message
    # with "[skip ci]" to avoid a build loop
    # and Travis build number for reference
    git commit -s -m "Travis update: (Build $TRAVIS_BUILD_NUMBER)" -m "[skip ci]"
}

upload_files() {
    # Remove existing "origin"
    git remote rm origin

    # Add new "origin" with the access token
    git remote add origin https://${GH_TOKEN}@github.com/vmware/dscr-for-vmware.git > /dev/null 2>&1
    git push origin master --quiet
}

setup_git

commit_updated_module_files

# Attempt to commit to git only if "git commit" succeeded
if [ $? -eq 0 ]; then
    echo "A new commit with changed module files exists. Uploading to GitHub."
    upload_files
else
    echo "No changes in module files. Nothing to do."
fi