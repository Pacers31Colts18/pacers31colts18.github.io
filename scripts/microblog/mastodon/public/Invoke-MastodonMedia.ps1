Write-Output ">>> USING Invoke-MastodonMedia FROM: $PSCommandPath"

function Invoke-MastodonMedia {
    param (
        [string]$Instance,
        [string]$Token,
        [string]$Path,
        [string]$Alt
    )

    Write-Output "=== MASTODON MEDIA UPLOAD DEBUG START ==="
    Write-Output "Raw incoming Path: '$Path'"

    # Normalize invisible characters
    $Path = ($Path -replace '[\u0000-\u001F\u200B-\u200D\uFEFF\u00A0]', '').Trim()
    Write-Output "Normalized Path: '$Path'"

    # Early validation
    if (-not $Path -or $Path.Trim().Length -eq 0) {
        Write-Output ">>> ERROR: Uploader received EMPTY PATH"
        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    # Show repo root
    $repoRoot = $env:GITHUB_WORKSPACE
    Write-Output "Repo root: $repoRoot"

    # Show expected full path
    $expected = Join-Path $repoRoot $Path
    Write-Output "Expected full path: $expected"

    # Try resolving the path
    try {
        $resolved = Resolve-Path $expected -ErrorAction Stop
        $Path = $resolved.Path
        Write-Output "Resolved path: $Path"
    }
    catch {
        Write-Warning "Resolve-Path failed for: $expected"
        Write-Output "Directory listing of repo root:"
        Get-ChildItem -Recurse $repoRoot | Write-Output

        Write-Output "=== MASTODON MEDIA UPLOAD DEBUG END ==="
        return $null
    }

    # Validate file exists
    if (-not (Test-Path $Path)) {
        Write-Warning "File does not exist after resolution: $Path"
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
