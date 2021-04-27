# git-autoeverything
Git autocommit &amp; autosync script

This is the start of a bigger project. For now this only support autocommit and autosync (across two directories only for now).

# Usage

```bash
./git-auto.sh "/first/path /second/path"
```

# FAQ

- What happen if you use it on a single directory?
By default, it will decide to use that + the current directory as pair...so make sure you don't do that unless you know what you're doing.

- Can i write on both of these directories at the same time?
Yes, and No. I wouldn't recommend it for many reasons. Just choose either one as the "write" directory, and the other one as a backup/sync output...At least until i add support for multiple write handling.

- What if i use this on git repository(ies) that isn't created by this script?
I wouldn't recommend it, because that may or may not break something in the "git flow" of those repo(s)...Can't be really sure yet but i know your commit history will look weird if anything.If you really want though, look forward for newer update of this, which may or may not support this.

# TODO:

- Support for more features
- Support More directories for the autosync feature
- Make use of the autocommit across multiple repos
- Add watchman and inotify wait as alternative (given this only use git for now, which is good enough for small project)
- More protocols support beside local repos (ssh, etc)
- ???

Credit: https://github.com/ralfholly/git-autocommit
