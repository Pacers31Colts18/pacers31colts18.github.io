# Load required modules
$requiredModules = @("common")

foreach ($module in $requiredModules) {
    try {
        Import-Module -Name $module -Force -ErrorAction Stop
        Write-Host "Loaded required module: $module"
    }
    catch {
        Write-Error "Unable to load required module: $module"
        throw
    }
}

# Load Bluesky functions
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
