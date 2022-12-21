data "google_compute_network" "network" {
  name = "tf-vpc-int"
}

data "google_compute_subnetwork" "subnet" {
  name = "sub-priv-int"
}

resource "google_service_account" "gke-sa" {
  account_id   = "gcp-tf-gke-sa"
  display_name = "Service Account for GKE managed by Terraform"
}

resource "google_project_iam_member" "sa_iam" {
  for_each = toset(["roles/compute.networkAdmin", "roles/compute.admin", "roles/container.admin"])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke-sa.email}"

  depends_on = [
    google_service_account.gke-sa
  ]
}

resource "google_container_cluster" "primary" {
  project            = var.project_id
  name               = "gke-int"
  location           = var.region
  remove_default_node_pool = true
  initial_node_count = 1
  network            = data.google_compute_network.network.self_link
  subnetwork         = data.google_compute_subnetwork.subnet.self_link

  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_endpoint = false
    enable_private_nodes    = true
  }
  ip_allocation_policy {
  }
  master_authorized_networks_config {
    # cidr_blocks {
    #   cidr_block= "35.204.231.235/32"
    # }
  }
  depends_on = [
    google_service_account.gke-sa
  ]
}


resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "gke-node-pool-int"
  cluster    = google_container_cluster.primary.id
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}