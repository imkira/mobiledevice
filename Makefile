CC = clang
#IOS_SDK = $(shell xcode-select --print-path)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.0.sdk
#DEVICE_SUPPORT = $(shell xcode-select --print-path)/Platforms/iPhoneOS.platform/DeviceSupport

all: mobiledevice

mobiledevice: mobiledevice.m
	$(CC) -Wall -fobjc-arc -o mobiledevice -framework CoreFoundation -framework Cocoa -framework MobileDevice -F/System/Library/PrivateFrameworks mobiledevice.m

clean:
	rm -rf mobiledevice
