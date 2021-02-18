variable "dc-num" {
  default = 0
}

variable "dc-name" {
  default = "az1"
}

variable "role" {
  type    = string
  default = "primary"
}

variable "lxd-profile" {
  type    = list(any)
  default = ["default"]
}

variable "license" {
  type    = string
  default = ""
}

variable "template" {}
