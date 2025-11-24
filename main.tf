locals {
  create_organization = var.create_organization && var.organization_name != null
  organization_name   = local.create_organization ? huaweicloud_swr_organization.this[0].name : var.organization_name

  repositories_map = { for repo in var.repositories : repo.name => repo }
}

################################################################################
# SWR Organization
################################################################################

resource "huaweicloud_swr_organization" "this" {
  count = local.create_organization ? 1 : 0

  name   = var.organization_name
  region = var.region

  timeouts {
    create = var.organization_timeouts.create
    delete = var.organization_timeouts.delete
  }
}

################################################################################
# SWR Repositories
################################################################################

resource "huaweicloud_swr_repository" "this" {
  for_each = { for repo in var.repositories : repo.name => repo }

  organization = local.organization_name
  name         = each.value.name
  region       = var.region

  is_public   = try(each.value.is_public, false)
  description = try(each.value.description, null)
  category    = try(each.value.category, null)
}

################################################################################
# SWR Image Retention Policy
################################################################################

resource "huaweicloud_swr_image_retention_policy" "this" {
  for_each = {
    for k, v in huaweicloud_swr_repository.this : k => v
    if try(local.repositories_map[k].retention_policy, null) != null
  }

  organization = local.organization_name
  repository   = each.value.name
  region       = var.region
  type         = local.repositories_map[each.key].retention_policy.type
  number       = local.repositories_map[each.key].retention_policy.number

  dynamic "tag_selectors" {
    for_each = try(local.repositories_map[each.key].retention_policy.tag_selectors, [])
    content {
      kind    = try(tag_selectors.value.kind, null)
      pattern = tag_selectors.value.pattern
    }
  }

  depends_on = [huaweicloud_swr_repository.this]
}

