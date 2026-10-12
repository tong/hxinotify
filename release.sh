#!/bin/sh

## Build haxedoc.xml
haxe haxedoc.hxml

## Build demo application (test wise)
haxe --cwd example neko.hxml

rm -f ndll/*/*.hash
rm -f inotify.zip
zip -r inotify.zip ndll/ sys/ hlinotify.c hxinotify.cpp build.xml haxedoc.xml haxelib.json README.md CHANGES.md -x "*/\.*"

haxelib submit inotify.zip
