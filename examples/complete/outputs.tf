output "organization_name" {
  description = "Organization name"
  value       = module.swr.organization_name
}

output "organization_login_server" {
  description = "Container registry login URL"
  value       = module.swr.organization_login_server
}

output "repository_details" {
  description = "All repository details"
  value       = module.swr.repository_details
}

output "repository_paths" {
  description = "Repository image paths for docker pull"
  value       = module.swr.repository_paths
}

output "repository_retention_policies" {
  description = "Repository retention policy resource IDs"
  value       = module.swr.repository_retention_policies
}

output "repositories_with_retention" {
  description = "List of repositories that have retention policies configured"
  value = [
    for k, v in module.swr.repository_retention_policies : k
  ]
}
