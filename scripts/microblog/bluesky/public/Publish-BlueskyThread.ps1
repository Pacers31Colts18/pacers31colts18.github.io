function Publish-BlueskyThread {
    param(
        [Parameter(Mandatory)]
        $Session,

        [Parameter(Mandatory)]
        [string[]] $Posts,

        [Parameter()]
        $Media
    )

    $previous = $null
    $results = @()

    foreach ($post in $Posts) {

        $embed = $null

        if ($Media) {
            $embed = @{
                images = @(
                    @{
                        image = $Media
                        alt   = "Image"
                    }
                )
                "$type" = "app.bsky.embed.images"
            }
        }

        if ($previous) {
            $embed = $embed ?? @{}
            $record = @{
                text      = $post
                createdAt = (Get-Date).ToString("o")
                reply     = @{
                    root = $previous
                    parent = $previous
                }
            }
        }

        $response = New-BlueskyPost -Session $Session -Text $post -Embed $embed
        $previous = $response.uri

        $results += $response
    }

    return $results
}
