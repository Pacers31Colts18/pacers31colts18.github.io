function New-BlueskyPost {
    param(
        [Parameter(Mandatory)]
        $Session,

        [Parameter(Mandatory)]
        [string] $Text,

        [Parameter()]
        $Embed
    )

    $record = @{
        text      = $Text
        createdAt = (Get-Date).ToString("o")
    }

    # Ensure embed is valid and includes a $type discriminator
    if ($Embed) {

        # If this is an image embed, enforce the correct Bluesky structure
        if ($Embed.images) {
            $record.embed = @{
                '$type' = 'app.bsky.embed.images'
                images  = $Embed.images
            }
        }
        else {
            # Generic embed passthrough (must already contain $type)
            $record.embed = $Embed
        }
    }

    $body = @{
        repo       = $Session.did
        collection = "app.bsky.feed.post"
        record     = $record
    }

    $response = Invoke-RestMethod -Method Post `
        -Uri "$($Session.endpoint)/xrpc/com.atproto.repo.createRecord" `
        -Headers @{ Authorization = "Bearer $($Session.accessJwt)" } `
        -Body ($body | ConvertTo-Json -Depth 10) `
        -ContentType "application/json"

    return $response
}
