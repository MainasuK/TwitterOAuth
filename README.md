## TwitterOAuth
OAuth1.0a server for Twitter.

## Prepare
e.g. Ubuntu 18.04

```bash
# install swift
$ mkdir swift-5.2.5
$ cd swift-5.2.5 
$ wget https://swift.org/builds/swift-5.2.5-release/ubuntu1804/swift-5.2.5-RELEASE/swift-5.2.5-RELEASE-ubuntu18.04.tar.gz
$ tar -xzvf swift-5.2.5-RELEASE-ubuntu18.04.tar.gz

# export PATH. add it to ~/.bash_profile
# export PATH=/home/mainasuk/Developer/swift-5.2.5/swift-5.2.5-RELEASE-ubuntu18.04/usr/bin:"${PATH}"
$ . ~/.profile

# install vapor toolbox
$ git clone https://github.com/vapor/toolbox.git
$ cd toolbox
$ git fetch --all
$ git checkout tags/18.2.2
$ ./scripts/build.swift 
$ sudo mv .build/release/vapor /usr/local/bin
```

## Usage
```bash
# checkout repo
$ git clone https://github.com/MainasuK/TwitterOAuth.git
$ cd TwitterOAuth
$ git pull
$ vapor --version
framework: 4.29.1
toolbox: 18.2.2

$ export CONSUMER_KEY="…"
$ export CONSUMER_SECRET_KEY="…"
$ vapor run serve --port <PORT>
```