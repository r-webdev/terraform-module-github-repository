variable "name" {
  description = "Repository name."
  type        = string
}

variable "description" {
  description = "Repository description."
  type        = string
  default     = null
}

variable "homepage_url" {
  description = "Repository homepage URL."
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility: public, private, or internal."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private, or internal."
  }
}

variable "topics" {
  description = "Repository topics."
  type        = list(string)
  default     = []
}

variable "default_branch" {
  description = "Default branch name."
  type        = string
  default     = "main"
}

variable "allow_merge_commit" {
  description = "Allow merge commits when merging pull requests."
  type        = bool
  default     = false
}

variable "allow_squash_merge" {
  description = "Allow squash merges when merging pull requests."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merges when merging pull requests."
  type        = bool
  default     = false
}

variable "squash_merge_commit_title" {
  description = "Squash merge commit title format: PR_TITLE or COMMIT_OR_PR_TITLE."
  type        = string
  default     = "PR_TITLE"

  validation {
    condition     = contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.squash_merge_commit_title)
    error_message = "squash_merge_commit_title must be PR_TITLE or COMMIT_OR_PR_TITLE."
  }
}

variable "squash_merge_commit_message" {
  description = "Squash merge commit message format: PR_BODY, COMMIT_MESSAGES, or BLANK."
  type        = string
  default     = "COMMIT_MESSAGES"

  validation {
    condition     = contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.squash_merge_commit_message)
    error_message = "squash_merge_commit_message must be PR_BODY, COMMIT_MESSAGES, or BLANK."
  }
}

variable "delete_branch_on_merge" {
  description = "Delete head branches automatically after pull requests are merged."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Allow auto-merge on pull requests."
  type        = bool
  default     = false
}

variable "has_issues" {
  description = "Enable GitHub Issues."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Enable GitHub Projects."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Enable GitHub Wiki."
  type        = bool
  default     = false
}

variable "has_discussions" {
  description = "Enable GitHub Discussions."
  type        = bool
  default     = false
}

variable "vulnerability_alerts" {
  description = "Enable Dependabot security alerts (private repos only)."
  type        = bool
  default     = true
}

variable "archive_on_destroy" {
  description = "Archive the repository instead of deleting it when Terraform destroys the resource."
  type        = bool
  default     = true
}

variable "team_permissions" {
  description = "Map of team slug to permission: pull, triage, push, maintain, or admin."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for permission in values(var.team_permissions) :
      contains(["pull", "triage", "push", "maintain", "admin"], permission)
    ])
    error_message = "Each team permission must be pull, triage, push, maintain, or admin."
  }
}

variable "collaborator_permissions" {
  description = "Map of GitHub username to permission: pull, triage, push, maintain, or admin."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for permission in values(var.collaborator_permissions) :
      contains(["pull", "triage", "push", "maintain", "admin"], permission)
    ])
    error_message = "Each collaborator permission must be pull, triage, push, maintain, or admin."
  }
}

variable "branch_protection" {
  description = "Optional branch protection rules keyed by branch pattern."
  type = map(object({
    enforce_admins                   = optional(bool, false)
    require_signed_commits           = optional(bool, false)
    required_conversation_resolution = optional(bool, true)
    required_linear_history         = optional(bool, false)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    lock_branch                     = optional(bool, false)
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, true)
      require_code_owner_reviews      = optional(bool, false)
      required_approving_review_count = optional(number, 1)
      require_last_push_approval      = optional(bool, false)
    }), null)
    required_status_checks = optional(object({
      strict   = optional(bool, true)
      contexts = optional(list(string), [])
    }), null)
  }))
  default = {}
}
