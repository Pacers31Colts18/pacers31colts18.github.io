@{
    RootModule        = 'mastodon.psm1'
    ModuleVersion     = '1.1.0'
    GUID              = 'b7d4a4c1-8f3c-4b5d-9c1b-92c7e4a1f001'
    Author            = 'Joe Loveless'
    CompanyName       = 'JoeLoveless.com'
    Description       = 'Microblog posting module for Mastodon.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Invoke-MicroblogToMastodon',
        'Get-MastodonConfiguration',
        'Invoke-MastodonMedia',
        'New-MastodonPost',
        'Publish-MastodonThread'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('mastodon', 'microblog')
        }
    }
}
