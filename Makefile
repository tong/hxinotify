
#
# hxinotify
#
# 
# This Makefile works by default for Linux32
# You can active other OS support by compiling with the following options
#
# For Linux32
#   make os=linux32
#   make os=linux
#   make
#
# For Linux64
#   make os=linux64
#
# For RaspberryPi
#   make os=rpi
#

OS = Linux
SRC = src/*.cpp
FLAGS_NDLL = 
FLAGS_DEMO = 

ifeq (${os},linux32)
OS = Linux
else ifeq (${os},linux64)
OS = Linux64
FLAGS_NDLL += -DHXCPP_M64
FLAGS_DEMO += -D HXCPP_M64
else ifeq (${os},rpi)
OS = RPi
FLAGS_NDLL += -Drpi
endif

NDLL = ndll/$(OS)/inotify.ndll

all: build

$(NDLL): $(SRC)
	@echo 'Building ndll for : '$(OS)
	@(cd src;haxelib run hxcpp build.xml $(FLAGS_NDLL);)
ndll: $(NDLL)

demo: $(NDLL) demo/*.hx demo/build-*.hxml
	@echo 'Building demo application ...'
	(cd demo;haxe build-neko.hxml)
	(cd demo;haxe build-cpp.hxml $(FLAGS_DEMO);)
	cp demo/bin/InotifyDemo demo/inotify-demo
	cp $(NDLL) demo/

build: ndll demo

clean:
	rm -rf ndll/
	rm -rf src/obj
	rm -f src/all_objs
	rm -rf demo/bin

.PHONY: ndll demo build clean
