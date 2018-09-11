MOBILEDEVICE_CLI_VERSION=\"2.0.0\"
MOBILEDEVICE_CLI_REVISION=\"$(shell git rev-parse HEAD)\"
DEFINES=-DMOBILEDEVICE_CLI_VERSION=$(MOBILEDEVICE_CLI_VERSION) -DMOBILEDEVICE_CLI_REVISION=$(MOBILEDEVICE_CLI_REVISION)

CC = clang
PREFIX = /usr/local
sources := $(wildcard *.m)
headers := $(wildcard *.h)

.PHONY: all install clean

all: mobiledevice

mobiledevice: $(sources) $(headers)
	./symlink_framework.sh
	$(CC) -Wall -fobjc-arc -o mobiledevice -framework CoreFoundation -framework Cocoa -framework MobileDevice -FFrameworks $(DEFINES) $(sources)

install: mobiledevice
	install -d ${PREFIX}/bin
	install mobiledevice ${PREFIX}/bin

clean:
	rm -rf Frameworks
	rm -rf mobiledevice
