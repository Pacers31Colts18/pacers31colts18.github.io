@{
    RootModule        = 'Bluesky.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c1f4d8b2-3e6a-4d1c-9f2a-8b7e4c2d9001'
    Author            = 'Joe Loveless'
    CompanyName       = 'JoeLoveless.com'
    Description       = 'Microblog posting module for Bluesky (AT Protocol).'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Invoke-MicroblogToBluesky',
        'Get-BlueskyConfiguration',
        'Submit-BlueskyMedia',
        'New-BlueskyPost',
        'Post-BlueskyThread'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('bluesky', 'microblog')
        }
    }
}
