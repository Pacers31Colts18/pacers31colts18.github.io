function Get-BlueskyConfiguration {
    param()

    $config = [ordered]@{
        Handle     = $env:BLUESKY_HANDLE
        AppPassword = $env:BLUESKY_APP_PASSWORD
        Endpoint   = "https://bsky.social"
        File     = "microblog/index.md"
        MaxChars = 500
        MaxMedia = 4
        Pat      = $env:GH_PAT
    }

    if (-not $config.Handle -or -not $config.AppPassword) {
        throw "Missing Bluesky configuration"
    }

    if (-not (Test-Path $config.File)) {
        throw "Microblog file not found: $($config.File)"
    }

    return $config
}
