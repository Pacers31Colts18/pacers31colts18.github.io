Write-Output ">>> USING Invoke-MastodonMedia FROM: $PSCommandPath"

function Invoke-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )

    # ------------------------------------------------------------
    # 0. Validate incoming path BEFORE anything else
    # ------------------------------------------------------------

    Write-Output ">>> DEBUG: Raw incoming Path = '$Path'"

    if (-not $Path) {
        Write-Output ">>> ERROR: Path is NULL"
        return $null
    }

    if ($Path.Trim().Length -eq 0) {
        Write-Output ">>> ERROR: Path is EMPTY or WHITESPACE"
        return $null
    }

    $charCodes = ([int[]][char[]]$Path) -join ", "
    Write-Output ">>> DEBUG: Path character codes = $charCodes"

    # ------------------------------------------------------------
    # 1. Start uploader debug
    # ------------------------------------------------------------

    Write-Output "=== MASTODON MEDIA UPLOAD DEBUG START ==="
    Write-Output "Original Path from parser: '$Path'"

    # ------------------------------------------------------------
    # 2. Normalize Markdown paths so GitHub preview AND Mastodon work
    # ------------------------------------------------------------

    if ($Path -match '^[./]*images/') {
        $Path = "microblog/$Path"
        Write-Output "Rewritten Markdown path → $Path"
    }

    # ------------------------------------------------------------
    # 3. Resolve relative paths against the repo root
    # ------------------------------------------------------------

    $repoRoot = $env:GITHUB_WORKSPACE
    Write-Output "Repo root: $repoRoot"

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $repoRoot $Path
        Write-Output "Resolved relative path → $Path"
    }

    # ------------------------------------------------------------
    # 4. Resolve final absolute path
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
    # 5. Validate file exists and is non-empty
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
    # 6. Prepare upload
    # ------------------------------------------------------------

    $headers = @{ Authorization = "Bearer $Token" }
    $form = @{ file = $fileInfo }

    if ($Alt) {
        Write-Output "Using alt text: $Alt"
        $form.description = $Alt
    }

    # ------------------------------------------------------------
    # 7. Upload to Mastodon
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
