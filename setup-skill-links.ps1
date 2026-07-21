param([switch]$Remove)

$skillsDir = "$env:USERPROFILE\.config\opencode\skills"
$projectSkills = @{
    "meeting-protocol" = "Common\Meeting-protocol"
}

if ($Remove) {
    foreach ($name in $projectSkills.Keys) {
        $link = Join-Path $skillsDir $name
        if (Test-Path $link) {
            Remove-Item -LiteralPath $link -Recurse -Force
            Write-Host "Removed: $link"
        }
    }
    return
}

# Ensure skills dir exists
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null

$repoRoot = $PSScriptRoot

foreach ($name in $projectSkills.Keys) {
    $link = Join-Path $skillsDir $name
    $target = Join-Path $repoRoot $projectSkills[$name]

    if (Test-Path $link) {
        $item = Get-Item $link
        if ($item.LinkType -eq 'Junction' -and $item.Target -eq $target) {
            Write-Host "Already linked: $name"
            continue
        }
        Write-Host "Replacing: $name"
        Remove-Item -LiteralPath $link -Recurse -Force
    }

    cmd /c mklink /J "$link" "$target" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Created junction: $link -> $target"
    } else {
        Write-Host "ERROR: Failed to create junction for $name"
    }
}