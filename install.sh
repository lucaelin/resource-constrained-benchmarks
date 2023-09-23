#!/usr/bin/env bash

apt install python3-pip uuid bc curl

curl -fsSLo- https://s.id/golang-linux | bash

export GOROOT="$HOME/go"
export GOPATH="$HOME/go/packages"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

cd bench
go build -a -o warmup ./warmup.go
go build -a -o bench ./bench.go
cd ..

pip install matplotlib pandas==1.5.3

docker ps && exit 

echo install docker? 
read -s -n 1 
curl https://get.docker.com | bash 
adduser $USER docker
