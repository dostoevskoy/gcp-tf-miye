variable "project_id" {
  description = "Project ID where the resources will be deployed"
  type        = string
}

variable "vpcs" {
  type = map(any)
}

variable "vpc-peerings" {
  type = list(object({
    peering_name = string,
    network      = string,
    peer_network = string
  }))
}

variable "vm_nets" {
  type = list(object({
    env = string,
    subnetwork = string
  }))
}

