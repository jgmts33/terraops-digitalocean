# Get the latest and greatest snapshot
data "digitalocean_image" "docker" {
    name = "${var.snapshot}"
}

# Get the current IP
data "http" "current_ip" {
   url = "http://icanhazip.com"
}

variable "key_pair" {}
variable "region" {}
variable "snapshot" {}
