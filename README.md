HXINOTIFY
=========
Haxe/Cpp/Neko bindings to inotify.

Inotify is an inode-based filesystem notification technology for monitoring various filesystem events.

Inotify can be used for such tasks:
* detecting changes in files and directories (e.g. configuration files, mail directories)
* guarding critical files and their eventual automatic recovery
* file usage statistics and similar purposes
* automatic upload handling
* monitoring installations outside of packaging systems
* automatic on-change backup and/or versioning
* reflecting changes to search databases
* ...

Inotify is useful in many situations where reactions on file system changes are necessary. Without inotify it can be implemented by periodical (or manually requested) examining files and directories. But such way is slow and wastes processor time.
Inotify brings very fast and economical method how to react on file system changes.


HXInotify has no requirements except a supporting linux kernel (>=2.6.13).
