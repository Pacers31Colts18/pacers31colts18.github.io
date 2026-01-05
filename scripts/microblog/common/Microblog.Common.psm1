# Load common functions
$publicPath  = Join-Path $PSScriptRoot "public"
$privatePath = Join-Path $PSScriptRoot "private"

$Public  = @( Get-ChildItem -Path $publicPath  -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $privatePath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
        throw
    }
}

# Export only public functions
Export-ModuleMember -Function $Public.BaseName
