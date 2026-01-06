function Publish-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )

    if (-not (Test-Path $Path)) {
        Write-Warning "Image file not found: $Path"
        return $null
    }

    $headers = @{ Authorization = "Bearer $Token" }
    $form = @{ file = Get-Item $Path }

    if ($Alt) { $form.description = $Alt }

    $res = Invoke-RestMethod -Uri "https://$Instance/api/v1/media" -Method POST -Headers $headers -Form $form
    return $res.id
}
