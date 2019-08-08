#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Deploy the new images to staging
ssh staging-swarm.{{ cookiecutter.domain }} "docker stack deploy -c /data/stacks/{{ cookiecutter.app_name }} --with-registry-auth {{ cookiecutter.app_name }}"
