#!/bin/bash

# check
git log -p
read -p "Is that correct?: " push
if [[ "$push" == "y" ]]
then
  echo "Pushing …"
  # push
  git pull --rebase && pkgdev push -A
else
  echo "Aborted."
fi
