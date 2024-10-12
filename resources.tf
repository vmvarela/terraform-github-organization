resource "github_organization_settings" "this" {
  billing_email                                                = var.billing_email
  company                                                      = var.company
  blog                                                         = var.blog
  email                                                        = var.email
  twitter_username                                             = var.twitter
  location                                                     = var.location
  name                                                         = var.name
  description                                                  = var.description
  has_organization_projects                                    = contains(var.features, "organization_projects")
  has_repository_projects                                      = contains(var.features, "repository_projects")
  default_repository_permission                                = var.default_repository_permission
  members_can_create_repositories                              = contains(var.members_permissions, "create_repositories")
  members_can_create_public_repositories                       = contains(var.members_permissions, "create_public_repositories")
  members_can_create_private_repositories                      = contains(var.members_permissions, "create_private_repositories")
  members_can_create_internal_repositories                     = contains(var.members_permissions, "create_internal_repositories")
  members_can_create_pages                                     = contains(var.members_permissions, "create_pages")
  members_can_create_public_pages                              = contains(var.members_permissions, "create_public_pages")
  members_can_create_private_pages                             = contains(var.members_permissions, "create_private_pages")
  members_can_fork_private_repositories                        = contains(var.members_permissions, "fork_private_repositories")
  web_commit_signoff_required                                  = var.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = contains(var.security, "advanced")
  dependabot_alerts_enabled_for_new_repositories               = contains(var.security, "dependabot_alerts")
  dependabot_security_updates_enabled_for_new_repositories     = contains(var.security, "dependabot_security_updates")
  dependency_graph_enabled_for_new_repositories                = contains(var.security, "dependency_graph")
  secret_scanning_enabled_for_new_repositories                 = contains(var.security, "secret_scanning")
  secret_scanning_push_protection_enabled_for_new_repositories = contains(var.security, "secret_scanning_push_protection")
}

resource "github_team" "this" {
  for_each       = var.teams
  name           = each.key
  description    = each.value["description"]
  privacy        = each.value["privacy"]
  parent_team_id = each.value["parent_team"]
}

resource "github_team_members" "this" {
  for_each = { for team, data in var.teams : team => data if data["members"] != null || data["maintainers"] != null }
  team_id  = github_team.this[each.key].id
  dynamic "members" {
    for_each = each.value["members"] != null ? each.value["members"] : []
    content {
      username = members.value
      role     = "member"
    }
  }
  dynamic "members" {
    for_each = each.value["maintainers"] != null ? each.value["maintainers"] : []
    content {
      username = members.value
      role     = "maintainer"
    }
  }
}

resource "github_team_settings" "this" {
  for_each = {
    for team, team_data in var.teams : team => team_data
    if team_data["review_request_delegation"] != null
  }
  team_id = github_team.this[each.key].id
  review_request_delegation {
    algorithm    = each.value["review_request_delegation"]["algorithm"]
    member_count = each.value["review_request_delegation"]["member_count"]
    notify       = each.value["review_request_delegation"]["notify"]
  }
}

resource "github_organization_security_manager" "this" {
  for_each = {
    for team, team_data in var.teams : team => team_data
    if try(team_data["security_manager"], false) == true
  }
  team_slug = github_team.this[each.key].slug
}

resource "github_actions_organization_secret" "this" {
  for_each        = try(local.managed_secrets, null) != null ? local.managed_secrets : {}
  visibility      = each.value.repositories != null ? "selected" : "all"
  secret_name     = each.key
  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value
  selected_repository_ids = each.value.repositories != null ? [
    for repository in each.value.repositories :
    data.github_repository.this[repository].repo_id
  ] : []
}

resource "github_actions_organization_secret_repositories" "this" {
  for_each    = try(local.existing_secrets, null) != null ? local.existing_secrets : {}
  secret_name = each.key
  selected_repository_ids = each.value.repositories != null ? [
    for repository in each.value.repositories:
    data.github_repository.this[repository].repo_id
  ] : []
}

resource "github_actions_organization_variable" "this" {
  for_each      = try(var.variables, null) != null ? var.variables : {}
  visibility    = each.value.repositories != null ? "selected" : "all"
  variable_name = each.key
  value         = each.value.value
  selected_repository_ids = each.value.repositories != null ? [
    for repository in each.value.repositories:
    data.github_repository.this[repository].repo_id
  ] : []
}

resource "github_organization_ruleset" "this" {
  for_each    = (var.enterprise && try(var.rulesets, null) != null) ? var.rulesets : {}
  name        = each.key
  enforcement = each.value.enforcement
  rules {
    dynamic "branch_name_pattern" {
      for_each = try(each.value.rules.branch_name_pattern, null) != null ? [1] : []
      content {
        operator = each.value.rules.branch_name_pattern.operator
        pattern  = each.value.rules.branch_name_pattern.pattern
        name     = each.value.rules.branch_name_pattern.name
        negate   = each.value.rules.branch_name_pattern.negate
      }
    }
    dynamic "commit_author_email_pattern" {
      for_each = try(each.value.rules.commit_author_email_pattern, null) != null ? [1] : []
      content {
        operator = each.value.rules.commit_author_email_pattern.operator
        pattern  = each.value.rules.commit_author_email_pattern.pattern
        name     = each.value.rules.commit_author_email_pattern.name
        negate   = each.value.rules.commit_author_email_pattern.negate
      }
    }
    dynamic "commit_message_pattern" {
      for_each = try(each.value.rules.commit_message_pattern, null) != null ? [1] : []
      content {
        operator = each.value.rules.commit_message_pattern.operator
        pattern  = each.value.rules.commit_message_pattern.pattern
        name     = each.value.rules.commit_message_pattern.name
        negate   = each.value.rules.commit_message_pattern.negate
      }
    }
    dynamic "committer_email_pattern" {
      for_each = try(each.value.rules.committer_email_pattern, null) != null ? [1] : []
      content {
        operator = each.value.rules.committer_email_pattern.operator
        pattern  = each.value.rules.committer_email_pattern.pattern
        name     = each.value.rules.committer_email_pattern.name
        negate   = each.value.rules.committer_email_pattern.negate
      }
    }
    creation         = each.value.rules.creation
    deletion         = each.value.rules.deletion
    non_fast_forward = each.value.rules.non_fast_forward
    dynamic "pull_request" {
      for_each = try(each.value.rules.pull_request, null) != null ? [1] : []
      content {
        dismiss_stale_reviews_on_push     = each.value.rules.pull_request.dismiss_stale_reviews_on_push
        require_code_owner_review         = each.value.rules.pull_request.require_code_owner_review
        require_last_push_approval        = each.value.rules.pull_request.require_last_push_approval
        required_approving_review_count   = each.value.rules.pull_request.required_approving_review_count
        required_review_thread_resolution = each.value.rules.pull_request.required_review_thread_resolution
      }
    }
    required_linear_history = each.value.rules.required_linear_history
    required_signatures     = each.value.rules.required_signatures
    dynamic "required_status_checks" {
      for_each = (each.value.rules.required_status_checks != null) ? [1] : []
      content {
        dynamic "required_check" {
          for_each = each.value.rules.required_status_checks
          content {
            context        = required_check.key
            integration_id = required_check.value
          }
        }
        strict_required_status_checks_policy = each.value.strict_required_status_checks_policy
      }
    }
    dynamic "tag_name_pattern" {
      for_each = try(each.value.rules.tag_name_pattern, null) != null ? [1] : []
      content {
        operator = each.value.rules.tag_name_pattern.operator
        pattern  = each.value.rules.tag_name_pattern.pattern
        name     = each.value.rules.tag_name_pattern.name
        negate   = each.value.rules.tag_name_pattern.negate
      }
    }
    dynamic "required_workflows" {
      for_each = each.value.rules.required_workflows != null ? [1] : []
      content {
        dynamic "required_workflow" {
          for_each = each.value.rules.required_workflows != null ? each.value.rules.required_workflows : []
          content {
            repository_id = data.github_repository.this[required_workflow.value.repository].repo_id
            path          = required_workflow.value.path
            ref           = required_workflow.value.ref
          }
        }
      }
    }
    update = each.value.rules.update
  }
  target = each.value.target
  dynamic "bypass_actors" {
    for_each = (each.value.bypass_actors != null) ? each.value.bypass_actors : {}
    content {
      actor_id    = bypass_actors.key
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }
  dynamic "conditions" {
    for_each = (length(each.value.include) + length(each.value.exclude) > 0) ? [1] : []
    content {
      ref_name {
        include = [for p in each.value.include :
          substr(p, 0, 1) == "~" ? p : format("refs/%s/%s", each.value.target == "branch" ? "heads" : "tags", p)
        ]
        exclude = [for p in each.value.exclude :
          substr(p, 0, 1) == "~" ? p : format("refs/%s/%s", each.value.target == "branch" ? "heads" : "tags", p)
        ]
      }
      repository_name {
        include = each.value.repositories
        exclude = []
      }
    }
  }
}

resource "github_organization_webhook" "this" {
  for_each = try(var.webhooks, null) != null ? var.webhooks : {}
  active   = true
  configuration {
    url          = each.key
    content_type = each.value.content_type
    insecure_ssl = each.value.insecure_ssl
    secret       = each.value.secret
  }
  events = each.value.events
}

resource "github_organization_custom_role" "this" {
  for_each    = (var.enterprise && try(var.custom_roles, null) != null) ? var.custom_roles : {}
  name        = each.key
  description = each.value.description
  base_role   = each.value.base_role
  permissions = each.value.permissions
}

resource "github_actions_organization_permissions" "this" {
  count                = var.actions_permissions != null ? 1 : 0
  allowed_actions      = try(var.actions_permissions.allowed_actions, "all")
  enabled_repositories = try(var.actions_permissions.enabled_repositories, "all")
  allowed_actions_config {
    github_owned_allowed = try(var.actions_permissions.github_owned_actions, true)
    patterns_allowed     = try(var.actions_permissions.patterns_actions, [])
    verified_allowed     = try(var.actions_permissions.verified_actions, true)
  }
  enabled_repositories_config {
    repository_ids = [for repository in try(var.actions_permissions.selected_repositories, []) :
      data.github_repository.this[repository].repo_id
    ]
  }
}

resource "github_actions_runner_group" "this" {
  for_each   = (var.enterprise && try(var.runner_groups, null) != null) ? var.runner_groups : {}
  name       = each.key
  visibility = try(each.value.repositories, null) != null ? "selected" : "all"
  selected_repository_ids = [for repository in try(each.value.repositories, []) :
    data.github_repository.this[repository].repo_id
  ]
  restricted_to_workflows = try(each.value.workflows, null) != null
  selected_workflows      = try(each.value.workflows, null)
}

