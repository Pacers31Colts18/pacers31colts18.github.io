#Load based on PS Version
foreach ($module in $requiredModules) {
    try {
        Import-Module -Name $module -Force -ErrorAction SilentlyContinue
     } 
     Catch {
        Write-Error "Unable to load $module" 
    }
 }

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename
