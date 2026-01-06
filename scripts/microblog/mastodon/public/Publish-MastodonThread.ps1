function Publish-MastodonThread {
    param (
        [string]$Instance,
        [string]$Token,
        [string[]]$Posts,
        [string]$Visibility,
        [string[]]$MediaIds
    )

    $headers = @{ Authorization = "Bearer $Token" }
    $replyTo = $null

    foreach ($post in $Posts) {
        $payload = @{
            status     = $post
            visibility = $Visibility
        }

        if ($replyTo) {
            $payload.in_reply_to_id = $replyTo
        }
        elseif ($MediaIds.Count -gt 0) {
            $payload.media_ids = $MediaIds
        }

        $res = Invoke-RestMethod -Uri "https://$Instance/api/v1/statuses" -Method POST -Headers $headers -Body ($payload | ConvertTo-Json -Depth 5) -ContentType "application/json"
        $replyTo = $res.id
    }
}
