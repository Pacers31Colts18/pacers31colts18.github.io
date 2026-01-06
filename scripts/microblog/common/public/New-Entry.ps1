function New-Entry {
    param (
        $Config,
        $Session,
        
        [Parameter(Mandatory)]
        [ValidateSet("mastodon", "bluesky")]
        [string]$Platform,
        
        [string]$Frontmatter,
        [string]$Body,
        [string]$GitPath = "@github.com/Pacers31Colts18/pacers31colts18.github.io.git"
    )

    # Parse frontmatter
    $meta = Convert-Frontmatter $Frontmatter

    if (-not $meta.id) {
        Write-Error "Post missing id"
        exit
    }

    # Skip if already posted
    if (Test-GitTag $meta.id) {
        Write-Output "Skipping already-posted entry: $($meta.id)"
        return
    }

    Write-Output "Posting entry: $($meta.id)"

    # Determine platform based on frontmatter
    $postToMastodon = $false
    $postToBluesky  = $false

    switch ($meta.platform) {
        "mastodon" { $postToMastodon = $true }
        "bluesky"  { $postToBluesky  = $true }
        "all"      { $postToMastodon = $true; $postToBluesky = $true }
        default {
            Write-Warning "Unknown platform '$($meta.platform)', defaulting to 'all'"
            $postToMastodon = $true
            $postToBluesky  = $true
        }
    }

    # Respect workflow-level platform selection
    if ($Platform -eq "mastodon" -and -not $postToMastodon) {
        Write-Output "Skipping Mastodon for this entry (frontmatter says platform=$($meta.platform))."
        return
    }

    if ($Platform -eq "bluesky" -and -not $postToBluesky) {
        Write-Output "Skipping Bluesky for this entry (frontmatter says platform=$($meta.platform))."
        return
    }

    # Extract images + alt text from Markdown body
    $parsed = Parse-MarkdownImages -Body $Body
    $images = $parsed.Images
    $alts   = $parsed.Alts
    $cleanBody = $parsed.CleanBody

    # Auto-detect content type
    $hasText  = ($cleanBody.Trim().Length -gt 0)
    $hasMedia = ($images.Count -gt 0)

    Write-Output "Content detection: text=$hasText, media=$hasMedia"

    # Validate image count
    if ($images.Count -gt $Config.MaxMedia) {
        Write-Error "Too many images in $($meta.id) (max $($Config.MaxMedia))"
        exit
    }

    # Upload media (platform-specific)
    $mediaIds = @()

    for ($i = 0; $i -lt $images.Count; $i++) {
        $path = $images[$i]
        $alt  = $alts[$i]

        if ($Platform -eq "mastodon") {
            $mediaIds += Publish-MastodonMedia -Instance $Config.Instance -Token $Config.Token -Path $path -Alt $alt
        }

        if ($Platform -eq "bluesky") {
            $mediaIds += Publish-BlueskyMedia -Session $Session -Path $path
        }
    }

    # Build posts (threading)
    $posts = if ($meta.thread -and $hasText) {
        Split-Post -Text $cleanBody -MaxChars $Config.MaxChars
    }
    elseif ($hasText) {
        @($cleanBody.Substring(0, [Math]::Min($Config.MaxChars, $cleanBody.Length)))
    }
    else {
        @("")
    }

    # Publish (platform-specific)
    if ($Platform -eq "mastodon") {
        Publish-MastodonThread -Instance $Config.Instance -Token $Config.Token -Posts $posts -Visibility $meta.visibility -MediaIds $mediaIds
    }

    if ($Platform -eq "bluesky") {
        Publish-BlueskyThread -Session $Session -Posts $posts -Media $mediaIds[0]
    }

    # Tag after success
    git tag "microblog/$($meta.id)"
    git push "https://$($Config.Pat)$GitPath" "microblog/$($meta.id)" --force

    Write-Output "Posted to $Platform successfully, ID: $($meta.id)"
}
