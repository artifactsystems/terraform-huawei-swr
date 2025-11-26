output "organization_id" {
  description = "ID of the organization"
  value       = try(huaweicloud_swr_organization.this[0].id, null)
}

output "organization_name" {
  description = "Name of the organization"
  value       = local.organization_name
}

output "organization_creator" {
  description = "The creator user name of the organization"
  value       = try(huaweicloud_swr_organization.this[0].creator, null)
}

output "organization_permission" {
  description = "The permission of the organization (Manage, Write, Read)"
  value       = try(huaweicloud_swr_organization.this[0].permission, null)
}

output "organization_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = try(huaweicloud_swr_organization.this[0].login_server, null)
}

################################################################################
# Repository Outputs
################################################################################

output "repository_ids" {
  description = "Map of repository IDs (repository names)"
  value = {
    for k, v in huaweicloud_swr_repository.this : k => v.id
  }
}

output "repository_details" {
  description = "Map of repository details"
  value = {
    for k, v in huaweicloud_swr_repository.this : k => {
      id            = v.id
      repository_id = v.repository_id
      path          = v.path
      internal_path = v.internal_path
      num_images    = v.num_images
      size          = v.size
    }
  }
}

output "repository_paths" {
  description = "Map of repository image paths for docker pull"
  value = {
    for k, v in huaweicloud_swr_repository.this : k => v.path
  }
}

output "repository_internal_paths" {
  description = "Map of repository internal paths for intra-cluster docker pull"
  value = {
    for k, v in huaweicloud_swr_repository.this : k => v.internal_path
  }
}

################################################################################
# Image Retention Policy Outputs
################################################################################

output "repository_retention_policies" {
  description = "Map of repository retention policy resource IDs"
  value = {
    for k, v in huaweicloud_swr_image_retention_policy.this : k => v.id
  }
}
