locals {
  consul-map = zipmap([for v in lxd_container.consul : v.id], [for v in lxd_container.consul : v.ipv4_address])
}

terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.5.0"
    }
  }
}

data "http" "template" {
  url = var.template
}

data "template_file" "template" {
  template = data.http.template.body
  vars = {
    dc              = var.dc-name,
    iface           = var.iface,
    consul_count    = length(var.lxd-profile),
    consul_server   = "consul01-${var.role}",
    consul_wan_join = var.role == "primary" ? "" : "consul01-primary"
    license         = var.license
  }
}

resource "lxd_container" "consul" {
  count     = length(var.lxd-profile)
  name      = "${format("%s%02d", var.prefix, count.index + 1)}-${var.role}"
  image     = var.image
  ephemeral = false
  profiles  = [ var.lxd-profile[count.index] ]

  config = {
    "user.user-data" = data.template_file.template.rendered
  }

}

output "hosts" {
  value = local.consul-map
}
