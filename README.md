# HuaweiCloud SWR Terraform Module

Terraform module which creates SWR (Software Repository for Container) organization and repositories on Huawei Cloud.

## Features

This module supports the following SWR features:

- ✅ Organization/Namespace creation (or use existing)
- ✅ Multiple repository creation within an organization
- ✅ Public/Private repository configuration
- ✅ Repository categories (app_server, linux, framework_app, database, lang, other, windows, arm)
- ✅ Repository descriptions
- ✅ Image retention policies for automatic cleanup (date_rule and tag_rule)

## Examples

- [complete](./examples/complete) - Complete example with multiple repositories including retention policies (date_rule and tag_rule)

## Usage

### Basic Example

```hcl
module "swr" {
  source = "github.com/artifactsystems/terraform-huawei-swr?ref=v1.0.0"

  organization_name = "my-org"

  repositories = [
    {
      name        = "my-app"
      is_public   = false
      description = "My application container images"
      category    = "linux"
    }
  ]
}
```

### Using Existing Organization

```hcl
module "swr" {
  source = "github.com/artifactsystems/terraform-huawei-swr?ref=v1.0.0"

  create_organization = false
  organization_name  = "existing-org"

  repositories = [
    {
      name = "new-repo"
    }
  ]
}
```

### Multiple Repositories

```hcl
module "swr" {
  source = "github.com/artifactsystems/terraform-huawei-swr?ref=v1.0.0"

  organization_name = "my-org"

  repositories = [
    {
      name        = "frontend"
      is_public   = false
      category    = "framework_app"
      description = "Frontend application"
    },
    {
      name        = "backend"
      is_public   = false
      category    = "app_server"
      description = "Backend API service"
    },
    {
      name        = "database"
      is_public   = false
      category    = "database"
      description = "Database images"
    }
  ]
}
```

### Repository with Retention Policy

Retention policies help automatically clean up old container images to save storage space and costs.

```hcl
module "swr" {
  source = "github.com/artifactsystems/terraform-huawei-swr?ref=v1.0.0"

  organization_name = "my-org"

  repositories = [
    {
      name        = "app-with-retention"
      is_public   = false
      description = "Repository with automatic image cleanup"
      category    = "linux"
      retention_policy = {
        type   = "date_rule"
        number = 30  # Keep images for 30 days
        tag_selectors = [
          {
            kind    = "label"
            pattern = "latest"
          },
          {
            kind    = "regexp"
            pattern = "v\\d+\\.\\d+\\.\\d+"  # Keep semantic version tags
          }
        ]
      }
    },
    {
      name        = "app-tag-retention"
      is_public   = false
      description = "Repository with tag-based retention"
      category    = "app_server"
      retention_policy = {
        type   = "tag_rule"
        number = 10  # Keep only the latest 10 images
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| huaweicloud | >= 1.79.0 |

## Providers

| Name | Version |
|------|---------|
| huaweicloud | >= 1.79.0 |

## Resources

| Name | Type |
|------|------|
| [huaweicloud_swr_organization](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/swr_organization) | resource |
| [huaweicloud_swr_repository](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/swr_repository) | resource |
| [huaweicloud_swr_image_retention_policy](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/swr_image_retention_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_organization | Controls if SWR organization should be created | `bool` | `true` | no |
| organization_name | The name of the organization. Required if create_organization is true, or if using existing organization | `string` | `null` | no |
| region | Region where the resource(s) will be managed | `string` | `null` | no |
| repositories | List of repositories to create in the organization | `list(object)` | `[]` | no |
| organization_timeouts | Timeout configuration for organization resource | `object` | `{}` | no |

### Repository Object

Each repository in the `repositories` list supports the following attributes:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the repository (1-128 chars, lowercase letters, digits, periods, hyphens, underscores) | `string` | - | yes |
| is_public | Whether the repository is public. Public repositories can be pulled by anyone without authentication | `bool` | `false` | no |
| description | Description of the repository | `string` | `null` | no |
| category | Category of the repository. Valid values: `app_server`, `linux`, `framework_app`, `database`, `lang`, `other`, `windows`, `arm` | `string` | `null` | no |
| retention_policy | Image retention policy configuration for automatic cleanup. See [Retention Policy Object](#retention-policy-object) below | `object` | `null` | no |

### Retention Policy Object

The `retention_policy` object configures automatic image cleanup. Images matching the retention rules will be automatically deleted to save storage space.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| type | Retention policy type. Valid values: `date_rule` (delete images older than X days) or `tag_rule` (keep only the latest N images) | `string` | - | yes |
| number | For `date_rule`: Number of days to keep images. For `tag_rule`: Number of latest images to keep | `number` | - | yes |
| tag_selectors | List of tag selectors to exclude from retention policy. Images matching these selectors will never be deleted | `list(object)` | `[]` | no |

#### Tag Selector Object

Tag selectors allow you to protect specific images from being deleted by the retention policy. For example, you might want to always keep the `latest` tag or semantic version tags.

Each tag selector in the `tag_selectors` list supports:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kind | Matching rule type. Valid values: `label` (exact tag match) or `regexp` (regular expression match) | `string` | `null` | no |
| pattern | Matching pattern. For `label`: exact tag name (e.g., `latest`). For `regexp`: regular expression pattern (e.g., `v\\d+\\.\\d+\\.\\d+` for semantic versions) | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| organization_id | ID of the organization |
| organization_name | Name of the organization |
| organization_creator | The creator user name of the organization |
| organization_permission | The permission level of the organization creator (Manage, Write, or Read) |
| organization_login_server | The URL that can be used to log into the container registry (e.g., `swr.tr-west-1.myhuaweicloud.com`) |
| repository_ids | Map of repository IDs, keyed by repository name |
| repository_details | Map of repository details including `id`, `repository_id`, `path`, `internal_path`, `num_images`, and `size` |
| repository_paths | Map of repository image paths for docker pull (e.g., `swr.tr-west-1.myhuaweicloud.com/my-org/my-repo`) |
| repository_internal_paths | Map of repository internal paths for intra-cluster docker pull (used within Huawei Cloud CCE clusters) |
| repository_retention_policies | Map of repository retention policy resource IDs, keyed by repository name |

## Known Limitations / Roadmap

> **Note:** This module is designed for SWR standard version. No enterprise version features are supported.

The following features are **not yet implemented** but are planned for future releases:

## Notes

- **Public vs Private Repositories**: Public repositories can be pulled by anyone without authentication, but only authorized users can push images. Private repositories require authentication for both pull and push operations.
- **Retention Policies**: Retention policies help manage storage costs by automatically deleting old images. Use `tag_selectors` to protect important tags (like `latest` or version tags) from deletion.
- **Organization Names**: Organization names must be globally unique across all Huawei Cloud accounts.
