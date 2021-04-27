# git-autoeverything
Git autocommit &amp; autosync script

This is the start of a bigger project. For now this only support autocommit and autosync (across two directories only for now).

# Usage


Don't forget to `chmod +x` it first.

```bash
./git-auto.sh "/first/path /second/path"
```

# Why

Well, let's say, While i do know some alternative for syncing two directories (git-annex, rsync, etc) I preferred to make my own, because some of those didn't work the way i wanted, didn't work in all situations i wanted (rsync), or just had a steep learning curve (looking at you git-annex).

# Workflow

```
                |Data|    
                  |
|--------|<-------|                 |--------|
| folder |                          | folder |
|        |     autosync to          |        |
|  main  |<------------------------>| second |
|--------|                          |--------|
```
Since the main one is already up to date after being synced to the second folder, and since the second should be empty, and thus have the same files, git will report "Still up to date" and stop.

autocommit is oneway only for now (to the main ones).

# FAQ

- What happen if you use it on a single directory?

By default, it will decide to use that + the current directory as pair...so make sure you don't do that unless you know what you're doing.

- Can i write on both of these directories at the same time?

Yes, and No. I wouldn't recommend it for many reasons. Just choose either one as the "write" directory, and the other one as a backup/sync output...At least until i add support for multiple write handling.

- What if i use this on git repository(ies) that isn't created by this script?

I wouldn't recommend it, because that may or may not break something in the "git flow" of those repo(s)...Can't be really sure yet but i know your commit history will look weird if anything. If you really want though, look forward for newer update of this, which may or may not support this.

- Can this work if the pair directories have different files/similar files?

Hard to say. The way the "autosync" work isn't the way it probably sounds like. Essentially, it sync one way, but check both ways (since it doesn't know which directory is supposed to be the "write" or the "sync" one here). So I would recommend to do this only if the other directory is empty for now, and wait for more updates to support different sync methods.

# TODO:

- Support for more features
- Support More directories for the autosync feature
- Make use of the autocommit across multiple repos
- Add watchman and inotify wait as alternative (given this only use git for now, which is good enough for small project)
- More protocols support beside local repos (ssh, etc)
- Add more comments
- ???

Credit: https://github.com/ralfholly/git-autocommit
