#!/bin/bash

REMOTE="all"

read -p "Primary Remote: " primary
if [ -z "$primary" ]; then exit 1; fi

read -p "Secondary Remote: " secondary
if [ -z "$secondary" ]; then exit 1; fi

# Add remote with multiple push URLs (https://konstantintutsch.com/blog/multiple-push-urls-single-git-remote/)
git remote add "$REMOTE" "$primary"
git remote set-url --add --push "$REMOTE" "$primary"
git remote set-url --add --push "$REMOTE" "$secondary"

# Confirm configuration
git remote -v | grep --color=never "$REMOTE"
