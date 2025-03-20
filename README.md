# Github Organization Terraform module

new module!: https://github.com/vmvarela/terraform-github-org

---

Terraform module to manage GitHub organization settings, including teams, roles, and organization-wide repository configurations.

These features of Github Organization configurations are supported:

- settings
- teams (w/security manager role)
- secrets (managed/existing) & variables
- rulesets (enterprise)
- webhooks
- custom roles (enterprise)
- actions permissions config
- runner groups (enterprise)

## Usage

### Private repository

```hcl
module "org" {
  source = "vmvarela/org/github"

  name           = "my-org"
  billing_email                                            = "my-email@mail.com"
  location                                                 = "Spain"
  default_repository_permission                            = "none"
  members_can_create_repositories                          = false
  members_can_create_private_repositories                  = false
  members_can_create_public_repositories                   = false
  members_can_create_pages                                 = false
  members_can_create_private_pages                         = false
  members_can_create_public_pages                          = false
  members_can_fork_private_repositories                    = false
  has_organization_projects                                = false
  has_repository_projects                                  = false
  dependabot_alerts_enabled_for_new_repositories           = true
  dependency_graph_enabled_for_new_repositories            = true
  dependabot_security_updates_enabled_for_new_repositories = true

  teams = {
    MYTEAM = {
      description = "My awesome team"
      privacy     = "closed"
      members     = ["vmvarela"]
    }

    OTHERTEAM = {
      description      = "Another awesome team"
      security_manager = true
      maintainers      = ["vmvarela"]
      parent_team      = "MYTEAM"
      privacy          = "closed"
      review_request_delegation = {
        algorithm    = "LOAD_BALANCE"
        member_count = 2
      }
    }
  }

  secrets = {
    MYSECRET = {
      plaintext_value = "mysecret"
    }
  }

  variables = {
    email = {
      value        = "vmvarela@gmail.com"
      visibility   = "selected"
      repositories = ["my-repo-1"]
    }
  }

  rulesets = {
    "test" = {
      target       = "branch"
      exclude      = ["feature/*", "hotfix/*", "release/*"]
      repositories = ["my-repo-1"]
      rules = {
        creation = true
      }
    }
    "test-2" = {
      target       = "tag"
      include      = ["~ALL"]
      repositories = ["my-repo-2"]
      rules = {
        deletion = true
      }
    }
    "check-pr" = {
      target       = "branch"
      include      = ["~DEFAULT_BRANCH"]
      repositories = ["~ALL"]
      rules = {
        required_workflows = [
          {
            repository = "my-repo-1"
            path       = ".github/workflows/check-pr.yml"
            ref        = "main"
          }
        ]
      }
    }
  }
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_organization_permissions.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/actions_organization_permissions) | resource |
| [github_actions_organization_secret.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_secret_repositories.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/actions_organization_secret_repositories) | resource |
| [github_actions_organization_variable.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/actions_organization_variable) | resource |
| [github_actions_runner_group.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/actions_runner_group) | resource |
| [github_organization_custom_role.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/organization_custom_role) | resource |
| [github_organization_ruleset.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/organization_ruleset) | resource |
| [github_organization_security_manager.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/organization_security_manager) | resource |
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/organization_settings) | resource |
| [github_organization_webhook.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/organization_webhook) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/team) | resource |
| [github_team_members.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/team_members) | resource |
| [github_team_settings.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/resources/team_settings) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/6.2.3/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions_permissions"></a> [actions\_permissions](#input\_actions\_permissions) | (Optional) The actions permissions configuration of the organization | <pre>object({<br>    allowed_actions       = optional(string)<br>    enabled_repositories  = optional(string)<br>    github_owned_actions  = optional(bool)<br>    patterns_actions      = optional(list(string), [])<br>    verified_actions      = optional(bool)<br>    selected_repositories = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_billing_email"></a> [billing\_email](#input\_billing\_email) | (Required) The billing email address for the organization. | `string` | n/a | yes |
| <a name="input_blog"></a> [blog](#input\_blog) | (Optional) The blog URL for the organization. | `string` | `null` | no |
| <a name="input_company"></a> [company](#input\_company) | (Optional) The company name for the organization. | `string` | `null` | no |
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | (Optional) The list of custom roles of the organization (key: role\_name) | <pre>map(object({<br>    description = optional(string)<br>    base_role   = string<br>    permissions = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_default_repository_permission"></a> [default\_repository\_permission](#input\_default\_repository\_permission) | (Optional) The default permission for organization members to create new repositories. Can be one of read, write, admin, or none. Defaults to read. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description for the organization. | `string` | `null` | no |
| <a name="input_email"></a> [email](#input\_email) | (Optional) The email address for the organization. | `string` | `null` | no |
| <a name="input_enterprise"></a> [enterprise](#input\_enterprise) | (Optional) True if the organization is associated with an enterprise account. | `bool` | `false` | no |
| <a name="input_features"></a> [features](#input\_features) | (Optional) The list of features enabled for the organization (organization\_projects, repository\_projects) | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The location for the organization. | `string` | `null` | no |
| <a name="input_members_permissions"></a> [members\_permissions](#input\_members\_permissions) | (Optional) The default permission for organization members. Can create\_repositories, create\_public\_repositories, create\_private\_repositories, or create\_internal\_repositories. | `list(string)` | <pre>[<br>  "create_repositories",<br>  "create_public_repositories",<br>  "create_private_repositories",<br>  "create_internal_repositories",<br>  "create_pages",<br>  "create_public_pages",<br>  "create_private_pages",<br>  "fork_private_repositories"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The name for the organization. | `string` | `null` | no |
| <a name="input_rulesets"></a> [rulesets](#input\_rulesets) | (Optional) Organization rules | <pre>map(object({<br>    enforcement = optional(string, "active")<br>    rules = optional(object({<br>      branch_name_pattern = optional(object({<br>        operator = optional(string)<br>        pattern  = optional(string)<br>        name     = optional(string)<br>        negate   = optional(bool)<br>      }))<br>      commit_author_email_pattern = optional(object({<br>        operator = optional(string)<br>        pattern  = optional(string)<br>        name     = optional(string)<br>        negate   = optional(bool)<br>      }))<br>      commit_message_pattern = optional(object({<br>        operator = optional(string)<br>        pattern  = optional(string)<br>        name     = optional(string)<br>        negate   = optional(bool)<br>      }))<br>      committer_email_pattern = optional(object({<br>        operator = optional(string)<br>        pattern  = optional(string)<br>        name     = optional(string)<br>        negate   = optional(bool)<br>      }))<br>      creation         = optional(bool)<br>      deletion         = optional(bool)<br>      non_fast_forward = optional(bool)<br>      pull_request = optional(object({<br>        dismiss_stale_reviews_on_push     = optional(bool)<br>        require_code_owner_review         = optional(bool)<br>        require_last_push_approval        = optional(bool)<br>        required_approving_review_count   = optional(number)<br>        required_review_thread_resolution = optional(bool)<br>      }))<br>      required_workflows = optional(list(object({<br>        repository = string<br>        path       = string<br>        ref        = optional(string)<br>      })))<br>      required_linear_history              = optional(bool)<br>      required_signatures                  = optional(bool)<br>      required_status_checks               = optional(map(string))<br>      strict_required_status_checks_policy = optional(bool)<br>      tag_name_pattern = optional(object({<br>        operator = optional(string)<br>        pattern  = optional(string)<br>        name     = optional(string)<br>        negate   = optional(bool)<br>      }))<br>      update = optional(bool)<br>    }))<br>    target = optional(string, "branch")<br>    bypass_actors = optional(map(object({<br>      actor_type  = string<br>      bypass_mode = string<br>    })))<br>    include      = optional(list(string), [])<br>    exclude      = optional(list(string), [])<br>    repositories = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_runner_groups"></a> [runner\_groups](#input\_runner\_groups) | (Optional) The list of runner groups of the organization (key: runner\_group\_name) | <pre>map(object({<br>    workflows                 = optional(list(string))<br>    repositories              = optional(list(string))<br>    allow_public_repositories = optional(bool)<br>  }))</pre> | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | (Optional) The list of secrets configuration of the organization (key: secret\_name) | <pre>map(object({<br>    encrypted_value = optional(string)<br>    plaintext_value = optional(string)<br>    repositories    = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_security"></a> [security](#input\_security) | (Optional) The list of security features enabled for the organization. | `list(string)` | <pre>[<br>  "advanced",<br>  "secret_scanning",<br>  "secret_scanning_push_protection",<br>  "dependabot_alerts",<br>  "dependabot_security_updates",<br>  "dependency_graph"<br>]</pre> | no |
| <a name="input_teams"></a> [teams](#input\_teams) | (Optional) A list of teams to add to the organization. | <pre>map(object({<br>    description      = optional(string)<br>    security_manager = optional(bool)<br>    privacy          = optional(string, "closed")<br>    parent_team      = optional(string)<br>    members          = optional(list(string))<br>    maintainers      = optional(list(string))<br>    review_request_delegation = optional(object({<br>      algorithm    = optional(string)<br>      member_count = optional(number)<br>      notify       = optional(bool)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_twitter"></a> [twitter](#input\_twitter) | (Optional) The Twitter username for the organization. | `string` | `null` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | (Optional) The list of variables configuration of the organization (key: variable\_name) | <pre>map(object({<br>    value        = string<br>    repositories = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_web_commit_signoff_required"></a> [web\_commit\_signoff\_required](#input\_web\_commit\_signoff\_required) | (Optional) Whether a commit signature is required for commits to this organization. | `bool` | `null` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | (Optional) The list of webhooks of the organization (key: webhook\_url) | <pre>map(object({<br>    content_type = string<br>    insecure_ssl = optional(bool, false)<br>    secret       = optional(string)<br>    events       = optional(list(string))<br>  }))</pre> | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
