function Analyze-Frontmatter {
    param ([string]$Frontmatter)

    $result = [ordered]@{
        id         = $null
        visibility = "public"
        thread     = $true
        images     = @()
        alt        = @()
    }

    $section = $null

    foreach ($line in $Frontmatter -split "`n") {
        $line = $line.Trim()

        if ($line -match '^id:\s*(.+)$') { $result.id = $matches[1].Trim(); continue }
        if ($line -match '^visibility:\s*(.+)$') { $result.visibility = $matches[1].Trim(); continue }
        if ($line -match '^thread:\s*(.+)$') { $result.thread = ($matches[1].Trim().ToLower() -eq "true"); continue }

        if ($line -eq "images:") { $section = "images"; continue }
        if ($line -eq "alt:")    { $section = "alt"; continue }

        if ($line -match '^- (.+)$') {
            if ($section -eq "images") { $result.images += $matches[1].Trim() }
            if ($section -eq "alt")    { $result.alt    += $matches[1].Trim() }
        }
    }

    return $result
}
