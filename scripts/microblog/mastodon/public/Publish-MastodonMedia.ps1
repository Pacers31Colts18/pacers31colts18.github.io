    Write-Output ">>> USING Publish-MastodonMedia FROM: $PSCommandPath"

function Publish-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )


    Write-Output "=== MASTODON MEDIA UPLOAD DEBUG START ==="
    Write-Output "Original Path from parser: $Path"

    # ------------------------------------------------------------
    # 1. Normalize Markdown paths so GitHub preview AND Mastodon work
    # ------------------------------------------------------------

    # If Markdown uses "images/foo.jpg", prepend "microblog/"
    if ($Path -match '^[./]*images/') {
        $Path = "microblog/$Path"
        Write-Output "Rewritten Markdown path → $Path"
    }

    # ------------------------------------------------------------
    # 2. Resolve relative paths against the repo root
    # ------------------------------------------------------------

    $repoRoot = $env:GITHUB_WORKSPACE

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $repoRoot $Path
        Write-Output "Resolved relative path → $Path"
    }

    # ------------------------------------------------------------
    # 3. Resolve final absolute path
    # ------------------------------------------------------------

    try {
        $Path = (Resolve-Path $Path).Path
        Write-Output "Final resolved path: $Path"
    }
    catch {
        Write-Warning "Failed to resolve path: $Path"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    # ------------------------------------------------------------
    # 4. Validate file exists and is non-empty
    # ------------------------------------------------------------

    if (-not (Test-Path $Path)) {
        Write-Warning "Image file not found after resolution: $Path"
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

    # ------------------------------------------------------------
    # 5. Prepare upload
    # ------------------------------------------------------------

    $headers = @{ Authorization = "Bearer $Token" }
    $form = @{ file = $fileInfo }

    if ($Alt) {
        Write-Output "Using alt text: $Alt"
        $form.description = $Alt
    }

    # ------------------------------------------------------------
    # 6. Upload to Mastodon
    # ------------------------------------------------------------

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
