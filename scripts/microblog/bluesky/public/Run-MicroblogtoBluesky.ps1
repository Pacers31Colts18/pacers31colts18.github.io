function Run-MicroblogToBluesky {

    $config = Get-BlueskyConfiguration

    # Authenticate Bluesky session
    $session = Invoke-RestMethod -Method Post -Uri "$($config.Endpoint)/xrpc/com.atproto.server.createSession" -Body @{
            identifier = $config.Handle
            password   = $config.AppPassword
        }

    $session | Add-Member -NotePropertyName endpoint -NotePropertyValue $config.Endpoint

    $raw = Get-Content $config.File -Raw
    $blocks = $raw -split '(?m)^---\s*$'

    for ($i = 1; $i -lt $blocks.Count; $i += 2) {

        $frontmatter = $blocks[$i].Trim()
        $body        = if ($i + 1 -lt $blocks.Count) { 
            $blocks[$i + 1].Trim() 
        } else { 
            "" 
        }

        if (-not $frontmatter) {
            Write-Warning "Invalid entry format near block $i"
        }

        Process-Entry -Platform "bluesky" -Session $session -Config $config -Frontmatter $frontmatter -Body $body
    }
}
