#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

docker run -v "$PWD/private:/etc/openvpn" --net=none --rm -it kylemanna/openvpn ovpn_genconfig -u udp://{{ cookiecutter.domain_vpn }}.{{ cookiecutter.domain }} -2 -C AES-256-GCM
docker run -v "$PWD/private:/etc/openvpn" --net=none --rm -it kylemanna/openvpn ovpn_initpki

docker run -v "$PWD/private:/etc/openvpn" --net=none --rm -it kylemanna/openvpn ovpn_copy_server_files
mkdir -p ../ansible/roles/vpn/files/
mv ./private/server ../ansible/roles/vpn/files/openvpn
