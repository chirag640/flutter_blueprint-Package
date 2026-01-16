# Publish script for Windows PowerShell
# Usage: ./scripts/publish.ps1 -Version 0.5.1
param(
    [string]$Version
)

if (-not $Version) {
    Write-Host "Usage: ./scripts/publish.ps1 -Version x.y.z" -ForegroundColor Yellow
    exit 1
}

Write-Host "Preparing to publish version $Version" -ForegroundColor Cyan

# Ensure clean working tree
$changes = git status --porcelain
if ($changes) {
    Write-Host "Uncommitted changes detected. Please commit or stash before publishing." -ForegroundColor Red
    git status --porcelain
    exit 1
}

# Run tests
Write-Host "Running tests..." -ForegroundColor Cyan
dart test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Abort publishing." -ForegroundColor Red
    exit 1
}

# Update version in pubspec.yaml
Write-Host "Bumping version in pubspec.yaml to $Version..." -ForegroundColor Cyan
(Get-Content pubspec.yaml) -replace '(?m)^version: .*$', "version: $Version" | Set-Content pubspec.yaml

# Sync version in version_reader.dart (fallback constant)
Write-Host "Syncing version in version_reader.dart..." -ForegroundColor Cyan
$versionReaderPath = "lib/src/utils/version_reader.dart"
(Get-Content $versionReaderPath) -replace "static const String _currentVersion = '[^']*'", "static const String _currentVersion = '$Version'" | Set-Content $versionReaderPath

git add pubspec.yaml CHANGELOG.md $versionReaderPath
git commit -m "chore(release): $Version" || Write-Host "No changes to commit"

git tag "v$Version"
git push origin main --tags

# Dry run publish
Write-Host "Running dart pub publish --dry-run" -ForegroundColor Cyan
dart pub publish --dry-run
if ($LASTEXITCODE -ne 0) {
    Write-Host "Dry-run failed. Fix issues before publishing." -ForegroundColor Red
    exit 1
}

$confirm = Read-Host "Dry-run succeeded. Publish to pub.dev now? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Aborting publish." -ForegroundColor Yellow
    exit 0
}

# Actual publish
Write-Host "Publishing to pub.dev..." -ForegroundColor Green
dart pub publish

if ($LASTEXITCODE -ne 0) {
    Write-Host "Publish failed." -ForegroundColor Red
    exit 1
}

Write-Host "Publish complete. Remember to update CHANGELOG and release notes on GitHub." -ForegroundColor Green
