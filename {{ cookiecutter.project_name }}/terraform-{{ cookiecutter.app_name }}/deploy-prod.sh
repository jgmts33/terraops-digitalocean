#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

terraform workspace select prod
source ../config/environment.sh
terraform apply
