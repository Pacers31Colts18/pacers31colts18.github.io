@{
    RootModule        = 'common.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'e3b7c4b1-9d2a-4c8f-8f3a-1b2c4d7e9001'
    Author            = 'Joe Loveless'
    CompanyName       = 'JoeLoveless.com'
    Description       = 'Shared microblogging utilities for Mastodon and Bluesky modules.'
    PowerShellVersion = '5.1'

    # Export only shared/common functions
    FunctionsToExport = @(
        'Convert-Frontmatter',
        'Split-Post',
        'New-Entry',
        'Test-GitTag'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('microblog', 'common', 'shared')
        }
    }
}
