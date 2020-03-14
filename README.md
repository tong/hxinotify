
# HXInotify

[![Build Status](https://travis-ci.org/tong/hxinotify.svg?branch=master)](https://travis-ci.org/tong/hxinotify) [![Haxelib Version](https://img.shields.io/github/tag/tong/hxinotify.svg?style=flat&label=haxelib)](https://lib.haxe.org/p/inotify)

Haxe-(C++|Hashlink|Neko) bindings to *inotify*, a linux kernel subsystem that acts to extend filesystems to notice changes and report those changes to applications.


Inotify can be used to automatically update directory views, reload configuration files, log changes, backup, synchronize, and upload.

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

- C++/Neko (ndll): `haxelib run hxcpp build.xml`

- Hashlink: https://github.com/tong/hlinotify


## Usage

https://github.com/tong/hxinotify/tree/master/example
