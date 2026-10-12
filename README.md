# hxinotify

Haxe-Cpp|Hashlink|Neko bindings to **inotify**, a linux kernel subsystem that acts to extend filesystems to notice changes and report those changes to applications.

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

See: https://man7.org/linux/man-pages/man7/inotify.7.html

[![Actions Status](https://github.com/tong/hxinotify/workflows/CI/badge.svg)](https://github.com/tong/hxinotify) [![Haxelib Version](https://img.shields.io/github/tag/tong/hxinotify.svg?style=flat-square&colorA=EA8220&colorB=FBC707&label=haxelib)](http://lib.haxe.org/p/inotify/)

## Build

The haxelib package includes prebuilt ndlls for `Linux64` (x86_64) and `RPi` (64-bit Raspberry Pi OS, aarch64).
For other systems, build the native library from the sources shipped in the package (`cd $(haxelib libpath inotify)`).

- Cpp/Neko (inotify.ndll)
```sh
haxelib run hxcpp build.xml
```
On a Raspberry Pi this writes `ndll/RPi/inotify.ndll`, which hxcpp loads on every Pi.
Rebuild it on 32-bit Raspberry Pi OS (armv7l), since the prebuilt one is 64-bit.

- Hashlink (inotify.hdll)
```sh
cc -o inotify.hdll -shared -std=c11 -O3 -Wall -m64 -fPIC hlinotify.c -lhl
```
Omit `-m64` on ARM.


## Test

```sh
test/test.sh
```

## Usage

See [example](https://github.com/tong/hxinotify/blob/master/example/App.hx).
