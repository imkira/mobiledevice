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
  get_udid                    : Display UDID of connected device
  get_bundle_id <path_to_app> : Display bundle identifier of app (.app folder)
  install_app <path_to_app>   : Install app (.app folder) to device
  uninstall <bundle_id>       : Uninstall app by bundle id
  list_installed_apps         : Lists all installed apps on device
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

## Contribute

Found a bug? Want to contribute and add a new feature?

Please fork this project and send me a pull request!

## License

mobiledevice is licensed under the MIT license:

www.opensource.org/licenses/MIT

