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
    iface           = "eth0",
    consul_count    = length(var.lxd-profile),
    consul_server   = "consul01-${var.role}",
    consul_wan_join = var.dc-name == "az1" ? "" : "consul01-primary"
    license         = var.license
  }
}

resource "lxd_container" "consul" {
  for_each  = toset(var.lxd-profile)
  name      = "${format("consul%02d", index(var.lxd-profile, each.value) + 1)}-${var.role}"
  image     = "packer-consul"
  ephemeral = false
  profiles  = [each.value]

  config = {
    "user.user-data" = data.template_file.template.rendered
  }

}

output "hosts" {
  value = local.consul-map
}