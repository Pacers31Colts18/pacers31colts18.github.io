---
title: "What Group Policy Settings aren't in Microsoft Intune?"
description: Finding settings that are in Group Policy, but aren't in Intune.
slug: what-settings-are-in-intune
date: 2025-10-11 00:00:00+0000
image: cover.png
categories:
    - Group Policy
    - Intune
    - PowerShell
    - Graph API
---

# What Group Policy Settings Aren't in Microsoft Intune?

## Introduction

One of the challenges that we've found using Intune, is that there are policies that are in Group Policy (new settings even!), that then are not natively supported through the Settings Catalog in Microsoft Intune. Some of this seems to be random, and no clear reason to why this is the case. What is even more frustrating, is either the lack of clear documentation on what settings are actually available, and when they become available, or categories that have gone away from the ADMX backed method all together and write settings to different locations. In this post, I've written a couple of scripts to help admins with finding the settings that either exist or don't exist by exporting ADMX file data from a folder path, and then parsing that data through the Graph API.

## The Issues

### Issue #1: Settings in Intune do not write to the same locations as Group Policy

This is not consistent of course. A lot of settings do write to the same location as the group policy settings, but not all. Nothing is more frustrating that inconsistency. I'm sure there are more that fall under this category. But from what I've seen, the following write to different spots in the registry:

- Bitlocker
- Windows Firewall
- Windows LAPS
- Windows Hello for Business

### Issue #2: GPP Preferences

I won't get into that too much here, that's already been asked for several times with no movement.

- Printers
- Drive Mappings
- Registry Settings
- ODBC Settings
- Files
- Folders

Doesn't seem like that's going to happen anytime soon.

### Issue #3: Random settings in Intune aren't available

Why this happens, I have no idea. I see settings from [Microsoft's Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319&msockid=11ab0ae17f91669f2c121f517e176760) not available. I know there are settings from CIS' Windows 11 Enterprise Benchmark that aren't available. VSCode even recently introduced Group Policy ADMX templates, but did not introduce Intune Settings Catalog policies? It's a very frustrating scenario, and one that does not seem to have any rhyme or reason to it.

## Helping find what's available and what's missing

I've written two functions recently that I wanted to share with the community, and hope that someone will find it valuable. Both scripts are available on my [GitHub](https://github.com/pacers31colts18) or you can find them directly below:

[Export-GPOADMXSettings](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings.ps1)
[Export-IntuneGPOSettings](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings.ps1)

## Export-GPOADMXSettings

While the Group Policy Analytics tool is available in Microsoft Intune, that is more for converting policies from Group Policy to Intune, or at least gathering the data on what is supported in already created group policies. What I am looking to do though, is export the settings from ADMX files themselves, and then find the corresponding Intune settings. Export-GPOADMXSettings helps do just that.

When running the script, you are presented with two paths to take.

- Option 1:
  - Enter a folder path that contains the ADMX files you want to analyze. This will then loop through all the ADMX files in the folder. Good for analyzing a few files, or a single file.
- Option 2:
  - Enter a domain name, this will then connect to the Sysvol and output the data.

If no parameter is specified, the function will default to loading a CSV file for a list of domains (our org has many). This will allow you to choose multiple domain names, with a **Title** header being the FQDN of the domain. From there, it's going to loop through each file and output the following data:

- Domain
    - Domain you connected to (if any)
- SettingName
  - Name of the group policy setting (not the displayName)
- Class
  - HKCU
  - HKLM
  - Both
- Key
  - Registry key path of the policy
- ValueName
  - Registry value name of the policy
- ValueType
  - I tried to categorize this how they are in Group Policy when selecting the options:
    - List
    - Enabled/Disabled List
    - Enabled List
    - Disabled List
    - Enabled/Disabled Value
    - Enabled Value
    - Disabled Value
    - TextBox
    - MultiText
    - Number
    - Dropdown
    - Checkbox
    - String
- ChildKey
  - If exists, the child registry key path.
- ChildValue
  - If exists, teh child registry value.
- Category
  - The associated category of the policy
- SupportedOn
  - What OS, AppVersion, etc that the setting has support for.
- ADMXFile
  - The name of the ADMX file processed.

Not all of this data is necessary for the next portion, but good to have if you are still working in a hybrid environment on a day to day basis. 

### Analyzing Common ADMX files
I've put example outputs also on my GitHub page, but the direct links are here:

[Microsoft OneDrive](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings/OneDrive_Export-GPOADMXSettings-20251010-1306.csv)
[FSLogix](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings/FSLogix_Export-GPOADMXSettings-20251010-1337.csv)
[Microsoft Edge](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings/Edge_Export-GPOADMXSettings-20251010-1144.csv)
[Google Chrome](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings/Chrome_Export-GPOADMXSettings-20251010-0807.csv)
[Azure Virtual Desktop](https://github.com/Pacers31Colts18/GroupPolicy/blob/master/Export-GPOADMXSettings/AVD_Export-GPOADMXSettings-20251011-1643.csv)

## Export-IntuneGPOSettings

*Note: Proper Graph API permissions are required for this. Feel free to checkout my [Getting Started with Microsoft Graph](https://joeloveless.com/2025/07/getting-started-with-microsoft-graph/) post if unfamiliar with Graph.*

Now that we have the Group Policy data, we are going to run the Eport-IntuneGPOSettings function. The main API endpoint that we will be working with on this is this path: **https://graph.microsoft.com/beta/deviceManagement/configurationSettings**

What we are doing with this is loading the previous csv file, and looping through the SettingName, and looking for matches.

```powershell
#Load CSV
    Try { 
        $csv = Import-Csv -path $inputfilepath
    }
    Catch {
        Write-Error "An error occurred importing CSV file: $_"
    }

    #region Gather the settings
foreach ($gp in $csv){
    Try {
        $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationSettings?`$filter=Name eq '$($gp.settingName)'"
        $Settings = (Invoke-MGGraphRequest -Method Get -Uri $uri).value | Where-Object { $_.applicability.platform -match 'windows' }

    }
    Catch {
        Write-Error "Error gathering settings"
    }
```
I found that there were matching setting names in iOS, Android, and MacOS when initially running this, so I needed to narrow down the results a little bit more. The unforunate outcome that I found is that a setting name in Edge, can have the same setting name in Google Chrome. Rather than try to filter it down anymore, and have possible bad results, I've decided to leave this as is. Matching the Group Policy Category to the Intune Category was not an easy task.

Once finished, the following results will be returned:

- GroupPolicyName
  - SettingName from the last CSV file
- GroupPolicyKey
  - Registry key path from the last CSV file
- GroupPolicyValueName
  - Registry key value name from the last CSV file
- IntuneName
  - Name of the policy in Microsoft Intune
- IntuneKeywords
  - Any of the keywords from the configurationsettings api
- IntuneRootDefinitionID
- IntuneDisplayName
- IntuneHelpText
- IntuneOffsetURI
- IntuneMinimumSupportedVersion
- IntuneWindowsSkus
  - Supported Windows Skus for the policy.

## So what is missing?

From the CSV files I gave above, let's take a look at what settings are available in Group Policy, available in Microsoft Intune, and what are missing in Microsoft Intune.

### Azure Virtual Desktop
[AVD Results](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings/AVD_Export-IntuneGPOSettings-20251011-1722.csv)
- 7 Group Policy settings
- 8 Microsoft Intune settings
  - AVD_SERVER_WATERMARKING is listed twice in Microsoft Intune
    - [Deprecated] Enable watermarking
    - Enable watermarking
So this is good, we have 100% support for AVD settings in the admx template file.
[Google Chrome](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings/Chrome_Export-IntuneGPOSettings-20251010-0808.csv)
- 691 Group Policy Settings

I ran into a lot of duplicates here with Microsoft Edge being in the mix, along with settings marked Deprecated. Instead, I'll filter by Blanks on the CSV file.

- 110 missing settings!

Not good! Within these missing settings, the ones that stick out to me the most are:
- AIModeSettings
- DevToolsGenAiSettings
- GeminiSettings
- PasswordDismissCompromisedAlertEnabled
- PasswordManagerPasskeysEnabled
- PasswordSharingEnabled
- PrivacySandboxAdMeasurementEnabled
- PrivacySandboxAdTopicsEnabled
- PrivacySandboxFingerprintingProtectionEnabled
- PrivacySandboxIpProtectionEnabled
- PrivacySandboxPromptEnabled
- PrivacySandboxSiteEnabledAdsEnabled

I would think/hope that there are orgs that would want a little bit more control over AI settings, password policies, and sandboxes in Intune that are purely cloud native?
[Microsoft Edge](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings/Edge_Export-IntuneGPOSettings-20251010-1144.csv)
- 835 Group Policy Settings

Similar to Google Chrome, we're going to see a lot of duplicates with the naming convention being the same.

- 20 missing settings. I do not understand how a Microsoft product doesn't have support in a Microsoft product. Below are the missing settings:
  
- FileOrDirectoryPickerWithoutGestureAllowedForOrigins
- LiveVideoTranslationEnabled
- EdgeWalletCheckoutEnabled
- EdgeWalletCheckoutEnabled_recommended
- ShowTabPreviewEnabled
- ShowTabPreviewEnabled_recommended
- Pol_EdgePreviewEnrollmentTypeMicrosoftEdge
- BlockTruncatedCookies
- ChannelSearchKind
- ReleaseChannels
- AccessControlAllowMethodsInCORSPreflightSpecConformant
- OriginKeyedProcessesEnabled_recommended
- RelaunchFastIfOutdated
- AccessControlAllowMethodsInCORSPreflightSpecConformant
- BlockTruncatedCookies
- WAMAuthBelowWin10RS3Enabled
- WebRtcPostQuantumKeyAgreement
- AllowBackForwardCacheForCacheControlNoStorePageEnabled
- ExtensionsPerformanceDetectorEnabled_recommended
- PrivateNetworkAccessRestrictionsEnabled
[FSLogix](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings/FSLogix_Export-IntuneGPOSettings-20251010-1338.csv)
- 116 Group Policy settings
- Only 1 missing setting, this one might make sense:
  - ProfilesRoamGroupPolicyState
[Microsoft OneDrive](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneGPOSettings/OneDrive_Export-IntuneGPOSettings-20251010-1306.csv)
- 65 Group Policy Settings
- 6 missing Intune settings
  - AddedFolderHardDeleteOnUnmount
  - DisableOfflineModeForExternalLibraries
  - DisableOfflineMode
  - AddedFolderUnmountOnPermissionsLoss
  - SharePointOnPremApplicationIdUri
  - SharePointOnPremOIDC

## Wrapping It Up

These are just some of the examples I ran into, with more being on the Windows setting side. Last time we refreshed our security baseline (pre-24H2), there were a lot more settings missing. I believe our count was around 180 settings not in the Settings Catalog. I'd be curious to know what the reasoning is behind settings not being available, especially settings that resolve CVE's.

    





