[mobiledeviceプロジェクトページへ](https://github.com/imkira/mobiledevice)

mobiledevice
============

mobiledeviceはAppleのMobile Deviceフレームワークと相互に使用するコマンドラインツールである。
XcodeやiTunesに頼らず、コマンドラインからアプリをインストールしたりアンインストールしたりするのが出来るのでそのような作業は自動化可能となる。
普通のjailbroken端末ではなくても大丈夫！

## 本ツールを使うための必要な環境など

* iPhone 3G以降の端末 or iPad（iPhone 4で確認した）。
* iPhone or iPadをUSBでMacに接続する。
* アプリをインストールするには、あらかじめにiOS開発証明書を端末にインストールする。
* Mac OS X 10.6以降（Snow Leopardで動作確認したが、Lionでも大丈夫だと思う）。
* XCode 3 or 4 と iOS SDKをインストールする。
* 本ツールをコインパイルする（任意だがインストールも可能）。

## コンパイルとインストールについて

mobiledeviceをコンパイルするには、ターミナルを開いて下記コマンドを記入する：

```
git clone git://github.com/imkira/mobiledevice.git
cd mobiledevice
make
#  /usr/local/binの下にインストールするには下記コマンドも入力する：
make install
```

## 使い方

コンパイルとインストール（任意）した後に、ターミナルを開く。

オプション無しで下記のようにmobiledeviceを実行すると、

```
mobiledevice
```

下記の通り、基本使い方の説明画面を確認できる（下記は日本語に翻訳したもの）。

```
Usage: mobiledevice <command> [<options>]

<Commands>
  get_udid                            : 接続中の端末のUDIDを取得する。
  get_bundle_id <appへのパス>         : .appフォルダーを指定してbundle identifierを取得する。
  install_app <appへのパス>           : .appフォルダーを指定して接続中の端末にアプリをインストールする。
  uninstall_app <bundle_id>           : bundle identifierを指定して接続中の端末からアプリをアンインストールする。
  list_installed_apps [-p]            : 接続中の端末にインストールされているアプリの一覧を取得する。
  tunnel <何ポートから> <何ポートへ>  : ローカルポートから接続中の端末のポートへのTCPトンネルを設立する。


<Options>
  -p : list_installed_appsで使うとインストールのパスも出力する。
```

上記コマンドの実行に失敗した場合、そのプロセスが「0」というstatus以外の値で必ず終了する。
また、発生したエラー次第stderrにその内容が出力される（されないこともある）。

実行に成功した場合、そのプロセスが「0」というstatusの値で必ず終了する。
list_installed_appsコマンド以外、その結果が必ずstdoutに出力される（例えば、「OK」というメッセージ）。

## 使用例

### 接続中の端末のUDIDを取得する

本コマンドは、UIAutomator instrumentsの「-w」オプションのように他ツールに渡すには便利：

```
mobiledevice get_udid
```

### .appフォルダーを指定してbundle identifierを取得する

本コマンドは、Mobile Deviceフレームワークとは関係ないが便利なコマンドとして提供されている。
指定した.appフォルダーから、そのアプリのbundle identifier（例：com.mycompany.myapp）を
取得するには、下記コマンドをする（注意：.ipaフォルダーは不可能）。

```
mobiledevice get_bundle_id folder1/folder2/example.app
```

注意点：

* パスは、端末上のパスでなくローカルのパソコン上のパスを指定する。

### .appフォルダーを指定して接続中の端末にアプリをインストールする

iTunes/Xcodeみたいに、アプリを接続中の端末にアプリをインストールするには下記コマンドをする。

```
mobiledevice install_app folder1/folder2/example.app
```

### bundle identifierを指定して接続中の端末からアプリをアンインストールする

接続中の端末から、アプリをアンインストールするには下記のようにそのアプリのbundle identifierを指定して
下記コマンドをする。

```
mobiledevice uninstall_app com.company.example
```

### 接続中の端末にインストールされているアプリの一覧を取得する

端末にインストールされているアプリの一覧を出力するには、下記コマンドをする。

```
mobiledevice list_installed_apps
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

```-p``` を指定すると、Bundle
IDだけでなく端末上にインストールされているアプリのインストールのパスも含めて出力する。

内容は下記のようなものである。

```
com.apple.VoiceMemos  /Applications/VoiceMemos.app
com.apple.mobiletimer /Applications/MobileTimer.app
...
com.mycompany.myapp1  /private/var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/YYYY.app
com.mycompany.myapp2  /private/var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/ZZZZ.app
...
```

注意点：

* Bundle IDとインストールのパスはTAB区切りである。

### Macのローカルポートから接続中の端末のポートへのTCPトンネルを成立する

もしも何らかの理由で作ったアプリが特定のTCPポートでTCPサーバーを立っているのであれば、
WiFi/3Gがなくても本コマンドを使ってUSB経由でMacから接続可能にする。
mobiledeviceがUSB経由でMacと接続中の端末間にトンネルを成立することで、
Mac（localhost or 127.0.0.1）の指定したTCPポートに（telnetなどで）接続すれば、
端末の指定したポートに接続出来る。

```
mobiledevice tunnel 8080 80
```

上記の例では、MacのTCPポート8080と接続中の端末のTCPポート80間のトンネルを成立する。
そのコマンドの出力内容は以下のようなものとなる。

```
Tunneling from local port 8080 to device port 80...
```

上記メッセージが出たら、Macから`telnet localhost 8080`などで
接続中の端末のTCPポート80に接続出来るようになる！

注意点：

* CTRL-Cでトンネルとともにプロセスを簡単に終了させるには、トンネル使用中にプロセスが
バックグランドで実行しないこと。
* トンネル使用中にプロセスを（CTRL-Cなどで）終了させると、接続中の接続が中断される。
* 一つのトンネルでも同時に複数の接続を行うことが可能となっている。ただし、
同じローカルポートを指定して２つ以上のトンネルは不可。

## 「貢献したい！」

「不具合を発見！」、「こんな凄い機能を作っちゃったのでmobiledeviceに追加したいけど...」といった
時にmobiledeviceプロジェクトをforkしpull requestをお願いします！

## ライセンス

mobiledeviceはMIT Licenseに準拠する：

www.opensource.org/licenses/MIT

