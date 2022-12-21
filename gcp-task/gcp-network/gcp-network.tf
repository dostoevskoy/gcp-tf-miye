resource "google_compute_network" "gcp-vpc-network" {
  name                    = var.network_name
  description             = var.network_description
  project                 = var.project_id
  auto_create_subnetworks = false
}

module "gcp-subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "6.0.0"

  project_id   = var.project_id
  network_name = var.network_name
  for_each     = var.subnets
  subnets = [
    {
      subnet_name                  = each.value["subnet_name"]
      subnet_ip                    = each.value["subnet_ip"]
      subnet_region                = var.region
      subnet_flow_logs             = each.value["subnet_flow_logs"]
      subnet_flow_logs_interval    = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling    = 0.5
      subnet_flow_logs_metadata    = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_filter_expr = "true"
    }
  ]
  depends_on = [
    google_compute_network.gcp-vpc-network
  ]
}

module "gcp-firewall-rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "6.0.0"
  project_id   = var.project_id
  network_name = var.network_name

  for_each = var.firewalls
  rules = [{
    name                    = each.value["name"]
    description             = "Managed by tf"
    direction               = each.value["direction"]
    priority                = null
    ranges                  = each.value["ranges"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow                   = each.value["allow"]
    deny                    = each.value["deny"]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
  depends_on = [
    google_compute_network.gcp-vpc-network
  ]
}

resource "google_compute_router" "gcp-router" {
  project = var.project_id
  name    = "tf-nat-router-${var.network_name}"
  network = var.network_name
  region  = var.region
  depends_on = [
    module.gcp-subnets
  ]
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.gcp-router.name
  name                               = "tf-nat-config-${var.network_name}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


