function Parse-MarkdownImages {
    param([string]$Body)

    # Normalize line endings and trim each line
    $Body = $Body.Replace("`r", "")
    $Body = ($Body -split "`n" | ForEach-Object { $_.Trim() }) -join "`n"

    # Flexible Markdown image regex: ![alt](path)
    $imgRegex = '!\s*

\[(.*?)\]

\s*\((.*?)\)'

    $images = @()
    $alts   = @()

    $cleanBody = $Body

    foreach ($match in [regex]::Matches($Body, $imgRegex)) {
        $alt  = $match.Groups[1].Value.Trim()
        $path = $match.Groups[2].Value.Trim()

        $alts   += $alt
        $images += $path

        $cleanBody = $cleanBody.Replace($match.Value, "")
    }

    return [ordered]@{
        Images    = $images
        Alts      = $alts
        CleanBody = $cleanBody.Trim()
    }
}
