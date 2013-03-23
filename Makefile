
#
# hxinotify
#

all: build

raspberry:
	(cd src; haxelib run hxcpp build.xml)

linux64:
	(cd src; haxelib run hxcpp build.xml -DHXCPP_M64)

test:
	(cd test; haxe build.hxml)

build: linux64 test

clean:
	rm -rf ndll
	rm -rf src/obj
	rm -f src/all_objs

