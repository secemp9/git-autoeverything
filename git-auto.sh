#!/usr/bin/env bash

gac() {
GIT_AUTOCOMMIT_VERSION="1.3"
GIT_AUTOCOMMIT_MESSAGE="<git-autocommit>"
GIT_AUTOCOMMIT_SECONDS=1
GIT_AUTOCOMMIT_VERBOSE=0
GIT_AUTOCOMMIT_QUIET=0

git_autocommit_commit_count=0

set -o errexit

function fatal
{
    echo $1 >&2
    exit 1
}

function print_autocommit_stats
{
    if [ "$GIT_AUTOCOMMIT_QUIET" -eq 0 ]; then
        ((++git_autocommit_commit_count))
        printf "\rLast commit: $(date +'%Y-%m-%d %H:%M:%S'), commits: $git_autocommit_commit_count ..., TotalSize: $(du -sh .)"
    fi
}

function verbose_log
{
    if [ "$GIT_AUTOCOMMIT_VERBOSE" -ne 0 ] && [ "$GIT_AUTOCOMMIT_QUIET" -eq 0 ]; then
        echo ""
        echo "$1"
    fi
}

# Returns 0 if changes have been auto-commited, 1 if not.
function autocommit
{
    local files="$(git status --porcelain)"
    if [ ! -z "$files" ]; then
        verbose_log "$files"
        # Add everything that is there.
        git add -A >/dev/null
        # Commit
        git commit -q -m "$GIT_AUTOCOMMIT_MESSAGE" >/dev/null
        print_autocommit_stats
        return 0
    fi

    return 1
}

# Returns 0 if true, 1 if false.
function is_last_commit_autocommit
{
    local line=$(git log --pretty=oneline -n 1)
    local array_line=($line)
    local commit=${array_line[0]}
    local message=${array_line[1]}

    if [ "$message" == "$GIT_AUTOCOMMIT_MESSAGE" ]; then
        return 0 # Yes
    fi

    return 1 # No
}

function init
{
  dir="$@"
  or="$dir"
  ne="$dir/.git"
  if [ -d "$ne" ]; then
    :
  else
    echo "$ne does not exist: creating one for you..."
    git init "$or"
  fi
}

function both_ways
{
for i in "${arr[@]}"
do
   init "$i" #or do whatever with individual element of the array
done
add_remote
}

function current_one
{
arr+=("$(pwd)")
for i in "${arr[@]}"
do
   init "$i"
done
add_remote
}

function add_remote
{   
for (( i=0, j=${#arr[@]} - 1; i<${#arr[@]}; ++i, --j ))
do
    cd "${arr[i]}"
    if [ -z "$(git remote -v)" ]; then
        git remote add "${arr[j]//[^[:alnum:]_-]/_}" "${arr[j]}"
    else
        :
    fi
done
}

function two_be_or_not
{
	read -a arr <<< "$@"
	if [ ${#arr[@]} == 0 ]; then
	    fatal "Need at least one PATH"
	elif [ ${#arr[@]} == 1 ]; then
	    current_one
	elif [ ${#arr[@]} == 2 ]; then
	    both_ways
	elif [ ${#arr[@]} > 2 ]; then
	    fatal "Only support two PATH for now"
	else
	    fatal "ERROR ???" # Might happen for whatever reason if there negative values...
	fi
to_be
}

function to_be
{
for (( i=0, j=${#arr[@]} - 1; i<${#arr[@]}; ++i, --j ))
do
    cd "${arr[i]}"
	if [ -z "$(git rev-list --all)" ]; then
	    git pull "${arr[j]//[^[:alnum:]_-]/_}" master
	else
	    :
	fi
done
}

function sync
{
for (( i=0, j=${#arr[@]} - 1; i<${#arr[@]}; ++i, --j ))
do
    cd "${arr[i]}"
    git pull "${arr[j]//[^[:alnum:]_-]/_}" master
done
}

function show_help
{
cat <<EOM
git-autocommit -- Periodically commits uncommitted changes.
Version $GIT_AUTOCOMMIT_VERSION, Copyright 2015 by Ralf Holly.
Licensed under the terms of the MIT License, see LICENSE file.

Options:
    -h          Show help.
    -s          Soft reset to parent commit of an auto-commit sequence.
                (useful for squashing autocommits into a meaningful topic commit.)
    -i <secs>   Set check-for-modifications interval to <secs> seconds.
    -q          Quiet (no output).
    -V          Enable verbose output.
EOM
}

# If ':' at beginning -> silent error mode!
while getopts ":hVqis:" opt; do
    case $opt in
        h)
            show_help
            exit
            ;;
        s)
            two_be_or_not "$OPTARG"
            ;;
        V)
            GIT_AUTOCOMMIT_VERBOSE=1
            ;;
        i)
            GIT_AUTOCOMMIT_SECONDS="$OPTARG"
            if [ -z "$GIT_AUTOCOMMIT_SECONDS" ] || [ "$GIT_AUTOCOMMIT_SECONDS" -le "0" ]; then
                fatal "Please provide a positive poll interval"
            fi
            verbose_log "Setting poll interval to $GIT_AUTOCOMMIT_SECONDS seconds"
            ;;
        q)
            GIT_AUTOCOMMIT_QUIET=1
            ;;
        :)
            fatal "Option -$OPTARG requires an argument"
            ;;
        ?)
            fatal "Wrong option provided: -$OPTARG"
            ;;
    esac
done

autoall() {
for i in "${arr[@]}"
do
   cd "$i" #or do whatever with individual element of the array
   autocommit && sync || true
   sleep "$GIT_AUTOCOMMIT_SECONDS"
done
}

while true; do
    autoall
done
}

gac -s "$@" -V
