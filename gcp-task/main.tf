module "gcp-network" {
  source = "./gcp-network"

  project_id = var.project_id
  region     = local.region

  for_each            = var.vpcs
  network_name        = each.value["vpc_name"]
  network_description = each.value["vpc_description"]
  subnets             = each.value["subnets"]
  firewalls           = each.value["firewalls"]
}


data "google_compute_network" "vpc-net" {
  for_each = { for peer in var.vpc-peerings : peer.peering_name => peer }
  name     = each.value["network"]
  depends_on = [
    module.gcp-network
  ]
}

data "google_compute_network" "vpc-peer-net" {
  for_each = { for peer in var.vpc-peerings : peer.peering_name => peer }
  name     = each.value["peer_network"]
  depends_on = [
    module.gcp-network
  ]
}

locals {
  vpc-prepared-peering = flatten([
    for peer in var.vpc-peerings : {
      peering_name = peer["peering_name"]
      network      = data.google_compute_network.vpc-net[peer["peering_name"]].self_link
      peer_network = data.google_compute_network.vpc-peer-net[peer["peering_name"]].self_link
    }
  ])
}

resource "google_compute_network_peering" "vpc-peering" {
  for_each     = { for peer in local.vpc-prepared-peering : peer.peering_name => peer }
  name         = each.value["peering_name"]
  network      = each.value["network"]
  peer_network = each.value["peer_network"]
  depends_on = [
    module.gcp-network
  ]
}

module "gcp-instance" {
  source          = "./gcp-instance"
  project_id      = var.project_id
  region          = local.region
  for_each        = { for vm_net in var.vm_nets : vm_net.env => vm_net }
  name_suffix     = each.value["env"]
  subnetwork_name = each.value["subnetwork"]

  depends_on = [
    module.gcp-network
  ]
}

module "gcp-gke" {
  source     = "./gcp-gke"
  project_id = var.project_id
  region     = local.region
}
