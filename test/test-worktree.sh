#!/usr/bin/env bash

. "test/testlib.sh"

# git 2.5 or higher only
compare_version $(git version | cut -d" " -f3) "2.5.0"
if [[ $? == $VERSION_LOWER ]]; then
  echo "Skipping git worktree tests since git version < 2.5.0"
  exit
fi

begin_test "git worktree"
(
    set -e
    reponame="worktree-main"
    mkdir $reponame
    cd $reponame
    git init

    # can't create a worktree until there's 1 commit at least
    echo "a" > tmp.txt
    git add tmp.txt
    git commit -m "Initial commit"

    expected=$(printf "%s\n%s\n
LocalWorkingDir=$TRASHDIR/$reponame
LocalGitDir=$TRASHDIR/$reponame/.git
LocalGitStorageDir=$TRASHDIR/$reponame/.git
LocalMediaDir=$TRASHDIR/$reponame/.git/lfs/objects
TempDir=$TRASHDIR/$reponame/.git/lfs/tmp
ConcurrentTransfers=3
BatchTransfer=false
$(env | grep "^GIT")
" "$(git lfs version)" "$(git version)")
    actual=$(git lfs env)
    [ "$expected" = "$actual" ]

    worktreename="worktree-2"
    git worktree add "$TRASHDIR/$worktreename"
    cd "$TRASHDIR/$worktreename"

    # git dir in worktree is like submodules (except path is worktrees) but this
    # is only for index, temp etc
    # storage of git objects and lfs objects is in the original .git
    expected=$(printf "%s\n%s\n
LocalWorkingDir=$TRASHDIR/$worktreename
LocalGitDir=$TRASHDIR/$reponame/.git/worktrees/$worktreename
LocalGitStorageDir=$TRASHDIR/$reponame/.git
LocalMediaDir=$TRASHDIR/$reponame/.git/lfs/objects
TempDir=$TRASHDIR/$reponame/.git/worktrees/$worktreename/lfs/tmp
ConcurrentTransfers=3
BatchTransfer=false
$(env | grep "^GIT")
" "$(git lfs version)" "$(git version)")
    actual=$(git lfs env)
    [ "$expected" = "$actual" ]
)
end_test
