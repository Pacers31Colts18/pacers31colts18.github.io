$ErrorActionPreference = "Stop"

# region Configuration
$Instance = $env:MASTODON_INSTANCE
$Token    = $env:MASTODON_TOKEN
$MaxChars = 500
$MaxMedia = 4

if (-not $Instance -or -not $Token) {
  throw "MASTODON_INSTANCE or MASTODON_TOKEN is missing"
}

#endregion

# region Helper Functions
function Split-Post {
  param (
    [string]$Text,
    [int]$Limit
  )

  $chunks = @()
  $current = ""

  foreach ($para in $Text -split "`n`n") {
    if (($current.Length + $para.Length + 2) -gt $Limit) {
      if ($current.Trim()) {
        $chunks += $current.Trim()
        $current = ""
      }
    }
    $current += "$para`n`n"
  }

  if ($current.Trim()) {
    $chunks += $current.Trim()
  }

  return $chunks
}

function Upload-MastodonMedia {
  param (
    [string]$FilePath,
    [string]$AltText
  )

  if (-not (Test-Path $FilePath)) {
    throw "Image not found: $FilePath"
  }

  $headers = @{
    Authorization = "Bearer $Token"
  }

  $form = @{
    file = Get-Item $FilePath
  }

  if ($AltText) {
    $form.description = $AltText
  }

  $response = Invoke-RestMethod -Uri "https://$Instance/api/v1/media" -Method POST -Headers $headers -Form $form

  return $response.id
}
#endregion

# Detect newly added microblog files
$files = git diff --name-status HEAD~1 HEAD |
  Where-Object { $_ -match '^A\s+microblog/.*\.md$' } |
  ForEach-Object { $_.Split("`t")[1] }

if (-not $files) {
  Write-Host "No new microblog posts detected"
  exit 0
}

# Process each new post
foreach ($file in $files) {
  Write-Host "Processing $file"

  $raw = Get-Content $file -Raw

if ($raw -notmatch '(?s)^---(.*?)---\s*(.*)$') {
    throw "Invalid or missing frontmatter in $file"
  }

  $frontmatterText = $matches[1]
  $body            = $matches[2].Trim()

  # Defaults
  $visibility = "public"
  $thread     = $true
  $images     = @()
  $altText    = @()

  $currentSection = $null

  foreach ($line in $frontmatterText -split "`n") {
    $line = $line.Trim()

    if ($line -match '^visibility:\s*(.+)$') {
      $visibility = $matches[1].Trim()
      continue
    }

    if ($line -match '^thread:\s*(.+)$') {
      $thread = $matches[1].Trim().ToLower() -eq "true"
      continue
    }

    if ($line -match '^images:\s*$') {
      $currentSection = "images"
      continue
    }

    if ($line -match '^alt:\s*$') {
      $currentSection = "alt"
      continue
    }

    if ($line -match '^- (.+)$') {
      if ($currentSection -eq "images") {
        $images += $matches[1].Trim()
      }
      elseif ($currentSection -eq "alt") {
        $altText += $matches[1].Trim()
      }
    }
  }

  if ($images.Count -gt $MaxMedia) {
    throw "Mastodon allows max $MaxMedia images per post"
  }

  # Upload images (first post only)
  $mediaIds = @()

  for ($i = 0; $i -lt $images.Count; $i++) {
    $img = $images[$i]
    $alt = if ($i -lt $altText.Count) { $altText[$i] } else { $null }

    Write-Host "Uploading image: $img"
    $mediaIds += Upload-MastodonMedia -FilePath $img -AltText $alt
  }

  # Split post into chunks (for threads)
  $posts = if ($thread) {
    Split-Post -Text $body -Limit $MaxChars
  }
  else {
    @($body.Substring(0, [Math]::Min($MaxChars, $body.Length)))
  }

  # Publish posts
  $headers = @{
    Authorization = "Bearer $Token"
  }

  $replyTo = $null

  foreach ($post in $posts) {
    $payload = @{
      status     = $post
      visibility = $visibility
    }

    if ($replyTo) {
      $payload.in_reply_to_id = $replyTo
    }
    elseif ($mediaIds.Count -gt 0) {
      $payload.media_ids = $mediaIds
    }

    $response = Invoke-RestMethod -Uri "https://$Instance/api/v1/statuses" -Method POST -Headers $headers -Body ($payload | ConvertTo-Json -Depth 5) -ContentType "application/json"

    $replyTo = $response.id
  }

  Write-Output "Posted $file successfully"
}
