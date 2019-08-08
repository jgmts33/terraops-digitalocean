# {{ cookiecutter.project_name }}
Takes a blank DigitalOcean slate and turns it into a DevOps wonderland.

These instructions assume you're already familiar with what `terraops` does. To learn more about what this creates and deploys, please [give this a read](https://github.com/lsapan/digitalocean-terraops).

## First-time Deployment

#### Prepare the DigitalOcean Account
1) Create a DigitalOcean account
2) Create an API token
3) Update `config/environment.yml` and `config/secrets.yml` with credentials

#### Create the reusable snapshot
1) Verify the `REGION` for Packer in `environment.sh`
2) Run `packer/build-snapshot.sh`
3) Update `TF_VAR_snapshot` in `config/environment.yml` with the created snapshot name

#### Prepare the VPN configuration
All of these commands take place in the `vpn` directory.
1) Delete the `certificates`, `private` and `ansible/roles/vpn/files/openvpn` directories if they already exist
2) Run `create_vpn.sh` to generate the initial configuration
3) Run `add_user.sh` for each user you want to grant access to

#### Create the internal / core infrastructure
1) `cd` into the `terraform-internal` directory
2) Run `./deploy.sh`

##### Note: DNS Update Required!
Be sure to point the domain(s) towards DigitalOcean's nameservers.

##### Deploy staging (optional)
1) Update `config/secrets.yml` as necessary
2) `cd` into the `terraform-{{ cookiecutter.app_name }}` directory
3) Run `terraform workspace new staging`
4) Run `deploy_staging.sh`

##### Deploy prod
1) Update `config/secrets.yml` as necessary
2) `cd` into the `terraform-{{ cookiecutter.app_name }}` directory
3) Run `terraform workspace new prod`
4) Run `deploy_prod.sh`


## Managing the VPN

#### Adding users after initial deployment
All of these commands take place in the `vpn` directory.
1) Run `add_user.sh` for each additional user you want to add
2) Run `update_remote.sh` to sync the changes over.

#### Recreating the VPN
The VPN can easily be recreated if it starts failing or behaving strangely.
From the `terraform-internal` directory:
1) Run `terraform taint digitalocean_droplet.vpn` to mark it for recreation
2) Run `./deploy.sh`


## Managing the Deployment

#### Applying Ansible changes without recreating the deployment
Most of the time, you should update the image and create a new deployment to apply stack changes.
However, if needed, you can apply a playbook manually. You'll need the IPs of the manager nodes:

```
# Prod
ansible-playbook -i x.x.x.x,x.x.x.x,x.x.x.x ansible/swarm.yml --extra-vars 'APP_ENVIRONMENT=PROD APP_IMAGE=prod HOST_URL=mydomain.com' -t swarm_manager

# Staging
ansible-playbook -i x.x.x.x,x.x.x.x,x.x.x.x ansible/swarm.yml --extra-vars 'APP_ENVIRONMENT=STAGING APP_IMAGE=master HOST_URL=staging.mydomain.com' -t swarm_manager
```
