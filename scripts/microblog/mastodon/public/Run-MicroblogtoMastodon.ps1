function Run-MicroblogtoMastodon {
    $config = Get-MastodonConfiguration

    $raw = Get-Content $config.File -Raw
    $blocks = $raw -split '(?m)^---\s*$'

    for ($i = 1; $i -lt $blocks.Count; $i += 2) {
        $frontmatter = $blocks[$i].Trim()
        $body        = if ($i + 1 -lt $blocks.Count) { $blocks[$i + 1].Trim() } else { "" }

        if (-not $frontmatter) {
            Write-Warning "Invalid entry format near block $i"
            continue
        }

        Process-Entry -Config $config -Frontmatter $frontmatter -Body $body
    }
}
