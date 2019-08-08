#######
# Swarm
#######

# Create the tag for the swarm
resource "digitalocean_tag" "swarm" {
    name = "${local.name}-swarm"
}

# Create Droplets for swarm managers
resource "digitalocean_droplet" "managers" {
    image = "${data.digitalocean_image.docker.id}"
    name = "${local.name}-swarm-manager"
    region = "${var.region}"
    size = "s-1vcpu-2gb"
    private_networking = true
    tags = ["${digitalocean_tag.swarm.id}"]

    count = 1

    provisioner "local-exec" {
        command = "../terraform-internal/wait_for_ssh.sh ${var.key_pair}@${self.ipv4_address_private}"
    }

    lifecycle {
        create_before_destroy = true
    }
}

# Create a swarm
resource "null_resource" "swarm" {
    count = 1

    # Re-run whenever swarm_manager_ids change
    triggers = {
        swarm_manager_ids = "${join(",", digitalocean_droplet.managers.*.ipv4_address_private)}"
    }

    provisioner "local-exec" {
        # TODO: Remove the extra comma when adding additional swarm managers
        command = "ansible-playbook -u ${var.key_pair} -i ${join(",", digitalocean_droplet.managers.*.ipv4_address_private)}, --extra-vars 'APP_ENVIRONMENT=${local.app_environment[terraform.workspace]} APP_IMAGE=${local.app_image[terraform.workspace]} HOST_URL=${terraform.workspace == "prod" ? {{ "" if cookiecutter.domain_prod_root else "%s." % cookiecutter['domain_prod'] }} : "${terraform.workspace}."}{{ cookiecutter.domain }}' ../ansible/swarm.yml"
    }
}

# Get the join token for workers
data "external" "swarm_token" {
    depends_on = ["null_resource.swarm"]
    program    = ["./get_swarm_token.sh", "${var.key_pair}@${digitalocean_droplet.managers.0.ipv4_address_private}"]
}

# Create droplets for the swarm workers
resource "digitalocean_droplet" "workers" {
    image = "${data.digitalocean_image.docker.id}"
    name = "${local.name}-swarm-worker"
    region = "${var.region}"
    size = "s-2vcpu-4gb"
    private_networking = true
    tags = ["${digitalocean_tag.swarm.id}"]
    user_data = "#!/bin/bash\nsudo apt-get update\nsudo docker swarm join --token ${lookup(data.external.swarm_token.result, "token")} ${digitalocean_droplet.managers.0.ipv4_address_private}:2377"

    count = 0
}


###############
# Load balancer
###############

# Create load balancer for the app
resource "digitalocean_loadbalancer" "app_lb" {
    name   = "{{ cookiecutter.app_name }}-${local.name}"
    region = "${var.region}"
    # TODO: Was ["${digitalocean_droplet.managers.*.id}"] (for multiple droplets) but it was complaining
    droplet_ids = ["${digitalocean_droplet.managers.0.id}"]
    redirect_http_to_https = true

    forwarding_rule {
        entry_port = 80
        entry_protocol = "http"

        target_port = 8080
        target_protocol = "http"
    }

    forwarding_rule {
        entry_port = 443
        entry_protocol = "https"
        certificate_id = "${data.digitalocean_certificate.{{ cookiecutter.domain_plain }}.id}"

        target_port = 8080
        target_protocol = "http"
    }

    healthcheck {
        port = 8080
        protocol = "http"
        path = "/lbhc"
    }

    lifecycle {
        prevent_destroy = true
    }
}


#####
# DNS
#####

# Create DNS records for the app
{% if cookiecutter.domain_prod_root -%}
resource "digitalocean_record" "app_root" {
  domain = "${data.digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
  name    = "@"
  type    = "A"
  value = "${digitalocean_loadbalancer.app_lb.ip}"
  count = "${terraform.workspace == "prod" ? 1 : 0}"
}
{% endif %}
resource "digitalocean_record" "app" {
  domain = "${data.digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
  name    = "${terraform.workspace == "prod" ? "{{ cookiecutter.domain_prod }}" : "${terraform.workspace}"}"
  type    = "A"
  value = "${digitalocean_loadbalancer.app_lb.ip}"
}

resource "digitalocean_record" "swarm_node" {
  domain = "${data.digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
  name    = "${local.name}-swarm"
  type    = "A"
  {# TODO: Add option to create load balancer exclusively for managers, and use that LB's address here #}
  value = "${digitalocean_droplet.managers.0.ipv4_address_private}"
}


#################
# Security groups
#################

# Set up the Swarm security group
resource "digitalocean_firewall" "swarm" {
    name   = "id-swarm-${local.name}"
    # TODO: Was ["${concat(digitalocean_droplet.managers.*.id, digitalocean_droplet.workers.*.id)}"] (for multiple droplets) but it was complaining
    droplet_ids = ["${digitalocean_droplet.managers.0.id}"]

    inbound_rule {
        source_tags = ["${digitalocean_tag.swarm.id}"]
        protocol = "tcp"
        port_range = "1-65535"
    }

    inbound_rule {
        source_tags = ["${digitalocean_tag.swarm.id}"]
        protocol = "udp"
        port_range = "1-65535"
    }

    inbound_rule {
        source_tags = ["${digitalocean_tag.swarm.id}"]
        protocol = "icmp"
    }

    inbound_rule {
        source_tags = ["${data.digitalocean_tag.vpn.id}"]
        source_load_balancer_uids = ["${digitalocean_loadbalancer.app_lb.id}"]
        protocol = "tcp"
        port_range = "8000-9000"
    }

    inbound_rule {
        source_tags = ["${data.digitalocean_tag.vpn.id}"]
        protocol = "tcp"
        port_range = "22"
    }

    outbound_rule {
        destination_addresses = ["0.0.0.0/0"]
        protocol = "tcp"
        port_range = "1-65535"
    }

    outbound_rule {
        destination_addresses = ["0.0.0.0/0"]
        protocol = "udp"
        port_range = "1-65535"
    }
}
