variable "project_id" {
  description = "Project ID where the resources will be deployed"
  type        = string
}

variable "region" {
  type = string

}

variable "network_name" {
  type = string
}

variable "network_description" {
  type = string
}

variable "subnets" {
  type    = map(any)
  default = null
}

variable "firewalls" {
  type    = map(any)
  default = null
}
