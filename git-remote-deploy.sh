#!/bin/bash

: '
Project: https://github.com/jeffery/git-remote-deploy

The MIT License (MIT)

Copyright (c) 2014 Jeffery Fernandez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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
    if [ -f "${deployDir}/composer.phar" ]; then
        echo "- Starting composer update"
        cd "$deployDir"; php composer.phar install --prefer-dist --profile --optimize-autoloader; cd -
        echo "- Finished composer update"
    else
        echo "Composer does not exist to"
    fi
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
