function Convert-Frontmatter {
    param ([string]$Frontmatter)

    # Default values
    $result = [ordered]@{
        id         = $null
        visibility = "public"
        thread     = $true
        platform   = "all"
    }

    foreach ($line in $Frontmatter -split "`n") {
        $line = $line.Trim()
        if (-not $line) { continue }

        # id
        if ($line -match '^id:\s*(.+)$') {
            $result.id = $matches[1].Trim()
            continue
        }

        # visibility
        if ($line -match '^visibility:\s*(.+)$') {
            $result.visibility = $matches[1].Trim()
            continue
        }

        # thread (boolean)
        if ($line -match '^thread:\s*(.+)$') {
            $value = $matches[1].Trim()
            $result.thread = [System.Convert]::ToBoolean($value)
            continue
        }

        # platform (mastodon | bluesky | all)
        if ($line -match '^platform:\s*(.+)$') {
            $value = $matches[1].Trim().ToLower()
            $result.platform = $value
            continue
        }
    }

    return $result
}
