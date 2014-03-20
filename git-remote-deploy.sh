#!/bin/bash

: '
Project: https://github.com/jeffery/git-remote-deploy

Copyright (C) 2014  Jeffery Fernandez <jefferyfernandez@gmail.com>
License: MIT
'

echo -e "\n## GIT Post-Update of $1 started ##\n"

updateGitRepository()
{
    local branchName="$1"
    local deployDir="$2"
    echo "- Updating repository"
    GIT_WORK_TREE="$deployDir" git checkout -f "$branchName"
    GIT_WORK_TREE="$deployDir" git clean -f -d
    echo "- Repository updated"
}

updateDepedendLibraries()
{
    local deployDir="$1"
    echo "- Starting composer update"
    cd "$deployDir"; ./composer.phar install --prefer-dist --profile --optimize-autoloader; cd -
    echo "- Finished composer update"
}

getBranchName()
{
    local ref="$1"
    branchName=$(git rev-parse --symbolic --abbrev-ref "$ref" 2>&1)
    if [ $? -ne 0 ]; then
        echo
    else
        echo ${branchName}
    fi
}

getDeploymentDirectory()
{
    local branchName="$1"
    deploymentPath=$(git config "deploy.${branchName}")
    if [ -z "$deploymentPath" ]; then
        false
    else
        echo "$deploymentPath"
    fi
}

createDeploymentDirectory()
{
    local directoryPath="$1"
    if [ -d "$directoryPath" ]; then
        true
    else
        create=$(mkdir -p "$directoryPath" 2>&1)
        if [ $? -ne 0 ]; then
            false
        else
            true
        fi
    fi
}

function die()
{
    echo -e "$1"
    exit 1
}

workingBranchName=$(getBranchName "$1" )

DEPLOY_DIR=$(getDeploymentDirectory "$workingBranchName")
if [ "${DEPLOY_DIR}" ]; then
    createDeploymentDirectory "$DEPLOY_DIR" || die "Could not create deployment path"
    updateGitRepository "$workingBranchName" "$DEPLOY_DIR"
    updateDepedendLibraries "$DEPLOY_DIR"
    echo -e "\n## GIT Deployed branch ${workingBranchName} into ${DEPLOY_DIR} ##\n"
else
    die "\n## GIT Could not fetch deployment config to start deployment ##\n"
fi
