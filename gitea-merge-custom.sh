#!/bin/zsh

set -e # exit if any command fails

read "pr?PR: "

read "target_branch?Target Branch: "

read "source_branch?Source Branch: "

git checkout --quiet "${target_branch}"
git merge --signoff -m "merge: ${source_branch} (#${pr})" "gitea/${source_branch}"
