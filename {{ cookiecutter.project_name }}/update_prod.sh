#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Promote the master images to prod
docker pull {{ cookiecutter.app_image_django }}:master
docker pull {{ cookiecutter.app_image_nginx }}:master
docker tag {{ cookiecutter.app_image_django }}:master {{ cookiecutter.app_image_django }}:prod
docker tag {{ cookiecutter.app_image_nginx }}:master {{ cookiecutter.app_image_nginx }}:prod
docker push {{ cookiecutter.app_image_django }}:prod
docker push {{ cookiecutter.app_image_nginx }}:prod

# Deploy the new images to prod
ssh prod-swarm.{{ cookiecutter.domain }} "docker stack deploy -c /data/stacks/{{ cookiecutter.app_name }} --with-registry-auth {{ cookiecutter.app_name }}"
