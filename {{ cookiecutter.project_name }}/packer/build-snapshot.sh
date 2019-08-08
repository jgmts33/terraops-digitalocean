#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

packer build -on-error=ask packer.json
