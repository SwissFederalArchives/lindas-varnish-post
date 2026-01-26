# lindas-varnish-post DevOps Pipeline

## Overview

This document describes the CI/CD pipeline implemented for lindas-varnish-post.

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code, auto-deploys to TEST |
| `develop` | Development branch for feature integration |

## Workflows

### Build and Deploy (`docker.yaml`)

**Triggers:**
- Push to `main` branch
- Pull requests to `main` or `develop`

**Actions:**
1. Builds multi-platform Docker image (amd64, arm64)
2. Tags with version from `package.json` and SHA
3. Auto-deploys to TEST environment (push only)
4. Saves previous TEST as `test-previous`

### Manual Deploy Workflows

| Workflow | File | Environment | Approval |
|----------|------|-------------|----------|
| Deploy to TEST | `deploy-test.yaml` | TEST | No |
| Deploy to INT | `deploy-int.yaml` | INT | No |
| Deploy to PROD | `deploy-prod.yaml` | PROD | Yes |

### Rollback Workflows

| Workflow | File | Environment | Approval |
|----------|------|-------------|----------|
| Rollback TEST | `rollback-test.yaml` | TEST | No |
| Rollback INT | `rollback-int.yaml` | INT | No |
| Rollback PROD | `rollback-prod.yaml` | PROD | Yes |

## Image Tags

| Tag | Description | Mutability |
|-----|-------------|------------|
| `X.Y.Z` | Version tag (e.g., `2.8.0`) | Immutable |
| `sha-XXXXXX` | Git SHA tag | Immutable |
| `test` | TEST environment | Mutable |
| `test-previous` | Previous TEST version | Mutable |
| `int` | INT environment | Mutable |
| `int-previous` | Previous INT version | Mutable |
| `prod` | PROD environment | Mutable |
| `prod-previous` | Previous PROD version | Mutable |

## Deployment Flow

```
develop --> PR --> main --> [auto] TEST --> [manual] INT --> [manual+approval] PROD
```

## Rollback Strategy

Each environment maintains a `-previous` tag. Rollback workflows swap the current and previous tags, allowing instant rollback and re-rollback.

## GitHub Environment Protection

The `production` environment should be configured in GitHub repository settings with:
- Required reviewers for PROD deployments
- Optional: deployment branches restriction

## Registry

Images are published to GitHub Container Registry:
```
ghcr.io/swissfederalarchives/lindas-varnish-post
```

## Related Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Run tests | `test.yaml` | Integration tests on all branches |
| Release | `release.yaml` | Changeset-based version management |
