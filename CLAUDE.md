# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A static HTML/CSS portfolio site (DMI course material) deployed to AWS via S3 + CloudFront. Infrastructure is meant to be provisioned with Terraform and generated on demand via the `scaffold-terraform` skill — there is no `terraform/` directory in the repo yet; it's created when that skill runs.

## Architecture

### Application (Static Site)
- **index.html** — Single-page portfolio (About, Services, Courses, Books, Community, Contact), 613 lines
- **style.css** — All styling, ~1145 lines, mobile-first responsive (breakpoints: 900px, 768px, 600px)
- **privacy.html / terms.html** — Standalone pages with inline styles
- **images/** — Static assets (logo, profile, course thumbnails, hero background)
- Pure HTML5 + CSS3, no JavaScript, no build step

### Infrastructure (generated into `terraform/` by the `scaffold-terraform` skill)
Per `.claude/skills/scaffold-terraform/template-spec.md`, the generated stack is:
- S3 bucket, private, OAC-based access (no legacy OAI, no public ACLs)
- CloudFront distribution with OAC origin, `index.html` default root, 404→`/index.html` (200), redirect-to-https, `PriceClass_200`, `CachingOptimized` policy
- Variables: region, project_name, environment (default `production`), domain_name
- Outputs: cloudfront_distribution_id, cloudfront_domain_name, s3_bucket_name, s3_bucket_arn
- Backend: S3 state backend, initially commented out (bootstrap without backend first, then `terraform init -migrate-state` after the state bucket exists)

### CI/CD (`.github/workflows/deploy.yml`)
- Triggers on push to `main`
- Uses GitHub OIDC (`aws-actions/configure-aws-credentials`) to assume `arn:aws:iam::533267262133:role/github-actions-deploy` in `eu-north-1` — no long-lived AWS keys
- Syncs repo to `s3://pravinmishradmi-site-production` (excludes `.git`, `.github`, `.claude`, `terraform/`, `.mcp.json`, `*.md`, `CLAUDE.md`), then invalidates CloudFront distribution `E3V6O6MRE2E21P`
- These bucket name / role ARN / distribution ID values are specific to the live deployment — if you regenerate Terraform or redeploy infra, update this workflow file to match the new outputs

## Skills (`.claude/skills/`)

Only four skills currently exist; all are manual-only (`disable-model-invocation: true`), so invoke them explicitly rather than expecting Claude to reach for them automatically:

```
/scaffold-terraform [region] [project-name]  → Generate terraform/ files per template-spec.md (default region ap-south-1, name portfolio-site)
/tf-plan                                     → terraform plan -no-color, then summarize risk/blast radius
/tf-apply                                    → terraform apply -auto-approve -no-color, then verify outputs; does not auto-retry on failure
/deploy                                       → Read terraform outputs, aws s3 sync (with --delete), aws cloudfront create-invalidation
```

`/deploy` and `/tf-apply` are meant to be run in that order after `/tf-plan` has been reviewed — do not skip straight to apply/deploy on a fresh scaffold.

## Commands

```bash
# Terraform (after /scaffold-terraform has generated terraform/)
cd terraform && terraform init
cd terraform && terraform plan
cd terraform && terraform apply

# Local preview
open index.html

# Manual S3 sync (CI does this automatically on push to main)
aws s3 sync . s3://pravinmishradmi-site-production --exclude "terraform/*" --exclude ".git/*" --exclude ".github/*" --exclude "*.md" --exclude ".claude/*" --delete
```

## Conventions
- Terraform files live under `terraform/` with standard layout (main.tf, variables.tf, outputs.tf, providers.tf, backend.tf) — see the skill files above rather than writing infra by hand
- GitHub Actions uses OIDC — no stored AWS access keys
- Site content changes deploy automatically via GitHub Actions on push to `main`; infra changes go through `/tf-plan` → `/tf-apply` manually

## Ownership Proof Rule (DMI Course Requirement)

Per README.md: before deploying to a personal VM/instance for the course, students must replace the footer ownership line:

```html
<p>Crafted with <span>cloud</span> excellence by Pravin Mishra</p>
```

with their own cohort/name/date, e.g.:

```html
<p><strong>Deployed by:</strong> DMI Cohort 2 | Rahul Sharma | Group 4 | Week 1 | 16-01-2026</p>
```

This must be visible in the deployment screenshot submitted for the course.
