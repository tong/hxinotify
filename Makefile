
ARCH := $(shell sh -c 'uname -m 2>/dev/null || echo not')
OS = Linux
NDLL_FLAGS =
#HXCPP_FLAGS =

ifeq (${ARCH},x86_64)
	OS = Linux64
	NDLL_FLAGS += -DHXCPP_M64
else ifeq (${ARCH},armv6l)
	OS = RPi
else ifeq (${ARCH},armv7l)
	OS = RPi
endif

ifeq (${os},android)
	OS = Android
	NDLL_FLAGS += -Dandroid
endif

SRC = src/sys/io/Inotify*.hx
NDLL = ndll/$(OS)/inotify.ndll

all: ndll haxedoc.xml

$(NDLL): lib/*.cpp lib/build.xml
	@(cd lib && haxelib run hxcpp build.xml $(NDLL_FLAGS);)

ndll: $(NDLL)

haxedoc.xml: $(SRC)
	haxe haxedoc.hxml

inotify.zip: clean ndll haxedoc.xml
	zip -r $@ ndll/ src/ haxedoc.xml haxelib.json README.md -x _*

release: inotify.zip

clean:
	rm -rf doc/
	rm -rf example/cpp
	rm -rf ndll/$(OS)
	rm -rf project/obj
	rm -f project/all_objs
	rm -f haxedoc.xml
	rm -f inotify.zip

.PHONY: all ndll release clean
