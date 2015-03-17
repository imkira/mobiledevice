[mobiledeviceプロジェクトページへ](https://github.com/imkira/mobiledevice)

mobiledevice
============

[![Build Status](https://travis-ci.org/imkira/mobiledevice.png)](https://travis-ci.org/imkira/mobiledevice)

mobiledeviceはAppleのMobile Deviceフレームワークと相互に使用するコマンドラインツールである。
XcodeやiTunesに頼らず、コマンドラインからアプリをインストールしたりアンインストールしたりするのが出来るのでそのような作業は自動化可能となる。
普通のjailbroken端末ではなくても大丈夫！

## 必要なもの

* iPhone 3G以降の端末 or iPad（iPhone 4, 5, 6で確認した）。
* iPhone or iPadをUSBでMacに接続する。
* アプリをインストールするには、あらかじめにiOS開発証明書を端末にインストールする。
* Mac OS X 10.6以降。
* XCode 3以降 と iOS SDKをインストールする。
* 本ツールをコインパイルする（任意だがインストールも可能）。

### インストール

### Homebrew

[homebrew](http://brew.sh)
を使用する場合、ターミナルを開いて下記コマンドを実行する：

```shell
brew update
brew install mobiledevice
```

### 手動

mobiledeviceをコンパイルするには、ターミナルを開いて下記コマンドを実行する：

```shell
git clone git://github.com/imkira/mobiledevice.git
cd mobiledevice
make
```

インストールするには下記コマンドも入力する：

```shell
make install
```

## 使い方

### ヘルプ

コンパイルとインストール（任意）した後に、ターミナルを開く。

下記のようにmobiledeviceを実行すると、

```shell
mobiledevice help
```

下記の通り、基本使い方の説明画面を確認できる(英語のみ)。

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

上記コマンドの実行に失敗した場合、そのプロセスが「0」というstatus以外の値で必ず終了する。
また、発生したエラー次第stderrにその内容が出力されることがある。

実行に成功した場合、そのプロセスが「0」というstatusの値で必ず終了する。

### 端末一覧を取得する

接続中の端末の一覧を出力するには、下記のように実行する。

```
mobiledevice list_devices
```

内容は下記のようなものである。

```
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
7c211433f02071597741e6ff5a8ea34789abbf43
0ab8318acaf6e678dd02e2b5c343ed41111b393d
```

上記一覧では、端末が３つ接続されていることが分かる。
一覧を何件まで制限するには、```-n <count>```フラグを使って下記のように実行する。

```
mobiledevice list_devices -n 1
```

内容は下記のようなものである。

```
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
```

### 端末のプロパティ名一覧を取得する

端末のプロパティ名一覧を出力するには、下記のように実行する。

```
mobiledevice list_device_props
```

内容は下記のようなものである。

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

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice list_device_props -u 7c211433f02071597741e6ff5a8ea34789abbf43
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。

### 端末のプロパティの値を取得する

端末のプロパティの値を出力するには、下記のように実行する。

```
mobiledevice get_device_prop property_name
```

例えば、端末の製品タイプを取得するには、下記のように```ProductType```というプロパティ名を指定して実行する。

```
mobiledevice get_device_prop ProductType
```

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice get_device_prop -u 7c211433f02071597741e6ff5a8ea34789abbf43
property_name
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。
* 実行成功の場合、出力内容が改行文字を足して出力される。

### アプリ一覧を取得する

端末にインストールされているアプリの一覧を出力するには、下記コマンドを実行する。

```
mobiledevice list_apps
```

内容は下記のようなものである。

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

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice list_apps -u 7c211433f02071597741e6ff5a8ea34789abbf43
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。

### アプリのプロパティ名一覧を取得する

端末にインストールされているアプリのプロパティ名一覧を出力するには、アプリのbundle identifierを指定して下記のように実行する。

```
mobiledevice list_app_props com.mycompany.myapp
```

内容は下記のようなものである。

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

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice list_app_props -u 7c211433f02071597741e6ff5a8ea34789abbf43
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。

### アプリのプロパティの値を取得する

端末にインストールされているアプリのプロパティの値を出力するには、アプリのbundle identifierとプロパティ名を指定して下記のように実行する。

```
mobiledevice get_app_prop com.mycompany.myapp property_name
```

例えば、Appleの「天気」アプリがインストールされている端末上のパスを取得するには、下記のように```Path```というプロパティ名を指定して実行する。

```
mobiledevice get_app_prop com.apple.weather Path
```

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice get_app_prop -u 7c211433f02071597741e6ff5a8ea34789abbf43 com.mycompany.myapp Path
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。
* 実行成功の場合、出力内容が改行文字を足して出力される。

### アプリをインストールする

端末にアプリをインストールするには下記コマンドを実行する。

```
mobiledevice install_app path/to/my_application.app
```

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice install_app -u 7c211433f02071597741e6ff5a8ea34789abbf43 path/to/my_application.app
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。

### アプリをアンインストールする

端末から、アプリをアンインストールするには下記のようにそのアプリのbundle identifierを指定して下記コマンドを実行する。

```
mobiledevice uninstall_app com.mycompany.myapp
```

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice uninstall_app -u 7c211433f02071597741e6ff5a8ea34789abbf43 com.mycompany.myapp
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。

### Macのローカルポートから端末のポートへのTCPトンネルを成立する

もしも何らかの理由で作ったアプリが特定のTCPポートでTCPサーバーを立っているのであれば、
WiFi/3Gがなくても本コマンドを使ってUSB経由でMacから接続可能にする。
mobiledeviceがUSB経由でMacと端末間にトンネルを成立することで、
Mac（localhost or 127.0.0.1）の指定したTCPポートに（telnetなどで）接続すれば、
端末の指定したポートに接続出来る。

```
mobiledevice tunnel 8080 80
```

上記の例では、MacのTCPポート8080と端末のTCPポート80間のトンネルを成立する。
そのコマンドの出力内容は以下のようなものとなる。

```
Tunneling from local port 8080 to device port 80...
```

上記メッセージが出たら、Macから`telnet localhost 8080`などで
端末のTCPポート80に接続出来るようになる！

端末を特定するには、```-u <udid>```フラグを足してコマンドを下記のように実行する。

```
mobiledevice tunnel -u 7c211433f02071597741e6ff5a8ea34789abbf43 8080 80
```

注意点：

* ```-u <udid>```フラグを指定しない場合、最初に検知された端末が使用される。
* CTRL-Cでトンネルとともにプロセスを簡単に終了させるには、トンネル使用中にプロセスが
バックグランドで実行しないこと。
* トンネル使用中にプロセスを（CTRL-Cなどで）終了させると、接続が中断される。
* 一つのトンネルでも同時に複数の接続を行うことが可能となっている。ただし、
同じローカルポートを指定して２つ以上のトンネルは不可。

### .appフォルダーを指定してbundle identifierを取得する

本コマンドは、Mobile Deviceフレームワークとは関係ないが便利なコマンドとして提供されている。
指定した.appフォルダーから、そのアプリのbundle identifier（例：com.mycompany.myapp）を
取得するには、下記コマンドを実行する（注意：.ipaフォルダーは不可能）。

```
mobiledevice get_bundle_id folder1/folder2/example.app
```

注意点：

* パスは、端末上のパスでなくローカルのパソコン上のパスを指定する。

## 「貢献したい！」

「不具合を発見！」、「こんな凄い機能を作っちゃったのでmobiledeviceに追加したいけど...」といった
時にmobiledeviceプロジェクトをforkしpull requestをお願いします！

### 貢献してくれた方々

[一覧](https://github.com/imkira/mobiledevice/graphs/contributors).

## ライセンス

mobiledeviceはMIT Licenseに準拠する：

www.opensource.org/licenses/MIT
