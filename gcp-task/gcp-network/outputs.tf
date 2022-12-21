output "vpc_id" {
  value       = google_compute_network.gcp-vpc-network.id
  description = "The ID of the created VPC"
}

output "vpc_selflink" {
  value       = google_compute_network.gcp-vpc-network.self_link
  description = "The self_link of the created VPC"
}
