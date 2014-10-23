CC = clang
PREFIX = /usr/local

.PHONY: all install clean

all: mobiledevice

mobiledevice: mobiledevice.m mobiletunnel.c mobiledevice.h
	$(CC) -Wall -fobjc-arc -o mobiledevice -framework CoreFoundation -framework Cocoa -framework MobileDevice -F/System/Library/PrivateFrameworks mobiledevice.m mobiletunnel.c

install: mobiledevice
	install -d ${PREFIX}/bin
	install mobiledevice ${PREFIX}/bin

clean:
	rm -rf mobiledevice
