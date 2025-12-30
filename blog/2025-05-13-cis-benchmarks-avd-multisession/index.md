---
title: "CIS L1 Benchmarks in Intune with AVD Multi-Session Hosts"
description: Details on what settings aren't in scope with AVD Multi-Session hosts.
slug: cis-benchmarks-avd-multisession
date: 2025-05-13
tags:
    - intune
    - cis
    - avd
---

# CIS L1 Benchmarks in Intune with AVD Multi-Session Hosts

Details on what settings aren't in scope for the Windows 11 Benchmark with AVD Multi-Session hosts.

<!-- truncate -->

What a week! Last week was MMS MOA 2025, and I still have this odd hangover from the week that I'm trying to recover from. The past couple nights I've been in bed by 8-9 p.m., which for my 40 year old self, isn't that far off. The haze in general is starting to wear off, and I'm starting to get back into the swings of every day life and every day work. I always come out of MMS with such excitement, but then typically there are the work challenges that get in the way. Never the fault of the actual team I'm on mind you, just work in general. I thought about making a post about all the sessions, all the fun, and everything else that makes MMS great, but my brain is foggy, and I don't know that I could do the week proper justice.

One of the questions I asked in a session about the Open Intune Baseline was surrounding AVD, and how to manage multi-session hosts. For those unfamiliar, AVD Multi-Session is running a "ServerRDSH" SKU, which, accurate or not, I think of these as Terminal Servers running a Windows 11 like operating system. With that, there are challenges with managing these in Intune. Microsoft, has IMO a pretty poorly written [Microsoft Learn[(https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/azure-virtual-desktop-multi-session)] article, that vaguely lays out the limitations. As we've started on the AVD path, and with the amount of clicks it takes in Intune to see what settings are actually applying and what are Not Applicable, we noticed quite the drift in our settings, especially when configuring the CIS L1 Baselines. In our case, due to auditing purposes, we use CIS Windows 11 Enterprise L1, rather than the Intune baseline that has been developed.

Once we figured out there was a limitation in the settings, I got thinking, how can we gather this data and actually know what is applying?

## Graph API for the win

When the Graph API first came out, I was confused on how this worked. Granted, I'm still confused, but just not as confused. In ITIL terms, that is considered progressing iteratively. We looked at the Graph SDK, and I quickly got frustrated by the length of some of the cmdlets, and the inconsistencies. So rather than fumbling with the cmdlets, I've really dove into the Graph API, and found it so much more repeatable and enjoyable. There are still gotchas, and I'm still trying to really figure out the syntax on searching, but I'm getting better.

I wrote a quick function, called [Export-IntuneConfigurationSettings](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneConfigurationSettings.ps1). What this allows me to do is search the Graph URI "https://graph.microsoft.com/beta/deviceManagement/configurationSettings", for settings and return the data from that. (Settings Catalog backed only)

## Walking through the script

I don't like to just link a script and leave it at that, so let's walk through it.

### Parameters, Connection, Declarations

If you've seen past posts from me, a lot of what I write I like to make very repeatable. To be honest, I do a lot of copying and pasting. But, it makes things easier for me, and I like to think easier for the people I work with when they look at our modules and functions and see repeatable code, rather than something crazy.


```powershell
            $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationSettings"
            $Settings = (Invoke-MGGraphRequest -Method Get -Uri $uri).value
```

Based off the connection above, I was able to find all the different operating system skus that are available on the Windows side in Intune. For this purposes (and most), I don't really care too much about iOS, Android, or Mac, so I'm just including Windows based operating systems.

```powershell
$settings.applicability.windowsskus
```

This will give you the direct path to the full list of the WindowsSkus.


```powershell
[CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,
            HelpMessage = "Choose from the following: All, windowsCloudN, windows11SE, iotEnterpriseSEval, windowsCPC, windowsEnterprise, windowsProfessional, windowsEducation, holographicForBusiness, windowsMultiSession, iotEnterprise")]
        [ValidateSet('All', 'windowsCloudN', 'windows11SE', 'windows11SE', 'iotEnterpriseSEval', 'windowsCPC', 'windowsEnterprise', 'windowsProfessional', 'windowsEducation', 'holographicForBusiness', 'windowsMultiSession', 'iotEnterprise')]
        [string]$Scope
    )
```

As you can see above, I'm doing a ValidateSet and giving options on the different SKUs to choose from, or you can select All.

```powershell
    # Microsoft Graph Connection check
    if ($null -eq (Get-MgContext)) {
        Write-Error "Authentication needed. Please connect to Microsoft Graph."
        Break
    }

    #region Declarations
    $FunctionName = $MyInvocation.MyCommand.Name.ToString()
    $date = Get-Date -Format yyyyMMdd-HHmm
    if ($outputdir.Length -eq 0) { $outputdir = $pwd }
    $OutputFilePath = "$OutputDir\$FunctionName-$date.csv"
    $LogFilePath = "$OutputDir\$FunctionName-$date.log"
    $ResultsArray = @()
    #endregion
```

This section is basically in all the code I have. In my profile, I have an $outputDir that I am setting, just a default path to dump all my files. If that is not present, than it will dump to present working directory.

### Gathering the settings

Now, we're ready to gather the settings. Based on the $Scope above, I have a Switch statement, one that is looking for **ALL** the settings, and one looking for settings based on a specific SKU.

```powershell
 #region Gather the settings
    Switch ($Scope) {
        "All" {
            $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationSettings"
            $Settings = (Invoke-MGGraphRequest -Method Get -Uri $uri).value
        }
        Default {
            Try {
                $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationSettings?`$search=%22|||WindowsSkus=$Scope|||%22"
                $Settings = (Invoke-MGGraphRequest -Method Get -Uri $uri).value
            }
            Catch {
                Write-Error "Error gathering Settings: $_"
            }
        }
    }
    #endregion
```

### Building the object, outputting the results

Now that we have the data, we can then build it into a PSCustomObject, and output the results. Nothing too crazy here, this is the data I found most intriguing, but there is a ton of information in the Graph API for this. Once that is done, we're outputting the results to a CSV file to look at later.

```powershell
#region Build Object
    foreach ($item in $Settings) {
        $result = New-Object -TypeName PSObject -Property @{
            Name                    = $item.Name
            Keywords                = $item.Keywords -join "; "
            RootDefinitionId        = $item.RootDefinitionId
            DisplayName             = $item.DisplayName
            HelpText                = $item.HelpText
            OffsetURI               = $item.OffsetURI
            InfoUrls                = $item.InfoUrls -join "; "
            MinimumSupportedVersion = $item.applicability.MinimumSupportedVersion
            WindowsSkus             = $item.applicability.WindowsSkus -join "; "
        }
        $ResultsArray += $result
    }
    #endregion

    #region Results
    if ($ResultsArray.Count -ge 1) {
        $ResultsArray | Sort-Object -Property DisplayName | Export-Csv -Path $OutputFilePath -NoTypeInformation
    }

    # Test if output file was created
    if (Test-Path $OutputFilePath) {
        Write-Output "Output file = $OutputFilePath."
    }
    else {
        Write-Warning "No output file created."
    }
    #endregion
```

## The Data

I've uploaded the raw CSV file on my Github, along with some other files.

[CSV output for All](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneConfigurationSettings-20250513-1630_All.csv)
[CSV output for Multi-Session](https://github.com/Pacers31Colts18/Intune/blob/main/Export-IntuneConfigurationSettings-20250513-1628_multi-session.csv)


Initial count:

- 16232 lines/settings for All
- 13288 lines/settings for Multi-Session
- 13739 lines/settings for Windows Enterprise

Quite the difference, even between Multi-Session and Enterprise

### CIS Benchmarks

The last bit of this post, is how this relates to CIS Benchmarks. When I first started looking at this, we were (and still) are on Enterprise v3.0.0. Since then, v4.0.0 has been released, along with v4.0.0 of the Intune benchmark. Rather than go back and re-work all the data, which was becoming to annoying for me. I've included three tabs, one for CIS Windows 11 Enterprise v3.0.0, one for CIS Windows 11 Enterprise v4.0.0 (only the new settings), and one for CIS Windows 11 Intune v4.0.0

The data for that can also be found on my [GitHub](https://github.com/Pacers31Colts18/Intune/blob/main/Intune_CISBenchmarks_MultiSession.xlsx)

Breakdown of each tab:

- v3.0.0 Windows 11 Enterprise L1
    - 61/384 settings are Intune configurable but not AVD Multi-Session scoped.
        - Intune configurable = Settings Catalog configurable, no custom ADMX, CSP, Remediation, etc.
    - 82/384 settings are not Intune configurable, meaning they are not an option in the Settings Catalog
        - Or they could be names I couldn't find, looking at you One Drive instead of OneDrive!
    - 143/384 settings are not supported in Intune for AVD Multi-Session hosts
- v4.0.0 Windows 11 Enterprise L1
    - Like I said, a new benchmark released, so this tab is a little bit of a work in progress here.
    - 3/31 settings are Intune configurable but not AVD Multi-Session scoped.
    - 10/31 settings are not Intune configurable, meaning they are not an option in the Settings Catalog
    - 13/31 settings  are not supported in Intune for AVD Multi-Session hosts (adding in the v3.0.0 settings to get the full picture)

Before I go too much further, I do want to recognize that CIS says the Intended Audience for these benchmarks are:

![CIS Guidance](win11_guidance.png)

We're in this situation where we have multiple forests, hybrid joined, and no longer wish to manage our settings with Group Policy. Due to regulations, we also need to adhere to IRS config standards, which use the Enterprise benchmarks. I don't believe we're the only ones out there doing this, as Microsoft's stance has been to push users towards Intune management rather than Group Policy management, so this is the pickle we are in.

*Mini disclaimer over*

For work purposes, the Enterprise benchmarks is all I really care about, but for everyone else, I wanted to provide the Intune benchmark data also.

- v4.0.0 Microsoft Intune for Windows 11
    - 86/337 settings/lines are Intune configurable but not AVD Multi-session scoped.
    - 16/337 settings are not Intune configurable, meaning they are not an option in the Settings Catalog.
        - Note: These are named properly from CIS, where the Enterprise uses Group Policy naming convention.
            - Next rant: You think they could standardize the naming scheme for us between GPO and Intune? That'd be super neat.
    - 102/337 settings are not supported in Intune for AVD Multi-Session Hosts

### Big Takeways

- For some reason, User Rights Assignments aren't supported. Why? Beats me. It seems like you would want these to be configurable, but maybe I am missing something.
- ASR Rules aren't supported. I'm assuming you just wouldn't want processes to start getting blocked on these and locking users out?
- Services, not Intune supported at all, but maybe one day?
- The rest seem like random settings to me. I don't really see a rhyme or reason really to why some would be supported, but some aren't. Example: Allow Cortana = Supported. Allow Cortana Above Lock = Not Supported

## Conclusion

Really, this was more of an awareness post more than anything. I think a lot of us are new to the AVD/VDI/Virtual world, coming mainly from a physical workstation side of the house. I've touched Citrix, but it's been many years ago. With Intune and now Microsoft having AVD, it seems orgs are sort of combining the teams and hoping to set the policies the same as a workstation. To me it makes total sense to go this route, but there are some catches and things to consider, especially with Intune. Hopefully this will help someone else out, and be able to catch settings not applying more easily.



