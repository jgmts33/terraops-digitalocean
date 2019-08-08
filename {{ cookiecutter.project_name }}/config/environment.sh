# DigitalOcean
export DIGITALOCEAN_API_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Packer
export REGION="{{ cookiecutter.digitalocean_region }}"

# Ansible
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_PIPELINING=True

# Terraform
export DIGITALOCEAN_TOKEN=$DIGITALOCEAN_API_TOKEN
export TF_VAR_key_pair="{{ cookiecutter.your_ssh_username }}"
export TF_VAR_region=$REGION
export TF_VAR_snapshot="docker-xxxxxxxxxx"

# Ensure SSH agent is ready
ssh-add -K ~/.ssh/id_rsa
