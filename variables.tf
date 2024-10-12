variable "billing_email" {
  description = "(Required) The billing email address for the organization."
  type        = string
}

variable "enterprise" {
  description = "(Optional) True if the organization is associated with an enterprise account."
  type        = bool
  default     = false
}

variable "company" {
  description = "(Optional) The company name for the organization."
  type        = string
  default     = null
}

variable "blog" {
  description = "(Optional) The blog URL for the organization."
  type        = string
  default     = null
}

variable "email" {
  description = "(Optional) The email address for the organization."
  type        = string
  default     = null
}

variable "twitter" {
  description = "(Optional) The Twitter username for the organization."
  type        = string
  default     = null
}

variable "location" {
  description = "(Optional) The location for the organization."
  type        = string
  default     = null
}

variable "name" {
  description = "(Optional) The name for the organization."
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional) The description for the organization."
  type        = string
  default     = null
}

variable "features" {
  description = "(Optional) The list of features enabled for the organization (organization_projects, repository_projects)"
  type        = list(string)
  default     = []
}

variable "default_repository_permission" {
  description = "(Optional) The default permission for organization members to create new repositories. Can be one of read, write, admin, or none. Defaults to read."
  type        = string
  default     = null
}

variable "members_permissions" {
  description = "(Optional) The default permission for organization members. Can create_repositories, create_public_repositories, create_private_repositories, or create_internal_repositories."
  type        = list(string)
  default = [
    "create_repositories",
    "create_public_repositories",
    "create_private_repositories",
    "create_internal_repositories",
    "create_pages",
    "create_public_pages",
    "create_private_pages",
    "fork_private_repositories"
  ]
}

variable "web_commit_signoff_required" {
  description = "(Optional) Whether a commit signature is required for commits to this organization."
  type        = bool
  default     = null
}

variable "security" {
  description = "(Optional) The list of security features enabled for the organization."
  type        = list(string)
  default = [
    "advanced",
    "secret_scanning",
    "secret_scanning_push_protection",
    "dependabot_alerts",
    "dependabot_security_updates",
    "dependency_graph"
  ]
}

variable "teams" {
  description = "(Optional) A list of teams to add to the organization."
  type = map(object({
    description      = optional(string)
    security_manager = optional(bool)
    privacy          = optional(string, "closed")
    parent_team      = optional(string)
    members          = optional(list(string))
    maintainers      = optional(list(string))
    review_request_delegation = optional(object({
      algorithm    = optional(string)
      member_count = optional(number)
      notify       = optional(bool)
    }))
  }))
  default = {}
}

variable "secrets" {
  description = "(Optional) The list of secrets configuration of the organization (key: secret_name)"
  type = map(object({
    encrypted_value = optional(string)
    plaintext_value = optional(string)
    repositories    = optional(list(string))
  }))
  default = null
}

variable "variables" {
  description = "(Optional) The list of variables configuration of the organization (key: variable_name)"
  type = map(object({
    value        = string
    repositories = optional(list(string))
  }))
  default = null
}

variable "rulesets" {
  description = "(Optional) Organization rules"
  type = map(object({
    enforcement = optional(string, "active")
    rules = optional(object({
      branch_name_pattern = optional(object({
        operator = optional(string)
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)
      }))
      commit_author_email_pattern = optional(object({
        operator = optional(string)
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)
      }))
      commit_message_pattern = optional(object({
        operator = optional(string)
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)
      }))
      committer_email_pattern = optional(object({
        operator = optional(string)
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)
      }))
      creation         = optional(bool)
      deletion         = optional(bool)
      non_fast_forward = optional(bool)
      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool)
        require_code_owner_review         = optional(bool)
        require_last_push_approval        = optional(bool)
        required_approving_review_count   = optional(number)
        required_review_thread_resolution = optional(bool)
      }))
      required_workflows = optional(list(object({
        repository = string
        path       = string
        ref        = optional(string)
      })))
      required_linear_history              = optional(bool)
      required_signatures                  = optional(bool)
      required_status_checks               = optional(map(string))
      strict_required_status_checks_policy = optional(bool)
      tag_name_pattern = optional(object({
        operator = optional(string)
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)
      }))
      update = optional(bool)
    }))
    target = optional(string, "branch")
    bypass_actors = optional(map(object({
      actor_type  = string
      bypass_mode = string
    })))
    include      = optional(list(string), [])
    exclude      = optional(list(string), [])
    repositories = optional(list(string))
  }))
  default = {}
  validation {
    condition     = alltrue([for name, config in(var.rulesets == null ? {} : var.rulesets) : contains(["active", "evaluate", "disabled"], config.enforcement)])
    error_message = "Possible values for enforcement are active, evaluate or disabled."
  }
  validation {
    condition     = alltrue([for name, config in(var.rulesets == null ? {} : var.rulesets) : contains(["tag", "branch"], config.target)])
    error_message = "Possible values for ruleset target are tag or branch"
  }
}

variable "webhooks" {
  description = "(Optional) The list of webhooks of the organization (key: webhook_url)"
  type = map(object({
    content_type = string
    insecure_ssl = optional(bool, false)
    secret       = optional(string)
    events       = optional(list(string))
  }))
  default = null
  validation {
    condition     = alltrue([for url, config in(var.webhooks == null ? {} : var.webhooks) : contains(["form", "json"], config.content_type)])
    error_message = "Possible values for content_type are json or form."
  }
}

variable "custom_roles" {
  description = "(Optional) The list of custom roles of the organization (key: role_name)"
  type = map(object({
    description = optional(string)
    base_role   = string
    permissions = list(string)
  }))
  default = null
  validation {
    condition     = alltrue([for role, config in(var.custom_roles == null ? {} : var.custom_roles) : contains(["read", "triage", "write", "maintain"], config.base_role)])
    error_message = "Possible values for base_role are read, triage, write or maintain."
  }
}

variable "actions_permissions" {
  description = "(Optional) The actions permissions configuration of the organization"
  type = object({
    allowed_actions       = optional(string)
    enabled_repositories  = optional(string)
    github_owned_actions  = optional(bool)
    patterns_actions      = optional(list(string), [])
    verified_actions      = optional(bool)
    selected_repositories = optional(list(string), [])
  })
  default = null
}

variable "runner_groups" {
  description = "(Optional) The list of runner groups of the organization (key: runner_group_name)"
  type = map(object({
    workflows                 = optional(list(string))
    repositories              = optional(list(string))
    allow_public_repositories = optional(bool)
  }))
  default = null
}
