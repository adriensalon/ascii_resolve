$ErrorActionPreference = 'Stop'

$fusionDirectory = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion'
$fusesDirectory = Join-Path $fusionDirectory 'Fuses'
$templatesDirectory = Join-Path $fusionDirectory 'Templates'
$fuseSource = Join-Path $PSScriptRoot 'ASCIIArt.fuse'
$templateSource = Join-Path $PSScriptRoot 'ASCIIArt.setting'

foreach ($source in @($fuseSource, $templateSource)) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "$(Split-Path -Leaf $source) must be next to this installer."
    }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Path $fusesDirectory, $templatesDirectory -Force | Out-Null
$templateBundle = Join-Path $templatesDirectory 'ASCIIArt.drfx'
$stagingPath = Join-Path $templatesDirectory ('ASCIIArt-' + [guid]::NewGuid().ToString('N') + '.tmp')

try {
    $archive = [IO.Compression.ZipFile]::Open($stagingPath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $archive, $templateSource, 'Edit/Effects/ASCII Art.setting')
    } finally {
        $archive.Dispose()
    }

    Copy-Item -LiteralPath $fuseSource -Destination (Join-Path $fusesDirectory 'ASCIIArt.fuse') -Force
    if (Test-Path -LiteralPath $templateBundle) {
        [IO.File]::Replace($stagingPath, $templateBundle, [NullString]::Value)
    } else {
        [IO.File]::Move($stagingPath, $templateBundle)
    }
} finally {
    if (Test-Path -LiteralPath $stagingPath) {
        Remove-Item -LiteralPath $stagingPath
    }
}

Write-Host 'Installed ASCII Art. Restart Resolve, then apply ASCII Art from the Edit page Effects Library.'
