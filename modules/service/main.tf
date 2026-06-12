resource "github_repository" "this" {
  name        = var.name
  description = var.description
  homepage_url = var.homepage_url
  visibility  = var.visibility
  topics      = var.topics

  auto_init          = false
  archive_on_destroy = var.archive_on_destroy

  allow_merge_commit  = var.allow_merge_commit
  allow_squash_merge  = var.allow_squash_merge
  allow_rebase_merge  = var.allow_rebase_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  allow_auto_merge    = var.allow_auto_merge

  squash_merge_commit_title   = var.squash_merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message

  has_issues      = var.has_issues
  has_projects    = var.has_projects
  has_wiki        = var.has_wiki
  has_discussions = var.has_discussions
}

resource "github_repository_vulnerability_alerts" "this" {
  count = var.visibility == "private" ? 1 : 0

  repository = github_repository.this.name
  enabled    = var.vulnerability_alerts
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_team_repository" "this" {
  for_each = var.team_permissions

  repository = github_repository.this.name
  team_id    = each.key
  permission = each.value
}

resource "github_repository_collaborator" "this" {
  for_each = var.collaborator_permissions

  repository = github_repository.this.name
  username   = each.key
  permission = each.value
}

resource "github_branch_protection" "this" {
  for_each = var.branch_protection

  repository_id = github_repository.this.node_id
  pattern       = each.key

  enforce_admins                  = each.value.enforce_admins
  require_signed_commits          = each.value.require_signed_commits
  require_conversation_resolution  = each.value.required_conversation_resolution
  required_linear_history         = each.value.required_linear_history
  allows_deletions                = each.value.allows_deletions
  allows_force_pushes             = each.value.allows_force_pushes
  lock_branch                     = each.value.lock_branch

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews != null ? [each.value.required_pull_request_reviews] : []

    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
    }
  }

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks != null ? [each.value.required_status_checks] : []

    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }
}
