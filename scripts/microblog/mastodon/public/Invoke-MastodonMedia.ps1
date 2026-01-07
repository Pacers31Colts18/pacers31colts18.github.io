Write-Output ">>> USING Invoke-MastodonMedia FROM: $PSCommandPath"

function Invoke-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )

    # Early validation
    if (-not $Path -or $Path.Trim().Length -eq 0) {
        Write-Output ">>> ERROR: Uploader received EMPTY PATH"
        return $null
    }

    Write-Output "=== MASTODON MEDIA UPLOAD DEBUG START ==="
    Write-Output "Original Path from New-Entry: '$Path'"

    # Resolve relative paths
    $repoRoot = $env:GITHUB_WORKSPACE
    Write-Output "Repo root: $repoRoot"

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $repoRoot $Path
        Write-Output "Resolved relative path → $Path"
    }

    try {
        $Path = (Resolve-Path $Path).Path
        Write-Output "Final resolved path: $Path"
    }
    catch {
        Write-Warning "Failed to resolve path: $Path"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    if (-not (Test-Path $Path)) {
        Write-Warning "Image file not found: $Path"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    $fileInfo = Get-Item $Path

    if ($fileInfo.Length -eq 0) {
        Write-Warning "Image file is empty: $Path"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    Write-Output "Uploading file: $Path (Size: $($fileInfo.Length) bytes)"

    $headers = @{ Authorization = "Bearer $Token" }
    $form = @{ file = $fileInfo }

    if ($Alt) {
        Write-Output "Using alt text: $Alt"
        $form.description = $Alt
    }

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
