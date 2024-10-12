# Local variables
locals {
  repositories = distinct(concat(
    var.secrets == null ? [] : flatten([
      for secret, secret_data in var.secrets : secret_data.repositories if secret_data.repositories != null
    ]),
    var.variables == null ? [] : flatten([
      for variable, variable_data in var.variables : variable_data.repositories if variable_data.repositories != null
    ]),
    var.rulesets == null ? [] : flatten([
      for _, data in flatten(try([for r in var.rulesets : r.required_workflows], [])) : try(data.repository, null)
    ]),
    try(var.actions_permissions.selected_repositories, []),
    try(var.runner_groups.repositories, []),
  ))

  managed_secrets = var.secrets == null ? {} : {
    for secret, secret_data in var.secrets : secret => secret_data
    if secret_data.plaintext_value != null || secret_data.encrypted_value != null
  }
  existing_secrets = var.secrets == null ? {} : {
    for secret, secret_data in var.secrets : secret => secret_data
    if secret_data.plaintext_value == null && secret_data.encrypted_value == null
  }
}
