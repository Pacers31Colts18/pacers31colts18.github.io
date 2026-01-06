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

    # Analyze frontmatter
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

    $postToMastodon = $true
    $postToBluesky  = $true

    if ($meta.Keys -contains "mastodon") {
        $postToMastodon = [System.Convert]::ToBoolean($meta["mastodon"])
    }
    
    if ($meta.Keys -contains "bluesky") {
        $postToBluesky = [System.Convert]::ToBoolean($meta["bluesky"])
    }
    
    if ($Platform -eq "mastodon" -and -not $postToMastodon) {
        Write-Host "Skipping Mastodon for this entry."
        return
    }
    
    if ($Platform -eq "bluesky" -and -not $postToBluesky) {
        Write-Host "Skipping Bluesky for this entry."
        return
    }



    # Validate image count
    if ($meta.images.Count -gt $Config.MaxMedia) {
        Write-Error "Too many images in $($meta.id) (max $($Config.MaxMedia))"
        exit
    }

    # Upload media (platform-specific)
    $mediaIds = @()

    for ($i = 0; $i -lt $meta.images.Count; $i++) {

        $path = $meta.images[$i]
        $alt  = $meta.alt[$i]

        if ($Platform -eq "mastodon") {
            $mediaIds += Publish-MastodonMedia -Instance $Config.Instance -Token $Config.Token -Path $path -Alt $alt
        }

        if ($Platform -eq "bluesky") {
            $mediaIds += Publish-BlueskyMedia -Session $Session -Path $path
        }
    }

    # Split into threads
    $posts = if ($meta.thread) {
        Split-Post -Text $Body -MaxChars $Config.MaxChars
    } else {
        @($Body.Substring(0, [Math]::Min($Config.MaxChars, $Body.Length)))
    }

    # Publish (platform-specific)
    if ($Platform -eq "mastodon") {
        Publish-MastodonThread -Instance $Config.Instance -Token $Config.Token -Posts $posts -Visibility $meta.visibility -MediaIds $mediaIds
    }

    if ($Platform -eq "bluesky") {
        Publish-BlueskyThread -Session $Session -Posts $posts -Media $mediaIds[0]   # Bluesky only supports 1 image per post currently
    }

    # Tag after success
    git tag "microblog/$($meta.id)"
    git push "https://$($Config.Pat)$GitPath" "microblog/$($meta.id)" --force

    Write-Output "Posted to $Platform successfully, ID: $($meta.id)"
}
