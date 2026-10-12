### 2.1.0
- Fix `NONBLOCK` and `CLOEXEC` flag values (`new Inotify(true)` always failed)
- Non-blocking `read()` returns an empty array when no events are available
- Fix infinite loop parsing event names on cpp
- `addWatch` no longer resolves the path (fixes `DONT_FOLLOW`)
- Native calls return `-errno` on failure
- Blocking `read()` no longer stalls GC in other threads (hl, cpp)
- `fd` is public (read-only)
- Fix HL/C: primitives linked against libc's `inotify_*` functions; rebuild `inotify.hdll`
- Ship native sources for building the ndll/hdll
- RPi ndll is now 64-bit (aarch64); rebuild it on 32-bit Raspberry Pi OS

### 2.0.1
- Fix neko/cpp file name length

### 2.0.0
- Read event data on haxe side
- Hashlink support (https://github.com/tong/hlinotify)
- All methods return status code

### 1.3.0
- @:require(sys)
- @:enum abstract InotifyMask(Int) instead of inline class fields

### 1.2.2
- Haxe source moved into src directory, cpp code into project
- Exclude c++ source files from haxelib

### 1.2.1
- Fix

### 1.2
- Removed hxinotify.h
- Static cpp methods
- Renamed hxinotify.cpp : inotify.cpp
- Removed throwErrno
- Added value checks
- Fixed write descriptor event

### 1.1
- Fixed result array size
- Added haxedoc.hxml

### 1.0
- Initial release
