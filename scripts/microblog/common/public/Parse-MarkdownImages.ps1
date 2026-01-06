function Parse-MarkdownImages {
    param([string]$Body)

    # Regex for Markdown images: ![alt](path)
    $imgRegex = '!

\[(.*?)\]

\((.*?)\)'

    $images = @()
    $alts   = @()

    $cleanBody = $Body

    foreach ($match in [regex]::Matches($Body, $imgRegex)) {
        $alt  = $match.Groups[1].Value.Trim()
        $path = $match.Groups[2].Value.Trim()

        $alts   += $alt
        $images += $path

        # Remove the image markdown from the body text
        $cleanBody = $cleanBody.Replace($match.Value, "")
    }

    return [ordered]@{
        Images    = $images
        Alts      = $alts
        CleanBody = $cleanBody.Trim()
    }
}
