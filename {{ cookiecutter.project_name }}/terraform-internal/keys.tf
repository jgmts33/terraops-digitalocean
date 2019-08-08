variable "keys" {
    default = {
        {%- for user, public_key in cookiecutter.users.items() %}
        {{ user }} = "{{ public_key }}"
        {%- endfor %}
    }
}

resource "digitalocean_ssh_key" "keys" {
    name   = "${element(keys(var.keys), count.index)}"
    public_key = "${element(values(var.keys), count.index)}"
    count      = "${length(var.keys)}"
}
