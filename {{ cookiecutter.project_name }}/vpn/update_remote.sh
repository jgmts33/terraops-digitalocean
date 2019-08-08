#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

ansible-playbook -i {{ cookiecutter.domain_vpn }}.{{ cookiecutter.domain }}, ../ansible/vpn.yml -t vpn
