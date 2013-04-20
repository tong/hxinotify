
#
# hxinotify
#

OS =
NDLL_FLAGS =
HXCPP_FLAGS =

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')

ifeq (${uname_M},x86_64)
OS = Linux64
NDLL_FLAGS = -DHXCPP_M64
HXCPP_FLAGS = -D HXCPP_M64
else ifeq (${uname_M},armv6l)
OS = RPi
else
OS = Linux
endif

NDLL = ndll/$(OS)/inotify.ndll

all: ndll

$(NDLL): src/*.cpp Makefile
	@echo "Building ndll for : $(OS)"
	(cd src;haxelib run hxcpp build.xml $(NDLL_FLAGS);)

ndll: $(NDLL)

demo: $(NDLL) demo/*.hx demo/build-*.hxml
	@echo 'Building demo application ...'
	(cd demo;haxe build-neko.hxml)
	(cd demo;haxe build-cpp.hxml $(HXCPP_FLAGS);)
	cp demo/bin/InotifyDemo demo/inotify-demo
	cp $(NDLL) demo/
	
clean:
	rm -rf ndll/
	rm -rf src/obj
	rm -f src/all_objs
	rm -rf demo/bin

.PHONY: ndll demo clean