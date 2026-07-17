#!/bin/zsh

set -e # exit if any command fails

REMOTE="gitea"

read "pr?PR: "

read "target_branch?Target Branch: "

read "source_branch?Source Branch: "

git fetch "${REMOTE}" "${source_branch}"
git pull --ff-only "${REMOTE}" "${source_branch}"

git checkout --quiet "${target_branch}"
git merge --signoff -m "merge: ${source_branch} (#${pr})" "${REMOTE}/${source_branch}"
