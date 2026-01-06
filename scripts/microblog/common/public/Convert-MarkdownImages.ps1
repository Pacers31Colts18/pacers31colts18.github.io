function Convert-MarkdownImages {
    param([string]$Body)

    Write-Output "=== IMAGE PARSER DEBUG START ==="

    # Normalize CRLF → LF
    $Body = $Body.Replace("`r", "")

    # Trim each line to remove indentation GitHub sometimes adds
    $lines = $Body -split "`n"
    $lines = $lines | ForEach-Object { $_.Trim() }
    $Body = ($lines -join "`n")

    Write-Output "Normalized Body:"
    Write-Output $Body

    # Flexible Markdown image regex: ![alt](path)
    $imgRegex = '!\s*

\[(.*?)\]

\s*\((.*?)\)'

    Write-Output "Using regex: $imgRegex"

    $images = @()
    $alts   = @()

    $cleanBody = $Body

    $matches = [regex]::Matches($Body, $imgRegex)

    Write-Output "Matches found: $($matches.Count)"

    foreach ($match in $matches) {
        $alt  = $match.Groups[1].Value.Trim()
        $path = $match.Groups[2].Value.Trim()

        Write-Output " - MATCH: alt='$alt' path='$path'"

        $alts   += $alt
        $images += $path

        # Remove the image markdown from the body text
        $cleanBody = $cleanBody.Replace($match.Value, "")
    }

    Write-Output "=== IMAGE PARSER DEBUG END ==="

    return [ordered]@{
        Images    = $images
        Alts      = $alts
        CleanBody = $cleanBody.Trim()
    }
}
