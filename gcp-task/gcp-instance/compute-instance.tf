data "google_compute_subnetwork" "subnet" {
  name = var.subnetwork_name
}

output "subnet" {
  value = data.google_compute_subnetwork.subnet.self_link

}

module "instance_template" {
  source          = "terraform-google-modules/vm/google//modules/instance_template"
  version         = "7.9.0"
  region          = var.region
  project_id      = var.project_id
  subnetwork      = data.google_compute_subnetwork.subnet.self_link
  machine_type    = "e2-micro"
  service_account = null
}

module "compute_instance" {
  source              = "terraform-google-modules/vm/google//modules/compute_instance"
  version             = "7.9.0"
  region              = var.region
  subnetwork          = data.google_compute_subnetwork.subnet.self_link
  num_instances       = 1
  hostname            = "stepsone-${var.name_suffix}"
  instance_template   = module.instance_template.self_link
  deletion_protection = false

}
