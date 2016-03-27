
# HXINOTIFY

Haxe-Cpp/Neko bindings to [inotify](http://en.wikipedia.org/wiki/Inotify), a inode-based filesystem notification technology for monitoring filesystem events.

Inotify can be used for:
* Detecting changes in files and directories (e.g. configuration files, mail directories)
* Guarding critical files and their eventual automatic recovery
* File usage statistics and similar purposes
* Automatic upload handling
* Monitoring installations outside of packaging systems
* Automatic on-change backup and/or versioning
* Reflecting changes to search databases
* ...

Inotify is useful in many situations where reactions on file system changes are necessary.
Without inotify it can be implemented by periodical (or manually requested) examining files and directories, but such way is slow and wastes processor time. Inotify brings very fast and economical method how to react on file system changes.

Hxinotify has no requirements except a supporting linux kernel (>=2.6.13).

[![Build Status](https://travis-ci.org/tong/hxinotify.svg?branch=master)](https://travis-ci.org/tong/hxinotify) [![Haxelib Version](https://img.shields.io/github/tag/tong/hxinotify.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/inotify)
