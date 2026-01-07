function Publish-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )

    # If the path is relative and starts with "images/", prepend microblog/
    if ($Path -match '^[./]*images/') {
        $Path = "microblog/$Path"
    }


    Write-Output "=== MASTODON MEDIA UPLOAD DEBUG START ==="
    Write-Output "Original Path: $Path"

    # If the path is relative, resolve it to the repo root
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        # Repo root = three levels up from this script
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
        $resolved = Join-Path $repoRoot $Path

        Write-Output "Resolved relative path to: $resolved"
        $Path = $resolved
    }

    # Resolve any remaining relative segments
    try {
        $Path = (Resolve-Path $Path).Path
        Write-Output "Final resolved path: $Path"
    }
    catch {
        Write-Warning "Failed to resolve path: $Path"
        return $null
    }

    # Validate the file exists
    if (-not (Test-Path $Path)) {
        Write-Warning "Image file not found after resolution: $Path"
        return $null
    }

    # Validate file size > 0
    $fileInfo = Get-Item $Path
    if ($fileInfo.Length -eq 0) {
        Write-Warning "Image file is empty: $Path"
        return $null
    }

    Write-Output "Uploading file: $Path (Size: $($fileInfo.Length) bytes)"

    # Prepare upload
    $headers = @{ Authorization = "Bearer $Token" }
    $form = @{ file = $fileInfo }

    if ($Alt) { 
        Write-Output "Using alt text: $Alt"
        $form.description = $Alt 
    }

    # Upload to Mastodon
    try {
        $res = Invoke-RestMethod `
            -Uri "https://$Instance/api/v1/media" `
            -Method POST `
            -Headers $headers `
            -Form $form

        Write-Output "Upload successful. Media ID: $($res.id)"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $res.id
    }
    catch {
        Write-Error "Mastodon upload failed: $_"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }
}
