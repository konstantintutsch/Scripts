#!/bin/zsh

set -e # exit if any command fails

gh pr list

read "pr?Pull Request: "
if [ -z "${pr}" ]; then exit 1; fi

target_branch="$(gh pr view --json baseRefName ${pr} | jq '.baseRefName' | sed 's/"//g')"
echo "Target Branch: ${target_branch}"

gh pr checkout "${pr}"
source_branch="$(git rev-parse --abbrev-ref HEAD)"
echo "Source Branch: ${source_branch}"

git checkout "${target_branch}"
git commit --signoff "${source_branch}" -m "merge: ${source_branch} (#${pr})"
