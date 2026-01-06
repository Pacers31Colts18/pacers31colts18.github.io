function Get-MastodonConfiguration {
    $config = [ordered]@{
        Instance = $env:MASTODON_INSTANCE
        Token    = $env:MASTODON_TOKEN
        File     = "microblog/index.md"
        MaxChars = 500
        MaxMedia = 4
        Pat      = $env:GH_PAT
    }

    if (-not $config.Instance -or -not $config.Token) {
        Write-Error "Missing Mastodon configuration"
        exit
    }

    if (-not (Test-Path $config.File)) {
        Write-Error "Microblog file not found: $($config.File)"
        exit
    }

    return $config
}
