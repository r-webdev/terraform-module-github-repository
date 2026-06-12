output "name" {
  description = "Repository name."
  value       = github_repository.this.name
}

output "full_name" {
  description = "Repository full name (org/name)."
  value       = github_repository.this.full_name
}

output "html_url" {
  description = "Repository web URL."
  value       = github_repository.this.html_url
}

output "node_id" {
  description = "Repository node ID."
  value       = github_repository.this.node_id
}

output "default_branch" {
  description = "Default branch name."
  value       = github_branch_default.this.branch
}
