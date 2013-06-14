
#
# hxinotify
#
# For debug build set: debug=true
#

OS = Linux
NDLL_FLAGS =
HXCPP_FLAGS =

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
OS = Linux64
NDLL_FLAGS += -DHXCPP_M64
HXCPP_FLAGS += -D HXCPP_M64
else ifeq (${uname_M},armv6l)
OS = LinuxARM6
else ifeq (${uname_M},armv7l)
HXCPP_FLAGS += -D HXCPP_ARM6
OS = LinuxARM6
HXCPP_FLAGS += -D HXCPP_ARM6
endif

SRC = sys/io/Inotify*.hx
SRC_DEMO = $(SRC) example/*.hx example/*.hxml
NDLL = ndll/$(OS)/inotify.ndll
HX_DEMO = haxe  -main InotifyDemo -cp ../ $(HXCPP_FLAGS)

ifeq (${debug},true)
HX_DEMO += -debug
else
HX_DEMO += --no-traces -dce full
endif

all: ndll

$(NDLL): src/*.cpp
	@(cd src;haxelib run hxcpp build.xml $(NDLL_FLAGS);)

ndll: $(NDLL)

example-cpp: $(NDLL) $(SRC_DEMO)
	cd example && haxe build-cpp.hxml $(HXCPP_FLAGS)

example-neko: $(NDLL) $(SRC_DEMO)
	cd example && haxe build-neko.hxml

example: example-neko example-cpp

hxinotify.zip: clean ndll
	zip -r hxinotify.zip example/ ndll/ src/hxinotify.cpp src/build.xml sys haxelib.json README.md

haxelib: hxinotify.zip

install: haxelib
	haxelib local hxinotify.zip

uninstall:
	haxelib remove hxinotify

clean:
	rm -rf example/cpp
	rm -f example/test*
	rm -rf ndll/$(OS)
	rm -rf src/obj
	rm -f src/all_objs
	rm -f hxinotify.zip

.PHONY: ndll example-cpp example-neko example haxelib install uninstall clean
