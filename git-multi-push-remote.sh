#!/bin/zsh

REMOTE="all"

read "primary?Primary Remote: "
if [ -z "$primary" ]; then exit 1; fi

read "secondary?Secondary Remote: "
if [ -z "$secondary" ]; then exit 1; fi

# Add remote with multiple push URLs (https://konstantintutsch.com/blog/multiple-push-urls-single-git-remote/)
git remote add "$REMOTE" "$primary"
git remote set-url --add --push "$REMOTE" "$primary"
git remote set-url --add --push "$REMOTE" "$secondary"

# Confirm configuration
git remote -v | grep --color=never "$REMOTE"
