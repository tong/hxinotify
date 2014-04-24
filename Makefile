
##
## hxinotify
##

PROJECT=inotify
OS=Linux
NDLL_FLAGS=
HXCPP_FLAGS=

ARCH:=$(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${ARCH},x86_64)
	OS=Linux64
	NDLL_FLAGS+=-DHXCPP_M64
	HXCPP_FLAGS+=-D HXCPP_M64
else ifeq (${ARCH},armv6l)
	OS=RPi
	HXCPP_FLAGS+=-D RPi
else ifeq (${ARCH},armv7l)
	OS=RPi
	HXCPP_FLAGS+=-D RPi
endif

ifeq (${os},android)
	OS=Android
	NDLL_FLAGS=-Dandroid
	HXCPP_FLAGS=-D android
endif

SRC=sys/io/Inotify*.hx
SRC_EXAMPLE=$(SRC) example/*.hx example/*.hxml
NDLL=ndll/$(OS)/inotify.ndll

ifeq (${debug},true)
	HX_DEMO+=-debug
else
	HX_DEMO+=--no-traces -dce full
endif

all: ndll

$(NDLL): src/*.cpp src/build.xml
	@(cd src && haxelib run hxcpp build.xml $(NDLL_FLAGS);)

ndll: $(NDLL)

example-cpp: $(SRC_EXAMPLE)
	@(cd example;haxe build-cpp.hxml $(HXCPP_FLAGS);)

example-neko: $(SRC_EXAMPLE)
	@(cd example;haxe build-neko.hxml)

examples: example-neko example-cpp

haxedoc.xml: sys/io/Inotify.hx
	haxe haxedoc.hxml

inotify.zip: clean ndll haxedoc.xml
	zip -r $@ ndll/ src/*.cpp src/build.xml sys/io/Inotify.hx haxedoc.hxml haxelib.json Makefile README.md -x _*

haxelib: inotify.zip

install: haxelib
	haxelib local inotify.zip

uninstall:
	haxelib remove inotify

clean:
	rm -rf example/cpp
	rm -f example/inotify-example*
	rm -rf ndll/$(OS)
	rm -rf src/obj
	rm -f src/all_objs
	rm -f inotify.zip
	rm -f haxedoc.xml

.PHONY: ndll example-cpp example-neko examples haxelib install uninstall clean
