# Set the windows terminal font to a Nerd Font (JetBrainsMono NF)
# Example: irm https://example.com/termina_set_nerd_font.ps1 | iex
# Define the Font Face
$fontName = "JetBrainsMono NF"

# Locate Windows Terminal settings.json (Standard vs Preview paths)
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path $settingsPath)) { 
    $settingsPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json" 
}

if (Test-Path $settingsPath) {
    # Load and parse the JSON
    $jsonRaw = Get-Content $settingsPath -Raw
    $settings = $jsonRaw | ConvertFrom-Json

    # Check if 'font' property exists in defaults, if not, create it
    if (-not $settings.profiles.defaults.font) {
        $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value @{}
    }

    # IDEMPOTENCY CHECK: Only update if the font is different
    if ($settings.profiles.defaults.font.face -ne $fontName) {
        Write-Host "Updating Windows Terminal font to $fontName..." -ForegroundColor Cyan
        $settings.profiles.defaults.font.face = $fontName
        
        # Convert back to JSON and save
        # Depth 10 ensures nested profiles aren't truncated
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
        Write-Host "Success! Windows Terminal updated." -ForegroundColor Green
    } else {
        Write-Host "Font is already set to $fontName. No changes needed." -ForegroundColor Yellow
    }
} else {
    Write-Warning "Windows Terminal settings file not found."
}
