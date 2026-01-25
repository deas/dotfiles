# Script to install a Nerd Font for the current user (Non-Admin)
# Usage: ./install_nerd_font.ps1 [[-FontName] <String>] [[-Version] <String>] [-Force]
# Example: ./install_nerd_font.ps1 -FontName "FiraCode"
# Example: irm https://example.com/install_nerd_font.ps1 | iex
#

param (
    [Parameter(Mandatory=$false)]
    [string]$FontName = "JetBrainsMono",

    [Parameter(Mandatory=$false)]
    [string]$Version = "v3.4.0",

    [switch]$Force
)

$Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/$Version/$FontName.zip"
$ZipPath = "$env:TEMP\$FontName.zip"
$ExtractPath = "$env:TEMP\$FontName"
$UserFontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$RegistryKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

Write-Host "Targeting $FontName Nerd Font (Version $Version)..." -ForegroundColor Cyan

# 1. Idempotency Check
# We check if any files matching the font name pattern exist in the user's font directory.
# This avoids re-downloading if it looks like it's already there.
$ExistingFonts = Get-ChildItem -Path $UserFontsDir -Filter "*$FontName*.ttf" -ErrorAction SilentlyContinue

if ($ExistingFonts -and (-not $Force)) {
    Write-Host "$FontName Nerd Font appears to be already installed." -ForegroundColor Green
    Write-Host "Found existing files: $($ExistingFonts[0].Name) ..."
    Write-Host "Run with -Force to reinstall."
    exit 0
}

if ($Force) {
    Write-Host "Force switch detected. Reinstalling..." -ForegroundColor Yellow
}

# 2. Download
Write-Host "Downloading font from $Url..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath
}
catch {
    Write-Error "Failed to download font. Check if the Font Name '$FontName' is valid for Nerd Fonts releases."
    Write-Error "URL attempted: $Url"
    Write-Error "Error details: $_"
    exit 1
}

# 3. Extract
Write-Host "Extracting zip file..."
if (Test-Path $ExtractPath) { Remove-Item $ExtractPath -Recurse -Force }
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

# 4. Create User Fonts Directory if it doesn't exist
if (-not (Test-Path $UserFontsDir)) {
    Write-Host "Creating user fonts directory: $UserFontsDir"
    New-Item -ItemType Directory -Force -Path $UserFontsDir | Out-Null
}

# 5. Install Fonts
# We filter for compatible Windows font formats
$FontFiles = Get-ChildItem -Path $ExtractPath -Include "*.ttf", "*.otf" -Recurse

if ($FontFiles.Count -eq 0) {
    Write-Warning "No .ttf or .otf files found in the downloaded archive."
}

foreach ($File in $FontFiles) {
    $FileName = $File.Name
    $DestPath = Join-Path $UserFontsDir $FileName
    
    # Copy file to the user's font directory
    try {
        Copy-Item -Path $File.FullName -Destination $DestPath -Force
    }
    catch {
        Write-Warning "Could not copy $FileName. It might be in use."
        continue
    }
    
    # Register in Registry
    # The value name should ideally be the Font Name, but the filename is a sufficient fallback 
    # for scripts lacking complex TTF parsing libraries.
    $RegValueName = "$($File.BaseName) (TrueType)"
    
    # Check if registry key exists and matches before setting
    $CurrentValue = Get-ItemProperty -Path $RegistryKey -Name $RegValueName -ErrorAction SilentlyContinue
    
    if ($null -eq $CurrentValue -or $CurrentValue.$RegValueName -ne $DestPath) {
        Write-Host "Registering $FileName..."
        try {
            Set-ItemProperty -Path $RegistryKey -Name $RegValueName -Value $DestPath -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to register $FileName in registry."
        }
    }
}

# 6. Cleanup
Write-Host "Cleaning up temporary files..."
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
if (Test-Path $ExtractPath) { Remove-Item $ExtractPath -Recurse -Force }

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Note: You may need to restart your terminal (Windows Terminal, PowerShell, Putty, etc.) for the fonts to appear."
