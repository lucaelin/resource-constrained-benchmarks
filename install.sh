#!/usr/bin/env bash

sudo apt update
sudo apt install -y python3-pip uuid bc curl unzip

curl -fsSL https://deno.land/install.sh | sh

curl -fsSLo- https://s.id/golang-linux | bash

export GOROOT="$HOME/go"
export GOPATH="$HOME/go/packages"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

cd bench
go build -a -o warmup ./warmup.go
go build -a -o bench ./bench.go
cd ..

pip3 install --break-system-packages matplotlib pandas==1.5.3

docker ps && exit 

echo install docker? 
read -s -n 1 
curl https://get.docker.com | bash 
sudo adduser $USER docker
