# Load required common module
$commonPath = Join-Path $PSScriptRoot ".." "common/common.psm1"

if (-not (Test-Path $commonPath)) {
    Write-Error "Common module not found at: $commonPath"
    exit
}

try {
    Import-Module $commonPath -Force -Verbose
    Write-Host "Loaded common module from: $commonPath"
}
catch {
    Write-Error "Failed to load common module: $_"
    exit
}

# Load public/private functions
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
        exit
    }
}

# Export only public functions
Export-ModuleMember -Function $Public.BaseName
