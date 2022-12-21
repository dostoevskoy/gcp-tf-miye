output "sa_email" {
  value       = google_service_account.sa.email
  description = "The e-mail address of the service account."
}

output "sa_name" {
  value       = google_service_account.sa.name
  description = "The full name of the service account."
}

output "sa_unique_id" {
  value       = google_service_account.sa.unique_id
  description = "The unique id of the service account."
}

output "project_id" {
  value       = replace(google_project.tf-project.id, "projects/", "")
  description = "The id of the project that has been created."
}
