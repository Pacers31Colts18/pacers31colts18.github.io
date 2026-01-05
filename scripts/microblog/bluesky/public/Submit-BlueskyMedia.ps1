function Submit-BlueskyMedia {
    param(
        [Parameter(Mandatory)]
        $Session,
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path $Path)) {
        Write-Warning "Media file not found: $Path"
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)

    $response = Invoke-RestMethod -Method Post `
        -Uri "$($Session.endpoint)/xrpc/com.atproto.repo.uploadBlob"
        -Headers @{
            Authorization = "Bearer $($Session.accessJwt)"
            "Content-Type" = "image/jpeg"
        } `
        -Body $bytes

    return $response.blob
}
