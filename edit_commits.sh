#!/bin/bash

count=1
N_to_squash="$(($1))"

echo "Combining first $1 commits together..."

while [ "$count" -le "$N_to_squash" ]
do
  if [[ $count -ne 1 ]]
  then
    sed -i '' "$count s/pick/squash/g" "$2"
  fi
  count="$((count+1))"
done
