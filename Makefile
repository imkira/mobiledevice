CC = clang
PREFIX = /usr/local
sources := $(wildcard *.m)
headers := $(wildcard *.h)

.PHONY: all install clean

all: mobiledevice

mobiledevice: $(sources) $(headers)
	$(CC) -Wall -fobjc-arc -o mobiledevice -framework CoreFoundation -framework Cocoa -framework MobileDevice -F/System/Library/PrivateFrameworks $(sources)

install: mobiledevice
	install -d ${PREFIX}/bin
	install mobiledevice ${PREFIX}/bin

clean:
	rm -rf mobiledevice
