resource "digitalocean_domain" "{{ cookiecutter.domain_plain }}" {
    name = "{{ cookiecutter.domain }}"
}

{% if cookiecutter.gsuite_google_site_verification -%}
# Google site verification
resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_google_verification" {
    domain = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name    = "@"
    type    = "TXT"
    ttl     = "300"
    value = "{{ cookiecutter.gsuite_google_site_verification }}"
}

resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_public_mx_1" {
    domain   = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name     = "@"
    type     = "MX"
    ttl      = "14400"
    priority = "1"
    value    = "aspmx.l.google.com."
}

resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_public_mx_2" {
    domain   = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name     = "@"
    type     = "MX"
    ttl      = "14400"
    priority = "5"
    value    = "alt1.aspmx.l.google.com."
}

resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_public_mx_3" {
    domain   = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name     = "@"
    type     = "MX"
    ttl      = "14400"
    priority = "5"
    value    = "alt2.aspmx.l.google.com."
}

resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_public_mx_4" {
    domain   = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name     = "@"
    type     = "MX"
    ttl      = "14400"
    priority = "10"
    value    = "aspmx2.googlemail.com."
}

resource "digitalocean_record" "{{ cookiecutter.domain_plain }}_public_mx_5" {
    domain   = "${digitalocean_domain.{{ cookiecutter.domain_plain }}.name}"
    name     = "@"
    type     = "MX"
    ttl      = "14400"
    priority = "10"
    value    = "aspmx3.googlemail.com."
}
{% endif -%}
