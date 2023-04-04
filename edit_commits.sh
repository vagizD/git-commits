#!/bin/bash

count=0
N_to_squash="$(($1-1))"

echo "Combining first $1 commits together..."

while [ "$count" -le "$N_to_squash" ]
do
  count="$((count+1))"
  if [[ $count -ne 1 ]]
  then
    sed -i '' "$count s/pick/squash/g" "$2"
  fi
done
