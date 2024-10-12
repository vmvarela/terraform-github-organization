module "org" {
  source                        = "../.."
  name                          = "Test Organization"
  description                   = "Only tests."
  billing_email                 = "vmvarela@gmail.com"
  location                      = "Spain"
  default_repository_permission = "none"
  members_permissions           = ["create_repositories"]
  features                      = ["organization_projects"]
  security                      = ["dependabot_alerts", "dependency_graph", "dependabot_security_updates"]

  teams = {
    MYTEAM = {
      description = "My awesome team"
      maintainers = ["vmvarela"]
    }

    OTHERTEAM = {
      description      = "Another awesome team"
      security_manager = true
      maintainers      = ["vmvarela"]
      parent_team      = "MYTEAM"
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
    # MYSECRET2 = {
    #   repositories = ["terraform-github-organization"]
    # }
  }

  # variables = {
  #   email = {
  #     value        = "vmvarela@gmail.com"
  #     repositories = ["terraform-github-organization"]
  #   }
  # }

  rulesets = {
    "test" = {
      target       = "branch"
      exclude      = ["feature/*", "hotfix/*", "release/*"]
      repositories = ["terraform-github-organization"]
      rules = {
        creation = true
      }
    }
    "test-2" = {
      target       = "tag"
      include      = ["~ALL"]
      repositories = ["terraform-github-repository"]
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
            repository = "terraform-github-organization"
            path       = ".github/workflows/check-pr.yml"
            ref        = "main"
          }
        ]
      }
    }
  }

  webhooks = {
    "https://google.es/" = {
      content_type = "form"
      insecure_ssl = false
      events       = ["deployment"]
    }
  }

  custom_roles = {
    "myrole" = {
      description = "My custom role"
      base_role   = "write"
      permissions = ["remove_assignee"]
    }
  }

  # actions_permissions = {
  #   allowed_actions       = "local_only"
  #   enabled_repositories  = "selected"
  #   github_owned_actions  = true
  #   verified_actions      = true
  #   selected_repositories = ["terraform-github-organization", "terraform-github-repository"]
  # }

  runner_groups = {
    "MYRUNNERGROUP" = {
      repositories = ["terraform-github-organization"]
      workflows    = ["Release"]
    }
  }
}
