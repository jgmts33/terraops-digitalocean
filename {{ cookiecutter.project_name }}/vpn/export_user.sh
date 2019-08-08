#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Get the client name
CLIENTNAME="$1"

# Export the certificate
mkdir -p certificates
docker run -v "$PWD/private:/etc/openvpn" --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > certificates/$CLIENTNAME.ovpn

# Create (or recreate) a two factor authentication token
otp_secret_line=$(docker run -v "$PWD/private:/etc/openvpn" --rm -it kylemanna/openvpn bash -c "echo -1 | ovpn_otp_user $CLIENTNAME" | grep "secret key")
otp_secret="${otp_secret_line:24:26}"
qr_link="otpauth://totp/VPN?secret=$otp_secret&issuer={{ cookiecutter.app_name }}"
docker run -v "$PWD/certificates:/qr" -e QR_TEXT="$qr_link" -e QR_FILE=$CLIENTNAME.png --rm valien/docker-qr-generator

cp -Rf private/otp ../ansible/roles/vpn/files/openvpn

echo "Generated client certificate and QR code for $1."
