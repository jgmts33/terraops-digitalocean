#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source ../config/environment.sh
terraform apply
