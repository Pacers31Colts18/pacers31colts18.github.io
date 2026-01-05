function Get-BlueskyConfiguration {
    param()

    $config = [ordered]@{
        Handle     = $env:BLUESKY_HANDLE
        AppPassword = $env:BLUESKY_APP_PASSWORD
        File       = "microblog/index.md"
        Endpoint   = "https://bsky.social"
    }

    foreach ($key in $config.Keys) {
        if (-not $config[$key]) {
            throw "Missing required Bluesky configuration value: $key"
        }
    }

    return $config
}
