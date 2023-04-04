#!/bin/bash

if [[ $(git status --porcelain) ]]
then
  echo "Your working tree is not clean, cannot continue."
  exit 1
fi

regex='^[0-9]+$'
current_branch=$(git branch --show-current)
total_commits=$(git rev-list --count HEAD)

if [[ $total_commits -eq 1 ]]  # I
then
  echo "Your current branch $current_branch has only 1 commit in history, no need in squashing."
  exit 1
fi

echo ""
echo "Total commits in your current branch $current_branch: $total_commits."
echo "*** - commits to squash, --- - commits to leave, T - total number of commits."
echo "(1) -------[T-N]***********HEAD       Squash last N commits."
echo "(2) *******[T-N]-----------HEAD       Squash all commits before [T-N] into one commit (leave only last N commits)."
read -p "Please, enter needed operation. (1/2): " choice


if [[ "$choice" -eq 1 ]]
then
  read -p "Enter N: " N

  if ! [[ $N =~ $regex ]]
  then
    echo "Wrong input for N."
    exit 1
  elif [[ $N -gt $total_commits ]]
  then
    echo "N=$N > $total_commits - number of commits in history of branch '$current_branch'."
    exit 1
  fi

  read -p "Enter commit message: " commit_msg

  if [[ -z "$commit_msg" ]]
  then
    echo "Commit message should be non-empty."
    exit 1
  fi

  echo "You want to squash last $N commits with message '$commit_msg' on branch '$current_branch'."
  read -p "Coninue? (Y/n): " confirm && [[ "$confirm" == [yY] ]] || exit 1

  echo ""
  echo "-----------------------------------------"
  echo ""

  if [[ $N -eq $total_commits ]]  # squashing ALL commits into one
  then
    git update-ref -d HEAD
    git commit -m "$commit_msg"
  else
    git reset --soft HEAD~"$N"
    git commit -m "$commit_msg"
  fi

  echo ""
  echo "-----------------------------------------"
  echo ""

  echo "Commit is done, N last commits are combined into one, you need force push into '$current_branch' to finish."
  echo ""

elif [[ "$choice" -eq 2 ]]  # II
then
  read -p "Enter N: " N

  if ! [[ $N =~ $regex ]]
  then
    echo "Wrong input for N."
    exit 1
  elif [[ $N -ge $((total_commits - 1)) ]]
  then
    echo "N=$N, commits in '$current_branch' - $total_commits. Chosen option is irrelevant."
    exit 1
  elif [[ $N -eq 0 ]]
  then
    echo "N=$N is irrelevant."
    exit 1
  elif [[ $N -eq 1 ]]
  then
    echo "For leaving only $N commit use option (1)."
  fi

  read -p "Enter commit message: " commit_msg

  if [[ -z "$commit_msg" ]]
  then
    echo "Commit message should be non-empty."
    exit 1
  fi

  echo "You want to leave last $N commits and squash all before them with message '$commit_msg' on branch '$current_branch'."
  read -p "Coninue? (Y/n): " confirm && [[ "$confirm" == [yY] ]] || exit 1

  echo ""
  echo "-----------------------------------------"
  echo ""
  # HEAD~"$((total_commits))" is impossible so root state is used.
  # GIT environment variables are used to avoid user-required actions
  GIT_EDITOR="echo $commit_msg > " GIT_SEQUENCE_EDITOR="bash edit_commits.sh $((total_commits-N)) " git rebase -i --root

  echo ""
  echo "-----------------------------------------"
  echo ""

  echo "Commit is done, first N commits are combined into one, you need force push into '$current_branch' to finish."
  echo ""

fi
