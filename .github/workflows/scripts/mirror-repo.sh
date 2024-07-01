#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

function mirror-repo() {
    original_repo="$1"
    mirror_repo_name="$2"
    export GIT_SSH_COMMAND="ssh -v -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -l ${INPUT_SSH_USERNAME}"
    git clone --bare "${original_repo}" original.git
    cd original.git

    curl -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_PRIVATE_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/orgs/minemacs/repos \
        -d "{\"name\":\"Hello-World\",\"description\":\"This is a mirror of ${original_repo}\",\"homepage\":\"https://github.com\",\"private\":false,\"has_issues\":true,\"has_projects\":true,\"has_wiki\":true}"

    git remote add mirror "git@github.com:minemacs/${mirror_repo_name}"

    # TODO: smart handling of push (don't force by default)
    git push --tags --force --prune mirror "refs/remotes/origin/*:refs/heads/*"

    # NOTE: Since `post` execution is not supported for local action from './' for now, we need to
    # run the command by hand.
    # "${SCRIPT_DIR}/cleanup.sh" mirror
}

mirror-repo "$1" "$2"
