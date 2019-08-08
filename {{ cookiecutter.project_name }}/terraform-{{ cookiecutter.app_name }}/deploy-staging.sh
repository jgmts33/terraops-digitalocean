#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

terraform workspace select staging
source ../config/environment.sh
terraform apply
