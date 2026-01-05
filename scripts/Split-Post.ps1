function Split-Post {
    param (
        [string]$Text,
        [int]$MaxChars
    )

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

    if ($current.Trim()) { $chunks += $current.Trim() }
    return $chunks
}
