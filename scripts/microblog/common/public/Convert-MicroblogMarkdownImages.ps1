function Convert-MicroblogMarkdownImages {
    param([string]$Body)

    Write-Output "=== IMAGE PARSER DEBUG START ==="

    # Normalize CRLF → LF
    $Body = $Body.Replace("`r", "")

    # Remove invisible Unicode characters from entire body
    $Body = $Body -replace '[\u200B-\u200D\uFEFF\u00A0]', ''

    # Trim each line to remove indentation GitHub sometimes adds
    $lines = $Body -split "`n"
    $lines = $lines | ForEach-Object { $_.Trim() }
    $Body = ($lines -join "`n")

    Write-Output "Normalized Body:"
    Write-Output $Body

    # Single-line regex
    $imgRegex = '!\s*\[(.*?)\]\s*\((.*?)\)'
    Write-Output "Using regex: $imgRegex"

    $images = @()
    $alts   = @()
    $cleanBody = $Body

    $matches = [regex]::Matches($Body, $imgRegex)
    Write-Output "Matches found: $($matches.Count)"

    foreach ($match in $matches) {

        # Raw extracted values
        $rawAlt  = $match.Groups[1].Value
        $rawPath = $match.Groups[2].Value

        Write-Output " - RAW ALT:  '$rawAlt'"
        Write-Output " - RAW PATH: '$rawPath'"

        # Clean invisible characters from path explicitly
        $cleanPath = $rawPath -replace '[\u200B-\u200D\uFEFF\u00A0]', ''
        $cleanPath = $cleanPath.Trim()

        # Show character codes for debugging
        $charCodes = ([int[]][char[]]$cleanPath) -join ", "
        Write-Output " - CLEAN PATH: '$cleanPath'"
        Write-Output " - CLEAN PATH CHAR CODES: $charCodes"

        # Clean alt text too
        $cleanAlt = $rawAlt -replace '[\u200B-\u200D\uFEFF\u00A0]', ''
        $cleanAlt = $cleanAlt.Trim()

        $alts   += $cleanAlt
        $images += $cleanPath

        # Remove the markdown from the body
        $cleanBody = $cleanBody.Replace($match.Value, "")
    }

    Write-Output "=== IMAGE PARSER DEBUG END ==="

    return [ordered]@{
        Images    = $images
        Alts      = $alts
        CleanBody = $cleanBody.Trim()
    }
}
