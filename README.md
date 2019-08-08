# digitalocean-terraops

This template sets up everything you need for a new DigitalOcean deployment. It is built with security in mind, and allows you to easily provision your account with all the essentials. Plus, since it's built on Terraform and Ansible, it's very easy to extend and customize it to suit your needs.

### What does it create?

A lot! Here are the highlights:

- An OpenVPN server for securely connecting to your servers and infrastructure.
- A Docker Swarm cluster (with any number of managers / workers) to deploy your apps.
- Configuration files to quickly and automatically deploy apps to the swarm.
- A GitLab runner that can be used with GitLab's excellent CI/CD functionality.
- Automatic domain management, LetsEncrypt certificate creation, etc.

### What are the benefits?

##### Highly-available and self-healing app deployments with Docker Swarm

Docker Swarm is an excellent container orchestrator, and this project allows you to easily take advantage of its many features. From the get go, this will set up a highly available cluster that sits behind a load balancer. If some of your managers or workers go down, your cluster will continue functioning while ensuring that all of your containers are still being run.

##### VPN security

Leaving SSH access open on servers is a risk, but managing IP lists is tedious and not always reliable. A VPN allows you to connect to servers over the private network, while also only allowing SSH traffic from the VPN. This is also great for databases and other applications with ports that should not be publicly accessible.

##### Automatic secret management

Storing secrets in environment variables is a thing of the past! This template makes heavy use of Docker Swarm's secret functionality to securely define secrets and make them available exclusively to the containers that need them. New secrets are automatically added to the Swarm upon re-deploying too!

The template also automatically lets you distinguish between environment-specific secrets, and global secrets (ones that are the same for both staging and prod).

##### Batteries Included

The included Ansible files set up and secure your Droplets in a standard way, while Packer creates an image that can be used to spin up new Droplets without the need for futher provisioning. Everything is very much "batteries included", and these configurations can absolutely be used without any customization or tweaks.

##### First-class support for Django, Celery, Redis, RabbitMQ and Nginx

While entirely optional, if you happen to be deploying a Django app, there's a pre-configured Docker Swarm stack just for you! It comes with built-in support for Django + Gunicorn, Celery (and celerybeat) for tasks, Redis as a cache (or task queue), RabbitMQ as a message broker, and Nginx as a reverse-proxy in front of Gunicorn. The template automatically ensures there's the correct number of processes running on each node in your swarm.

Of course, you don't need to be using any of these in your stack! You'll simply need to define your stack in one file in order to deploy literally any app.

### Awesome! How do I use it?

This is a [cookiecutter](https://github.com/cookiecutter/cookiecutter) template. As such, you can just run:

```bash
cookiecutter gh:lsapan/digitalocean-terraops
```

That said, there are some advanced settings that you may want to configure in your `cookiecutter.json` file that can't be set from the command line. If you want to do that:

1. Clone this repository
2. Edit the `cookiecutter.json` file to suit your needs (options are explained below)
3. Run `cookiecutter digitalocean-terraops`

##### What do I do after I use cookiecutter?

The generated folder will have its own README file in it that walks you through the steps to get everything deployed! (Spoiler alert, it's _really, really_ easy.)

##### Dependencies?

Here are the versions of Terraform, Ansible and Packer that I've tested with (it probably works with earlier/later versions too though):

- Terraform 0.12.5

- Ansible 2.8.3

- Packer 1.4.1

### Options

| **Parameter**                     | **Required** | **Explanation**                                              |
| --------------------------------- | ------------ | ------------------------------------------------------------ |
| `project_name`                    | Yes          | The name of the folder for the generated project.            |
| `registry_url`                    | No           | If you have a private Docker Registry, you can provide its URL to trigger automatic login during provisioning. Of course, be sure to add credentials for it to `config/secrets.yml` after generating. |
| `users`                           | Yes          | Dictionary of usernames to public keys that should be granted access to deployed servers. |
| `app_name`                        | Yes          | The name of the app that you are deploying.                  |
| `app_secrets`                     | Yes          | A dictionary of the secrets that are used by your app. The value is a boolean specifying whether the secret is environment specific. When set to `true`, the generated `secrets.yml` file will have two declarations for the secret (one for staging, and one for prod). |
| `app_uses_django`                 | No           | Creates service declarations for `django`, `celery`, and `celerybeat`. |
| `app_uses_rabbitmq`               | No           | Creates a service for `rabbitmq`.                            |
| `app_uses_redis`                  | No           | Creates a service for `redis`.                               |
| `app_uses_nginx`                  | No           | Creates a service for `nginx`.                               |
| `app_image_django`                | No           | The image to use for app containers (`django`, `celery` and `celerybeat`). |
| `app_image_nginx`                 | No           | The image to use for `nginx` containers.                     |
| `digitalocean_region`             | Yes          | The region in DigitalOcean to create resources in.           |
| `domain`                          | Yes          | The primary domain you're working with. Be sure only to specify the root domain here (don't include www, etc). |
| `domain_plain`                    | Yes          | The name of the domain (can't include periods).              |
| `domain_prod`                     | Yes          | The subdomain to deploy prod to (i.e. `www`)                 |
| `domain_staging`                  | Yes          | The subdomain to deploy staging to (i.e. `staging`).         |
| `domain_prod_root`                | Yes          | Whether or not prod should be deployed to the root of the domain (in addition to `domain_prod`). For example, this allows you to deploy the app to both `mysite.com` and `www.mysite.com`. |
| `domain_vpn`                      | Yes          | The subdomain to deploy the VPN to.                          |
| `gsuite_google_site_verification` | No           | If you're using GSuite, you can specify your full site verification token in order to automatically create GSuite MX records for your domain. |
| `create_gitlab_runner`            | No           | For those of you using GitLab CI/CD.                         |
| `your_ssh_username`               | Yes          | This is the username that will be used to SSH into servers from your computer. |

### What about multiple apps?

The template only creates a terraform directory for one app, but you can very add additional stacks by duplicating files, or running `cookiecutter` with different app settings. You can use as many apps as you want!

Taking it further, you can also have multiple Docker Swarm clusters. Just run `cookiecutter` with different settings and take the generated `terraform-(appname)` folder.

### FAQ

##### Has this been used in production?

Absolutely. I've been using it in production with multiple apps for years.

##### DigitalOcean is awesome, but what about AWS or (other provider)?

I have a version of terraops for AWS as well, I just haven't created a cookiecutter template for it yet. That one supports even more functionality (multiple VPCs, Network ACLs, auto-scaling Docker Swarm nodes, etc). If this is something you need, let me know and I'll try to get around to porting that one to cookiecutter.
