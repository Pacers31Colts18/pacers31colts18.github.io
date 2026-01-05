$publicPath  = Join-Path $PSScriptRoot "common/public"
$privatePath = Join-Path $PSScriptRoot "common/private"

# Load all shared public + private functions
$Public  = @( Get-ChildItem -Path $publicPath  -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $privatePath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import shared function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
