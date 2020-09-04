## TwitterOAuth
OAuth1.0a server for Twitter.

## Prepare
e.g. Ubuntu 18.04


### Setup Environment
Swift [release](https://swift.org/download/#releases)
</br>
Vapor Toolbox [release](https://github.com/vapor/toolbox/releases)

```bash
# install Swift
sudo apt-get install \
    binutils \
    git \
    libc6-dev \
    libcurl4 \
    libedit2 \
    libgcc-5-dev \
    libpython2.7 \
    libsqlite3-0 \
    libstdc++-5-dev \
    libxml2 \
    pkg-config \
    tzdata \
    zlib1g-dev
    
mkdir -p ~/Developer/Swift         
cd ~/Developer/Swift
curl https://swift.org/builds/swift-5.2.5-release/ubuntu1804/swift-5.2.5-RELEASE/swift-5.2.5-RELEASE-ubuntu18.04.tar.gz -O
tar -xzvf swift-5.2.5-RELEASE-ubuntu18.04.tar.gz

echo 'export PATH=~/Developer/Swift/swift-5.2.5-RELEASE-ubuntu18.04/usr/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
echo $PATH
> /home/vapor/Developer/Swift/swift-5.2.5-RELEASE-ubuntu18.04/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

# install vapor toolbox
mkdir -p ~/Developer/Vapor
cd ~/Developer/Vapor
git clone https://github.com/vapor/toolbox.git
cd toolbox
git fetch --all
git checkout 18.2.2
./scripts/build.swift 
sudo mv .build/release/vapor /usr/local/bin
```

## Bootstrap
```bash
# checkout repo
cd ~/Developer/Vapor
git clone https://github.com/MainasuK/TwitterOAuth.git
cd TwitterOAuth
git pull

vapor --version
> framework: 4.29.1
> toolbox: 18.2.2 

# export enviorment variable and run it
## Method 1:
sudo apt-get install tmux
tmux new -s vapor
export CONSUMER_KEY="…"
export CONSUMER_SECRET_KEY="…"
vapor run serve --port <PORT>

## Method 2:
```