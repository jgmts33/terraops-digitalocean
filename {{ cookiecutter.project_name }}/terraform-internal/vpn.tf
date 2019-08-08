# Create the Floating IP for the VPN
resource "digitalocean_floating_ip" "vpn" {
    region = "${var.region}"
}

# Create the tag for the VPN
resource "digitalocean_tag" "vpn" {
    name = "vpn"
}

# Create VPN Droplet
resource "digitalocean_droplet" "vpn" {
    image = "${data.digitalocean_image.docker.id}"
    name = "vpn"
    region = "${var.region}"
    size = "s-1vcpu-1gb"
    private_networking = true
    tags = ["${digitalocean_tag.vpn.id}"]
}

resource "digitalocean_floating_ip_assignment" "vpn_fip" {
    ip_address   = "${digitalocean_floating_ip.vpn.ip_address}"
    droplet_id = "${digitalocean_droplet.vpn.id}"

    provisioner "local-exec" {
        command = "./wait_for_ssh.sh ${var.key_pair}@${digitalocean_floating_ip.vpn.ip_address} && ansible-playbook -u ${var.key_pair} -i ${digitalocean_floating_ip.vpn.ip_address}, ../ansible/vpn.yml"
    }
}

# Create DNS records for the VPN
resource "digitalocean_record" "vpn" {
  domain = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
  name    = "{{ cookiecutter.domain_vpn }}"
  type    = "A"
  value = "${digitalocean_floating_ip.vpn.ip_address}"
}

# Set up the VPN security group
resource "digitalocean_firewall" "vpn" {
    name   = "id-vpn"
    droplet_ids = ["${digitalocean_droplet.vpn.id}"]

    inbound_rule {
        source_addresses = ["0.0.0.0/0"]
        protocol = "tcp"
        port_range = "80"
    }

    inbound_rule {
        source_addresses = ["0.0.0.0/0"]
        protocol = "tcp"
        port_range = "443"
    }

    inbound_rule {
        source_addresses = ["0.0.0.0/0"]
        protocol = "udp"
        port_range = "1194"
    }

    inbound_rule {
        source_addresses = ["${chomp(data.http.current_ip.body)}/32"]
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
