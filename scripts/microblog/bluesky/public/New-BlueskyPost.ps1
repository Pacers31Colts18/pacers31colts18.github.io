function New-BlueskyPost {
    param(
        [Parameter(Mandatory)]
        $Session,

        [Parameter(Mandatory)]
        [string] $Text,

        [Parameter()]
        $Embed
    )

    # Build hashtags
    $facets = @()
    $regex = [regex]'#([A-Za-z0-9_]+)'

    foreach ($match in $regex.Matches($Text)) {
        $tag = $match.Groups[1].Value

        $before = $Text.Substring(0, $match.Index)
        $start  = [System.Text.Encoding]::UTF8.GetByteCount($before)
        $length = [System.Text.Encoding]::UTF8.GetByteCount($match.Value)
        $end    = $start + $length

        $facets += @{
            index = @{
                byteStart = $start
                byteEnd   = $end
            }
            features = @(
                @{
                    '$type' = 'app.bsky.richtext.facet#tag'
                    tag     = $tag
                }
            )
        }
    }

    # Build the post record
    $record = @{
        text      = $Text
        createdAt = (Get-Date).ToString("o")
    }

    if ($facets.Count -gt 0) {
        $record.facets = $facets
    }

    # Embed handling (images, etc.)
    if ($Embed) {
        if ($Embed.images) {
            # Ensure proper Bluesky embed structure
            $record.embed = @{
                '$type' = 'app.bsky.embed.images'
                images  = $Embed.images
            }
        }
        else {
            # Generic embed passthrough
            $record.embed = $Embed
        }
    }

    # Build the createRecord request
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
