$ErrorActionPreference = "Stop"

# region Config
$Instance = $env:MASTODON_INSTANCE
$Token    = $env:MASTODON_TOKEN
$File     = "microblog/microblog.md"
$MaxChars = 500
$MaxMedia = 4

if (-not $Instance -or -not $Token) {
    Write-Error "Missing Mastodon configuration"
    exit
}

if (-not (Test-Path $File)) {
    Write-Error "Microblog file not found: $File"
    exit
}
#endregion 

# region Helper Functions
function Split-Post {
  param ([string]$Text)

  $chunks = @()
  $current = ""

  foreach ($para in $Text -split "`n`n") {
    if (($current.Length + $para.Length + 2) -gt $MaxChars) {
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

function Upload-Media {
  param ($Path, $Alt)

  $headers = @{ Authorization = "Bearer $Token" }

  $form = @{ file = Get-Item $Path }
  if ($Alt) { $form.description = $Alt }

  $res = Invoke-RestMethod `
    -Uri "https://$Instance/api/v1/media" -Method POST -Headers $headers -Form $form

  return $res.id
}

function Tag-Exists($Id) {
  git tag --list "microblog/$Id" | Where-Object { $_ }
}

#endregion

# Load & split entries
$raw = Get-Content $File -Raw

$entries = $raw -split '(?m)^---\s*$' | Where-Object { $_.Trim() }

foreach ($entry in $entries) {

  if ($entry -notmatch '(?s)^(.+?)\n\n(.*)$') {
    Write-Error "Invalid entry format"
    exit
  }

  $frontmatter = $matches[1]
  $body        = $matches[2].Trim()

  # Defaults
  $id = $null
  $visibility = "public"
  $thread = $true
  $images = @()
  $alt = @()
  $section = $null

  foreach ($line in $frontmatter -split "`n") {
    $line = $line.Trim()

    if ($line -match '^id:\s*(.+)$') {
      $id = $matches[1].Trim()
      continue
    }

    if ($line -match '^visibility:\s*(.+)$') {
      $visibility = $matches[1].Trim()
      continue
    }

    if ($line -match '^thread:\s*(.+)$') {
      $thread = $matches[1].Trim().ToLower() -eq "true"
      continue
    }

    if ($line -eq "images:") { $section = "images"; continue }
    if ($line -eq "alt:")    { $section = "alt"; continue }

    if ($line -match '^- (.+)$') {
      if ($section -eq "images") { $images += $matches[1].Trim() }
      if ($section -eq "alt")    { $alt    += $matches[1].Trim() }
    }
  }

  if (-not $id) {
    throw "Post missing id"
  }

  if (Tag-Exists $id) {
    Write-Output "Skipping already-posted entry: $id"
    continue
  }

  Write-Output "Posting entry: $id"

  if ($images.Count -gt $MaxMedia) {
    Write-Error "Too many images in $id (max $MaxMedia)"
    exit
  }

  # Upload images
  $mediaIds = @()
  for ($i = 0; $i -lt $images.Count; $i++) {
    $mediaIds += Upload-Media $images[$i] ($alt[$i])
  }

  # Split post
  $posts = if ($thread) {
    Split-Post $body
  } else {
    @($body.Substring(0, [Math]::Min($MaxChars, $body.Length)))
  }

  # Publish
  $headers = @{ Authorization = "Bearer $Token" }
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

    $res = Invoke-RestMethod -Uri "https://$Instance/api/v1/statuses" -Method POST -Headers $headers -Body ($payload | ConvertTo-Json -Depth 5) -ContentType "application/json"

    $replyTo = $res.id
  }

  # Tag after success
  git tag "microblog/$id"
  git push origin "microblog/$id"

  Write-Host "Posted and tagged: $id"
}
