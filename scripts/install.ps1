# PowerShell Script to install flutter_blueprint and add it to the user's PATH

# --- Configuration ---
$PackageName = "flutter_blueprint"

# --- Script Body ---
Write-Host "🎯 Starting installation for $PackageName..."

# 1. Find the Dart Pub Cache Path
# The pub cache path can be in %LOCALAPPDATA% or %APPDATA%
$PubCachePath = ""
$LocalPath = "$env:LOCALAPPDATA\Pub\Cache\\bin"
$RoamingPath = "$env:APPDATA\Pub\Cache\\bin"

if (Test-Path $LocalPath) {
    $PubCachePath = $LocalPath
} elseif (Test-Path $RoamingPath) {
    $PubCachePath = $RoamingPath
} else {
    Write-Host "❌ Error: Could not find the Dart Pub Cache directory."
    Write-Host "Please ensure the Dart SDK is installed correctly."
    Exit 1
}

Write-Host "✅ Found Pub Cache bin directory: $PubCachePath"

# 2. Check if the path is already in the user's PATH environment variable
$UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -like "*$PubCachePath*") {
    Write-Host "✅ Pub Cache directory is already in your PATH."
} else {
    Write-Host "🔧 Adding Pub Cache directory to your PATH..."
    $NewPath = "$UserPath;$PubCachePath"
    [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "✅ Successfully added to PATH. Please restart your terminal for changes to take effect."
}

# 3. Activate the package globally
Write-Host "📦 Activating $PackageName globally..."
dart pub global activate $PackageName

# Check if the activation was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Failed to activate '$PackageName'. Please check for errors above."
    Exit 1
}

Write-Host "🚀 Success! $PackageName is installed and ready to use."
Write-Host "👉 To get started, open a NEW terminal and run:"
Write-Host "   flutter_blueprint init"
