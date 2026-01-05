function Process-Entry {
    param (
        $Config,
        [string]$Frontmatter,
        [string]$Body,
        [string]$GitPath = "@github.com/Pacers31Colts18/pacers31colts18.github.io.git"
    )

    $meta = Parse-Frontmatter $Frontmatter

    if (-not $meta.id) {
        Write-Error "Post missing id"
        exit
    }

    if (Check-GitTag $meta.id) {
        Write-Output "Skipping already-posted entry: $($meta.id)"
        return
    }

    Write-Host "Posting entry: $($meta.id)"

    if ($meta.images.Count -gt $Config.MaxMedia) {
        Write-Error "Too many images in $($meta.id) (max $($Config.MaxMedia))"
        exit
    }

    # Upload media
    $mediaIds = @()
    for ($i = 0; $i -lt $meta.images.Count; $i++) {
        $mediaIds += Upload-MastodonMedia -Instance $Config.Instance -Token $Config.Token -Path $meta.images[$i] -Alt $meta.alt[$i]
    }

    # Split into threads
    $posts = if ($meta.thread) {
        Split-Post -Text $Body -MaxChars $Config.MaxChars
    } else {
        @($Body.Substring(0, [Math]::Min($Config.MaxChars, $Body.Length)))
    }

    # Publish
    Post-MastodonThread -Instance $Config.Instance -Token $Config.Token -Posts $posts -Visibility $meta.visibility -MediaIds $mediaIds

    # Tag after success
    git tag "microblog/$($meta.id)"
    git push "https://$($Config.Pat)$GitPath" "microblog/$($meta.id)" --force
    Write-Output "Posted to Mastodon successfully, ID: $($meta.id)"
}
