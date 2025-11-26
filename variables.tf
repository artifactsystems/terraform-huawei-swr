variable "create_organization" {
  description = "Controls if SWR organization should be created"
  type        = bool
  default     = true
}

variable "organization_name" {
  description = "(Required) The name of the organization. The organization name must be globally unique. Required if create_organization is true, or if using existing organization."
  type        = string
  default     = null
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the region set in the provider configuration"
  type        = string
  default     = null
}

variable "repositories" {
  description = "List of repositories to create in the organization"
  type = list(object({
    name        = string
    is_public   = optional(bool, false)
    description = optional(string)
    category    = optional(string)
    retention_policy = optional(object({
      type   = string # date_rule or tag_rule
      number = number # days for date_rule, count for tag_rule
      tag_selectors = optional(list(object({
        kind    = optional(string) # label or regexp
        pattern = string
      })), [])
    }), null)
  }))
  default = []
}

################################################################################
# Organization Timeouts
################################################################################

variable "organization_timeouts" {
  description = "Timeout configuration for organization resource"
  type = object({
    create = optional(string, "5m")
    delete = optional(string, "5m")
  })
  default = {}
}
