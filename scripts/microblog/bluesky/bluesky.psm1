# Import shared/common module
$commonModule = Join-Path $PSScriptRoot ".." "Microblog.Common.psm1"
Import-Module $commonModule -Force

# Load Bluesky public functions
$publicPath = Join-Path $PSScriptRoot "public"
$Public = @( Get-ChildItem -Path $publicPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($import in $Public) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
