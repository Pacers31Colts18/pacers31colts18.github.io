#Load based on PS Version
foreach ($module in $requiredModules) {
    try {
        Import-Module -Name $module -Force -ErrorAction SilentlyContinue
     } 
     Catch {
        Write-Error "Unable to load $module" 
    }
}

# Corrected paths
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
