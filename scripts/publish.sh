#!/usr/bin/env bash
# Publish script for macOS / Linux
# Usage: ./scripts/publish.sh 0.5.1
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION="$1"

echo "Preparing to publish version $VERSION"

# Ensure clean working tree
if [ -n "$(git status --porcelain)" ]; then
  echo "Uncommitted changes detected. Please commit or stash before publishing." >&2
  git status --porcelain
  exit 1
fi

# Run tests
echo "Running tests..."
dart test

# Update version in pubspec.yaml
echo "Bumping version in pubspec.yaml to $VERSION..."
perl -0777 -pe "s/^version: .*$/version: $VERSION/m" -i pubspec.yaml

git add pubspec.yaml CHANGELOG.md || true
if git diff --staged --quiet; then
  echo "No staged changes to commit."
else
  git commit -m "chore(release): $VERSION"
fi

git tag "v$VERSION"
git push origin main --tags

# Dry run
echo "Running dart pub publish --dry-run"
dart pub publish --dry-run

echo "Dry-run succeeded. Run 'dart pub publish' to actually publish."
read -p "Publish now? (y/N) " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborting publish."
  exit 0
fi

# Actual publish
dart pub publish

echo "Publish complete. Remember to update CHANGELOG and GitHub release notes."