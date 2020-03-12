
# HXInotify

[![Build Status](https://travis-ci.org/tong/hxinotify.svg?branch=master)](https://travis-ci.org/tong/hxinotify) [![Haxelib Version](https://img.shields.io/github/tag/tong/hxinotify.svg?style=flat&label=haxelib)](https://lib.haxe.org/p/inotify)

Haxe C++/Hashlink/Neko bindings to [inotify](http://en.wikipedia.org/wiki/Inotify), a linux kernel subsystem that acts to extend filesystems to notice changes and report those changes to applications.

It can be used to monitor individual files or directories.
When a directory is monitored, inotify will return events for the directory itself, and for files inside the directory.

Inotify can be used for:
 * Detecting changes in files and directories (e.g. configuration files, mail directories)
 * Guarding critical files and their eventual automatic recovery
 * File usage statistics and similar purposes
 * Automatic upload handling
 * Monitoring installations outside of packaging systems
 * Automatic on-change backup and/or versioning
 * Reflecting changes to search databases
 * …

See: http://man7.org/linux/man-pages/man7/inotify.7.html


## Build

Build `inotify.ndll` for cpp/neko:  
`haxelib run hxcpp build.xml ndll`

For hashlink: https://github.com/tong/hlinotify
