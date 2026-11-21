$ErrorActionPreference = 'Stop'

$fusionDirectory = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion'
$fusesDirectory = Join-Path $fusionDirectory 'Fuses'
$source = Join-Path $PSScriptRoot 'ASCIIArt.fuse'
$destination = Join-Path $fusesDirectory 'ASCIIArt.fuse'

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "ASCIIArt.fuse must be next to this installer."
}

New-Item -ItemType Directory -Path $fusesDirectory -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $destination -Force
Write-Host "Installed ASCII Art in $fusesDirectory. Restart DaVinci Resolve to load it."
