
@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'mastodon.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'b7c1f7c4-9f3a-4e3e-9c0c-2a7b8d9f1e21'

    # Author of this module
    Author = 'Joe Loveless'

    # Company or vendor of this module
    CompanyName = #

    # Description of the functionality provided by this module
    Description = 'A PowerShell module for posting microblog entries to Mastodon, including media upload, threading, and Git tagging.'

    # Minimum version of the PowerShell engine required
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Check-GitTag'
        'Get-MastodonConfiguration'
        'New-MastodonPost'
        'Parse-Frontmatter'
        'Post-MastodonThread'
        'Process-Entry'
        'Split-Post'
        'Upload-MastodonMedia'
        'Run-MicroblogtoMastodon'
    )

    # Cmdlets to export (none)
    CmdletsToExport = @()

    # Variables to export (none)
    VariablesToExport = @()

    # Aliases to export (none)
    AliasesToExport = @()

    # Private data for future use
    PrivateData = @{}
}
