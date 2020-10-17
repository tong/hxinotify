
# HXInotify

[![Actions Status](https://github.com/tong/hxinotify/workflows/CI/badge.svg)](https://github.com/tong/hxinotify) [![Haxelib Version](https://img.shields.io/github/tag/tong/hxinotify.svg?style=flat-square&colorA=EA8220&colorB=FBC707&label=haxelib)](http://lib.haxe.org/p/inotify/)

Haxe-(Cpp|Hashlink|Neko) bindings to *inotify*, a linux kernel subsystem that acts to extend filesystems to notice changes and report those changes to applications.


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

- Cpp/Neko (ndll): `haxelib run hxcpp build.xml`
- Hashlink: https://github.com/tong/hlinotify


## Usage

See [example](https://github.com/tong/hxinotify/blob/master/example/App.hx)
