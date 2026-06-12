# terraform-service

Terraform module for managing GitHub repository settings and permissions. Add a `terraform/` folder in each project and reference the module by git `source`.

## What it manages

- Merge settings (squash-only, delete branch on merge, etc.)
- Visibility, description, topics
- Default branch
- Team and collaborator permissions
- Branch protection rules

## Repository setup

Add a `terraform/` folder to any project (e.g. `r-webdev/website/terraform/`).

### `versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "r-webdev"
}
```

### `main.tf`

```hcl
module "repository" {
  source = "git::https://github.com/r-webdev/terraform-service.git//modules/service?ref=v1.0.0"

  name        = "website"
  description = "Web Dev & Design community website"
  visibility  = "public"
  topics      = ["astro", "community"]

  # Squash-only merges
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  team_permissions = {
    maintainers = "admin"
    developers  = "push"
  }

  branch_protection = {
    main = {
      required_pull_request_reviews = {
        required_approving_review_count = 1
      }
      required_status_checks = {
        contexts = ["ci"] # must match your GitHub Actions check name
      }
    }
  }
}
```

### New vs existing repository

The module does not initialize the repository with a first commit (`auto_init = false`). The default branch and any branch protection rules require that branch to already exist on GitHub.

**Existing repository (recommended):** import the resources below, then plan and apply.

**New repository:** run `terraform apply` once to create the empty repository, push an initial commit so the default branch exists (e.g. `main`), then run `terraform apply` again to configure the default branch, permissions, and protection rules.

### Authenticate and run

```bash
export GITHUB_TOKEN="ghp_..." # needs repo + admin:org for team permissions
cd terraform
terraform init
terraform plan
terraform apply
```

### Import an existing repository

Import before the first apply so Terraform adopts the repo instead of trying to create it:

```bash
terraform import 'module.repository.github_repository.this' website
terraform import 'module.repository.github_branch_default.this' website
```

Set `default_branch` in your module call to match the repo's current default (defaults to `"main"`).

If branch protection rules already exist on GitHub:

```bash
terraform import 'module.repository.github_branch_protection.this["main"]' website:main
```

If teams already have access and you set `team_permissions`:

```bash
terraform import 'module.repository.github_team_repository.this["maintainers"]' maintainers:website
terraform import 'module.repository.github_team_repository.this["developers"]' developers:website
```

Then `terraform plan` should show setting changes only, not a new repository.

## Squash-only merges

```hcl
allow_merge_commit = false
allow_squash_merge = true
allow_rebase_merge = false
```

## Permissions

```hcl
team_permissions = {
  maintainers = "admin" # team slug -> pull | triage | push | maintain | admin
  developers  = "push"
}

collaborator_permissions = {
  octocat = "maintain"
}
```

Team slugs are the URL segment, e.g. `https://github.com/orgs/r-webdev/teams/maintainers` → `maintainers`.

## Branch protection

```hcl
branch_protection = {
  main = {
    required_pull_request_reviews = {
      required_approving_review_count = 1
    }
    required_status_checks = {
      strict   = true
      contexts = ["ci"] # must match your GitHub Actions job/check name
    }
  }
}
```

## Versioning

Tag releases so consumers can pin a version:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Then reference `?ref=v1.0.0` in the module `source`. The tag must exist on the remote before consumers can pin it.

## Layout

```
modules/service/   # reusable module (referenced by git source)
```
