# Get the latest and greatest snapshot
data "digitalocean_image" "docker" {
    name = "${var.snapshot}"
}

# Generate a new id each time we switch to a new snapshot id
resource "random_id" "version" {
    keepers = {
        ami_id = "${data.digitalocean_image.docker.id}"
    }

    byte_length = 2
}

# DNS
data "digitalocean_domain" "{{ cookiecutter.domain_plain }}" {
    name = "{{ cookiecutter.domain }}"
}

# VPN Instance
data "digitalocean_tag" "vpn" {
    name = "vpn"
}

# SSL
data "digitalocean_certificate" "{{ cookiecutter.domain_plain }}" {
  name = "{{ cookiecutter.domain }}"
}

# Variables
variable "key_pair" {}
variable "region" {}
variable "snapshot" {}

# Locals
locals {
    name = "${terraform.workspace}"

    app_environment = {
        staging = "STAGING"
        prod    = "PROD"
    }

    app_image = {
        staging = "master"
        prod    = "prod"
    }
}
