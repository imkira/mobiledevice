[日本語はこちら](https://github.com/imkira/mobiledevice/blob/master/README_JP.md)

mobiledevice
============

[![Build Status](https://travis-ci.org/imkira/mobiledevice.png)](https://travis-ci.org/imkira/mobiledevice)

mobiledevice is a command line utility for interacting with Apple's Private
Mobile Device Framework.  It can be used for automating some tasks like
installing and uninstalling apps on your iPhone/iPad without having to manually
do it via Xcode or iTunes.  You don't need a jailbroken device!

## Requirements

* iPhone 3G and above should work / iPad too (tested on iPhone 4, 5, 6).
* Plug in your iPhone/iPad to your Mac via USB.
* In order to install apps on the device, you need the iOS development
  certificates previously installed.
* Mac OS X 10.6 and above.
* XCode 3 or above with iOS SDK installed.
* You need to compile the tool and optionally install it.

## Installation

### Homebrew

If you use [homebrew](http://brew.sh), you can install mobiledevice by
executing:

```shell
brew update
brew install mobiledevice
```

### Manual

To compile mobiledevice, open a terminal console and type:

```shell
git clone git://github.com/imkira/mobiledevice.git
cd mobiledevice
make
```

To install mobiledevice in your system, proceed with:

```shell
make install
```

## Usage

### Help

After compiling/installing mobiledevice, open a terminal console.

For the usage screen, you can type

```shell
mobiledevice help
```

and the following will be displayed:

```
mobiledevice help
  Display this help screen

mobiledevice version [options]
  Display program version.
  Options:
    -r: Include revision identifier

mobiledevice list_devices [options]
  Display UDID of each connected devices.
  Options:
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)
    -n <count> : Limit the number of devices to be printed

mobiledevice list_device_props [options]
  List all property names of device.
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice get_device_prop [options] <prop_name>
  Display value of device property with given name.
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice list_apps [options]
  Lists all apps installed on device
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice list_app_props [options] <bundle_id>
  List all property names of app with given bundle id.
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice get_app_prop [options] <bundle_id> <prop_name>
  Display value of app property with given name.
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice install_app [options] <path_to_app>
  Install app (.app folder) to device
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice uninstall_app [options] <bundle_id>
  Uninstall app with given bundle id from device
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice tunnel [options] <from_port> <to_port>
  Forward TCP connections to connected device
  Options:
    -u <udid> : Filter by device UDID (default: first detected device)
    -t <timeout>: Timeout (in ms) to wait for devices (default: 1)

mobiledevice get_bundle_id <path_to_app>
  Display bundle identifier of app (.app folder)
```

On failure, all commands exit with status code set to a non-zero value, and
some print messages to stderr indicating the kind of error.

On success,  all commands exit with status code set to 0.

### List devices

To list all connected devices, you can type

```
mobiledevice list_devices
```

And all devices will be listed by UDID like the following:

```
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
7c211433f02071597741e6ff5a8ea34789abbf43
0ab8318acaf6e678dd02e2b5c343ed41111b393d
```

In the previous example, there are 3 connected devices.
If you want to limit the number of results you can pass the ```-n <count>```
flag as follows:

```
mobiledevice list_devices -n 1
```

The output will be, as expected, trimmed to one device.

```
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
```

### List device properties

To list all properties about a device, you can type:

```
mobiledevice list_device_props
```

The output should be something like:

```
ActivationPublicKey
ActivationState
ActivationStateAcknowledged
BasebandSerialNumber
BasebandStatus
BasebandVersion
BluetoothAddress
BuildVersion
CPUArchitecture
DeviceCertificate
DeviceClass
DeviceColor
DeviceName
DevicePublicKey
DieID
...
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice list_device_props -u 7c211433f02071597741e6ff5a8ea34789abbf43
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.

### Get device property value

To display the value of a device property with a given name, you can type:

```
mobiledevice get_device_prop property_name
```

For example to get information on the product type of the device, you can use ```ProductType``` as property name:

```
mobiledevice get_device_prop ProductType
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice get_device_prop -u 7c211433f02071597741e6ff5a8ea34789abbf43
property_name
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.
* On successful execution, the output consists of the value followed by a
  newline character.

### List applications

To get the list of installed apps, type:

```
mobiledevice list_apps
```

The output should be something like:

```
com.apple.VoiceMemos
com.apple.mobiletimer
com.apple.AdSheetPhone
com.apple.weather
com.apple.iphoneos.iPodOut
com.apple.mobilesafari
com.apple.Preferences
...
com.mycompany.myapp1
com.mycompany.myapp2
...
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice list_apps -u 7c211433f02071597741e6ff5a8ea34789abbf43
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.

### List application properties

To display the value of a device property with a given name, you can type:

```
mobiledevice list_app_props com.mycompany.myapp
```

The output should be something like:

```
SBIconClass
CFBundleInfoDictionaryVersion
Entitlements
DTPlatformVersion
CFBundleName
DTSDKName
ApplicationType
UIViewControllerBasedStatusBarAppearance
CFBundleIcons
UIStatusBarStyle
Container
LSRequiresIPhoneOS
CFBundleDisplayName
PrivateURLSchemes
UIBackgroundModes
DTSDKBuild
...
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice list_app_props -u 7c211433f02071597741e6ff5a8ea34789abbf43 com.mycompany.myapp
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.

### Get application property value

To display the value of an application property with a given name, you can type:

```
mobiledevice get_app_prop com.mycompany.myapp property_name
```

For example to get the path where Apple's Weather app is installed on the device, you can use ```Path``` as property name:

```
mobiledevice get_app_prop com.apple.weather Path
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice get_app_prop -u 7c211433f02071597741e6ff5a8ea34789abbf43 com.mycompany.myapp Path
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.
* On successful execution, the output consists of the value followed by a
  newline character.

### Install application

To install an app on the device, you can type:

```
mobiledevice install_app path/to/my_application.app
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice install_app -u 7c211433f02071597741e6ff5a8ea34789abbf43 path/to/my_application.app
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.

### Uninstall application

To uninstall an app from the device, pass in the bundle identifier and type:

```
mobiledevice uninstall_app com.mycompany.myapp
```

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice uninstall_app -u 7c211433f02071597741e6ff5a8ea34789abbf43 com.mycompany.myapp
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.

### Forward (tunnel) TCP connections from Mac to the device

If your app creates a TCP server by listening on some port, it may be useful to
connect to it via USB (no need for WiFi/3G connection). mobiledevice allows
you to create a tunnel between your Mac and your device, via a USB cable.
If you connect to your Mac (on localhost or 127.0.0.1) mobiledevice will
forward that connection to the device on the specified port by typing something
like:

```
mobiledevice tunnel 8080 80
```

The previous example attempts to illustrate a tunnel between your Mac's TCP
port 8080 and the device's TCP port 80. The output would be something like:

```
Tunneling from local port 8080 to device port 80...
```

From this point you can `telnet localhost 8080` and communicate with the server
running at TCP port 80 on the mobile app!

To specify a different device, you can also append the ```-u <udid>``` flag as
follows:

```
mobiledevice tunnel -u 7c211433f02071597741e6ff5a8ea34789abbf43 8080 80
```

Notes:

* If ```-u <udid>``` is not provided, the first detect device will be used.
* Please note that if you keep the process open, it will keep forwarding
  connections. If and when you decide to terminate it (for instance, by
  pressing CTRL-C), it will terminate all currently tunnelled connections and
  stop accepting more connections to it.
* Also note that mobiledevice allows you to keep multiple connections open to
  the same TCP port on the device (by running a single instance of
  mobiledevice), or to different ports (by running multiple instances of
  mobiledevice and specifying the ports for each).

### Get the bundle identifier of an application

This is just an utility command, and is not related to the MobileDevice
Framework.  To get the bundle identifier (e.g. com.mycompany.myapp) of an .app
you can type the following command (bear in mind it must be a valid .app
folder, not a .ipa!):

```
mobiledevice get_bundle_id path/to/my_application.app
```

Notes:

* Please note that the previous path is on your local computer, not a path to the device.

## Contribute

Found a bug? Want to contribute and add a new feature?

Please fork this project and send me a pull request!

### Contributors

* ruudputs: Added initial support for multiple devices.
* leopatras: Simplified obj-c string-related code and adoption of ARC.
* 7bp: Fixed compilation issues.
* k-yamada: Fixed usage screen typos.

You can check the [full list here](https://github.com/imkira/mobiledevice/graphs/contributors).

## License

mobiledevice is licensed under the MIT license:

www.opensource.org/licenses/MIT
