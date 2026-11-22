$ErrorActionPreference = 'Stop'

$fusionDirectory = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion'
$fusesDirectory = Join-Path $fusionDirectory 'Fuses'
$templatesDirectory = Join-Path $fusionDirectory 'Templates'
$templates = [ordered]@{
    'ASCIIArt' = 'Edit/Effects/ASCII Art.setting'
    'ASCIIText' = 'Edit/Titles/ASCII Text.setting'
}
$fontCatalog = Join-Path $PSScriptRoot 'ASCIITextFonts.txt'
$fontNames = @(Get-Content -LiteralPath $fontCatalog)

function Save-BannerFontArchive($path, $names) {
    Add-Type -AssemblyName System.Net.Http
    $client = [Net.Http.HttpClient]::new()
    try {
        $archive = [IO.Compression.ZipFile]::Open($path, [IO.Compression.ZipArchiveMode]::Create)
        try {
            for ($start = 0; $start -lt $names.Count; $start += 8) {
                $last = [Math]::Min($start + 7, $names.Count - 1)
                $pending = foreach ($name in $names[$start..$last]) {
                    $url = 'https://www.asciiart.eu/assets/fonts/' + [Uri]::EscapeDataString($name) + '.flf'
                    @{ Name = $name; Download = $client.GetByteArrayAsync($url) }
                }
                foreach ($font in $pending) {
                    try {
                        $bytes = $font.Download.GetAwaiter().GetResult()
                    } catch {
                        throw "Could not download the banner font '$($font.Name)'. $($_.Exception.Message)"
                    }
                    $stream = $archive.CreateEntry($font.Name + '.flf').Open()
                    try {
                        $stream.Write($bytes, 0, $bytes.Length)
                    } finally {
                        $stream.Dispose()
                    }
                }
            }
        } finally {
            $archive.Dispose()
        }
    } finally {
        $client.Dispose()
    }
}

function Read-BannerFontSource($path, $names) {
    $source = [Text.StringBuilder]::new()
    $archive = [IO.Compression.ZipFile]::OpenRead($path)
    try {
        foreach ($name in $names) {
            $entry = $archive.GetEntry($name + '.flf')
            if (-not $entry) { throw "Missing banner font '$name'." }
            $reader = [IO.StreamReader]::new($entry.Open())
            try {
                $data = $reader.ReadToEnd().Replace("`r`n", "`n").Replace("`r", "`n")
            } finally {
                $reader.Dispose()
            }
            if ($data -notmatch '^[ft]lf2a') { throw "Invalid FIGlet data for '$name'." }

            # Lua long strings preserve the font rows, including whitespace and backslashes.
            $delimiter = '='
            while ($data.Contains("]$delimiter]")) { $delimiter += '=' }
            $luaName = $name.Replace('\', '\\').Replace('"', '\"')
            [void]$source.Append("{ `"$luaName`", [$delimiter[$data`n]$delimiter] },`n")
        }
    } finally {
        $archive.Dispose()
    }
    return $source.ToString()
}

foreach ($name in $templates.Keys) {
    foreach ($extension in 'fuse', 'setting') {
        $source = Join-Path $PSScriptRoot "$name.$extension"
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "$(Split-Path -Leaf $source) must be next to this installer."
        }
    }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Path $fusesDirectory, $templatesDirectory -Force | Out-Null
$templateBundle = Join-Path $templatesDirectory 'ASCIIArt.drfx'
$fontArchive = Join-Path $fusionDirectory 'ASCIITextFonts.zip'
$runId = [guid]::NewGuid().ToString('N')
$stagingPath = Join-Path $templatesDirectory "ASCIIArt-$runId.tmp"
$stagedArchive = Join-Path $fusionDirectory "ASCIITextFonts-$runId.tmp"
$stagedFuse = Join-Path $fusesDirectory "ASCIIText-$runId.tmp"

try {
    $fontSource = $null
    if (Test-Path -LiteralPath $fontArchive) {
        try {
            $fontSource = Read-BannerFontSource $fontArchive $fontNames
        } catch {
            Write-Verbose "Refreshing the banner font cache. $($_.Exception.Message)"
        }
    }
    if (-not $fontSource) {
        Write-Host "Downloading $($fontNames.Count) ASCII Text banner fonts."
        Save-BannerFontArchive $stagedArchive $fontNames
        $fontSource = Read-BannerFontSource $stagedArchive $fontNames
        if (Test-Path -LiteralPath $fontArchive) {
            [IO.File]::Replace($stagedArchive, $fontArchive, [NullString]::Value)
        } else {
            [IO.File]::Move($stagedArchive, $fontArchive)
        }
    }
    $titleSource = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'ASCIIText.fuse'))
    $fontMarker = '--[[InstallASCII.ps1 inserts the FIGlet assets here]]'
    if (-not $titleSource.Contains($fontMarker)) { throw 'Missing banner font marker in ASCIIText.fuse.' }
    [IO.File]::WriteAllText($stagedFuse, $titleSource.Replace($fontMarker, "`n$fontSource"))

    $archive = [IO.Compression.ZipFile]::Open($stagingPath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($name in $templates.Keys) {
            $source = Join-Path $PSScriptRoot "$name.setting"
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $source, $templates[$name])
        }
    } finally {
        $archive.Dispose()
    }

    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'ASCIIArt.fuse') -Destination $fusesDirectory -Force
    $titleFuse = Join-Path $fusesDirectory 'ASCIIText.fuse'
    if (Test-Path -LiteralPath $titleFuse) {
        [IO.File]::Replace($stagedFuse, $titleFuse, [NullString]::Value)
    } else {
        [IO.File]::Move($stagedFuse, $titleFuse)
    }
    if (Test-Path -LiteralPath $templateBundle) {
        [IO.File]::Replace($stagingPath, $templateBundle, [NullString]::Value)
    } else {
        [IO.File]::Move($stagingPath, $templateBundle)
    }
} finally {
    foreach ($temporary in $stagingPath, $stagedArchive, $stagedFuse) {
        if (Test-Path -LiteralPath $temporary) {
            Remove-Item -LiteralPath $temporary
        }
    }
}

Write-Host "Installed ASCII Art and ASCII Text with $($fontNames.Count) banner fonts. Restart Resolve to refresh the Effects Library."
