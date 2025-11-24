provider "huaweicloud" {
  region = local.region
}

################################################################################
# Local Variables
################################################################################

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "tr-west-1"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-huaweicloud-swr"
    GithubOrg  = "terraform-huaweicloud-modules"
  }
}

################################################################################
# SWR Module - With Retention Policy
################################################################################

module "swr" {
  source = "../../"

  organization_name = "${local.name}-org"

  repositories = [
    {
      name        = "app-date-retention-repository"
      is_public   = false
      category    = "linux"
      description = "Repository with date-based retention (30 days)"
      retention_policy = {
        type   = "date_rule"
        number = 30  # Keep images for 30 days
        tag_selectors = [
          {
            kind    = "label"
            pattern = "latest"  # Never delete 'latest' tag
          },
          {
            kind    = "regexp"
            pattern = "v\\d+\\.\\d+\\.\\d+"  # Keep semantic version tags (v1.0.0, v2.1.3, etc.)
          }
        ]
      }
    },
    {
      name        = "app-tag-retention-repository"
      is_public   = false
      category    = "app_server"
      description = "Repository with tag-based retention (keep latest 10)"
      retention_policy = {
        type   = "tag_rule"
        number = 10  # Keep only the latest 10 images
      }
    },
    {
      name        = "app-no-retention-repository"
      is_public   = false
      category    = "other"
      description = "Repository without retention policy"
      # No retention_policy - images will not be automatically deleted
    }
  ]
}

