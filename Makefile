
#
# hxinotify
#

NDLL = inotify.ndll
NDLL_LINUX32 = ndll/Linux/$(NDLL)
NDLL_LINUX64 = ndll/Linux64/$(NDLL)
NDLL_RPI = ndll/RPi/$(NDLL)

HXCX = haxelib run hxcpp build.xml

all: linux64 test

linux:
	@(cd src;$(HXCX))

linux64:
	@(cd src;$(HXCX) -DHXCPP_M64)

raspberry: $(NDLL_RPI)
	@(cd src;$(HXCX))

test:
	(cd test; haxe build.hxml; cp bin/TestInotify ./;)
	cp $(NDLL_LINUX64) test/

clean:
	rm -rf ndll
	rm -rf src/obj
	rm -f src/all_objs
	rm -rf test/bin

.PHONY: linux linux64 raspberry test clean
