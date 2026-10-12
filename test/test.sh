#!/bin/sh
# Build native libs and run the test on hl, neko and cpp
cd "$(dirname "$0")/.."
haxelib run hxcpp build.xml > /dev/null || exit 1
cc -o inotify.hdll -shared -std=c11 -O3 -Wall -m64 -fPIC hlinotify.c -lhl || exit 1
cd test
status=0
run() { name=$1; shift; if timeout 10 "$@"; then echo "  ^ $name"; else echo "  ^ $name FAILED"; status=1; fi; }
haxe -cp .. -main Test -D inotify -hl test.hl && run hl env LD_LIBRARY_PATH=.. hl test.hl
haxe -cp .. -main Test -D inotify -neko test.n && run neko env NEKOPATH=../ndll/Linux64:${NEKOPATH:-/usr/lib/neko} neko test.n
haxe -cp .. -main Test -D inotify -cpp cpp > /dev/null && cp ../ndll/Linux64/inotify.ndll cpp/ && run cpp sh -c 'cd cpp && ./Test'
exit $status
