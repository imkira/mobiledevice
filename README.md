mobiledevice
============

mobiledevice is a command line utility for interacting with Apple's Private Mobile Device Framework.
It can be used for automating some tasks like installing and uninstalling apps on your iPhone/iPad
without having to manually do it via Xcode or iTunes.
You don't need a jailbroken device!

## Requirements

* iPhone 3G and above should work / iPad too (tested on iPhone 4).
* iOS development certificate installed previously on device.
* Mac OS X 10.6 and above (tested on Snow Leopard but should work on Lion too).
* XCode 3 or 4 + iOS SDK.
* Plug in your iPhone/iPad to your Mac via USB.
* You need to compile the tool and optionally install it.

## Compilation & Installation

To compile (and optionally install) mobiledevice, open a terminal console and type:

```
git clone git://github.com/imkira/mobiledevice.git
cd mobiledevice
rake
# to install system-wide (under /usr/local/bin) type the command below too:
rake install
```

## Usage

After compiling/installing mobiledevice, open a terminal console.

To get the screen explaining the usage you can type

```
mobiledevice
```

and you can see the following usage screen:

```
Usage: mobiledevice <command>

<Commands>
  get_udid                     : Display UDID of connected device
  get_bundle_id <path_to_app>  : Display bundle identifier of app (.app folder)
  install_app <path_to_app>    : Install app (.app folder) to device
  uninstall <bundle_id>        : Uninstall app by bundle id
  list_installed_apps          : Lists all installed apps on device
  tunnel <from_port> <to_port> : Forward TCP connections to connected device
```

On failure, all commands exit with status code set to a non-zero value
(including the usage screen above), and some print messages to stderr
indicating the kind of error.

On success,  all commands exit with status code set to 0. With the exception
of list_installed_apps command, all should return some output on stdout 
(like "OK" to signal success).

## Examples

### Get the UDID of the connected device

This command is useful for using on other tools (like UIAutomator's "-w" parameter):

```
mobiledevice get_udid
```

### Get the bundle identifier of an application

This is just an utility command, it is not related to the Mobile Device Framework.
To get the bundle identifier (e.g. com.mycompany.myapp) of an .app you can type
the following command (bear in mind it must be a valid .app folder, not a .ipa!):

```
mobiledevice get_bundle_id path/to/my_application.app
```

### Install an application on the connected device

To install an app on the connected device, like iTunes/Xcode would do, type:

```
mobiledevice install_app path/to/my_application.app
```

### Uninstall an application on the connected device

To uninstall an app from the connected device, pass in the bundle identifier and type:

```
mobiledevice uninstall_app com.mycompany.myapp
```

### Get a list of installed apps

To get a list of installed apps (by bundle identifyer), type:

```
mobiledevice list_installed_apps
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

### Forward (tunnel) TCP connections from Mac to the connected device

If your mobile app creates a TCP server by listening on some port,
it may be useful to connect to it via USB (no need for WiFi/3G connection).
mobiledevice allows you to create a tunnel between your Mac and your device,
via a USB connection. If you connect to your Mac (on localhost or 127.0.0.1)
mobiledevice will forward that connection to the device on the specified port
by typing something like:

```
mobiledevice tunnel 8080 80
```

The example above attempts to illustrate a tunnel between your Mac's TCP port 8080
and the device's TCP port 80. The output would be something like:

```
Tunneling from local port 8080 to device port 80...
```

From this point you can "telnet localhost 8080" and communicate with the server
running at TCP port 80 on the mobile app!

Please note that if you keep the process open, it will keep forwarding connections.
If and when you decide to terminate it (for instance, by pressing CTRL-C), it will
terminate all currently tunnelled connections and stop accepting more connections to it.

Also note that mobiledevice allows you to keep multiple connections open to the
same TCP port on the device (by running a single instance of mobiledevice), or to
different ports (by running multiple instances of mobiledevice and specifying the
ports for each). 

## Contribute

Found a bug? Want to contribute and add a new feature?

Please fork this project and send me a pull request!

## License

mobiledevice is licensed under the MIT license:

www.opensource.org/licenses/MIT

