function Publish-BlueskyMedia {
    param(
        [Parameter(Mandatory)]
        $Session,

        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Media file not found: $Path"
        exit
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)

    $response = Invoke-RestMethod -Method Post `
        -Uri "$($Session.endpoint)/xrpc/com.atproto.repo.uploadBlob?encoding=image/jpeg" `
        -Headers @{
            Authorization = "Bearer $($Session.accessJwt)"
        } `
        -Body $bytes

    return $response.blob
}
