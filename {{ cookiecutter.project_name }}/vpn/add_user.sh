#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

docker run -v "$PWD/private:/etc/openvpn" --net=none --rm -it kylemanna/openvpn easyrsa build-client-full $1 nopass
./export_user.sh $1
