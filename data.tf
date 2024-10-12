data "github_repository" "this" {
  for_each = local.repositories != null ? toset(local.repositories) : []
  name     = each.key
}