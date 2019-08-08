resource "digitalocean_certificate" "{{ cookiecutter.domain_plain }}" {
  name    = "{{ cookiecutter.domain }}"
  type    = "lets_encrypt"
  domains = ["{{ cookiecutter.domain }}", "{{ cookiecutter.domain_prod }}.{{ cookiecutter.domain }}", "{{ cookiecutter.domain_staging }}.{{ cookiecutter.domain }}"]
}
