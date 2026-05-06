#!/usr/bin/env bash
set -euo pipefail

# Tag the Azure Storage Account used for Terraform state with GitHub repo info.
# Usage: ./scripts/tag-tfstate-storage.sh
# Requires az CLI and appropriate credentials in env or .env file.

# Load environment variables from .env if present
if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${STORAGE_ACCOUNT_NAME?Need STORAGE_ACCOUNT_NAME in env or .env}"
: "${RESOURCE_GROUP_NAME?Need RESOURCE_GROUP_NAME in env or .env}"

# Determine Git repo remote
GIT_REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
if [ -z "${GIT_REMOTE_URL}" ]; then
  echo "Warning: could not determine git remote URL; set GIT_REPO env to override." >&2
  GIT_REMOTE_URL=${GIT_REPO:-}
fi

# Determine current branch and commit
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || true)

# Login with service principal if credentials are provided
if [ -n "${ARM_CLIENT_ID:-}" ] && [ -n "${ARM_CLIENT_SECRET:-}" ] && [ -n "${ARM_TENANT_ID:-}" ]; then
  echo "Logging into Azure using service principal..."
  az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" >/dev/null
fi

# Build tags object
# Use keys: git_repo, git_branch, git_commit
TAG_ARGS=(--set)
TAG_ARGS+=("tags.git_repo=$GIT_REMOTE_URL")
if [ -n "$GIT_BRANCH" ]; then
  TAG_ARGS+=("--set")
  TAG_ARGS+=("tags.git_branch=$GIT_BRANCH")
fi
if [ -n "$GIT_COMMIT" ]; then
  TAG_ARGS+=("--set")
  TAG_ARGS+=("tags.git_commit=$GIT_COMMIT")
fi

# Run the update
echo "Updating storage account '$STORAGE_ACCOUNT_NAME' in resource group '$RESOURCE_GROUP_NAME' with tags..."
az storage account update --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" "${TAG_ARGS[@]}"

echo "Done."
