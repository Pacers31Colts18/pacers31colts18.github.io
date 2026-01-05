function Get-MastodonConfiguration {
    $config = [ordered]@{
        Instance = $env:MASTODON_INSTANCE
        Token    = $env:MASTODON_TOKEN
        File     = "microblog/microblog.md"
        MaxChars = 500
        MaxMedia = 4
        Pat      = $env:GH_PAT
    }

    if (-not $config.Instance -or -not $config.Token) {
        throw "Missing Mastodon configuration"
    }

    if (-not (Test-Path $config.File)) {
        throw "Microblog file not found: $($config.File)"
    }

    return $config
}
