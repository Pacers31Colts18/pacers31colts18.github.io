---
title: Creating Intune Randomized Rollouts with Entra Group Membership
description: Creating Intune Randomized Rollouts with Entra Group Membership
slug: entra-grouprandomization
date: 2025-04-26
tags: 
    - intune
    - entra
    - powershell
    - graph-api
---

# Creating Intune Randomized Rollouts with Entra Group Membership

A walk through on how to create randomized rollouts for Intune deployments with Entra Groups using the Graph API.

<!-- truncate -->


It's been a couple weeks now since I made my last post, with the weather starting to get nicer, it means more yard work and more random projects around the house. Next week is MMSMOA 2025, and I will be attending that with many team members. I think this is my 5th MMS, with my first one being in 2018 (I think). I'm really looking forward to it again and to see what new concepts everyone comes up with. I leave every year very excited, but also very worn out from all the days in the conference rooms, and the events that take place afterwards.

With that said, I didn't want to go three weeks without posting anything, but was also struggling to come up with things to write about. Part of my struggle is seeing the already great content out there, and thinking that I can't truly add the value that other people provide. I know it's a bad head space to be in, and something to work through.

In our org, we have around 40k devices. Rolling out policies in the Group Policy days was a little bit easier for us, as we weren't hitting every device at once (way too many forests). The great thing about Intune, is that we can hit all the devices at once. The bad thing about Intune, is we can hit all devices at once!

So the question became, how do we effectively roll out policy to devices and not run into issues? We have a pilot group, but pilot groups are hard to maintain, and not always the best representation of the org. Someone has to maintain that membership, and get buy in from users to be apart of the pilot group, and have enough members. Once we get past the initial internal piloting, and then the pilot group itself, we wanted a way to slowly rollout policies over a course of 2-3 weeks, to catch any issues should they come up.

In our environment when rolling out large scale policies, we aim for a 1%/10%/25%/All Workstations. Typically this will run over the course of three weeks, in a schedule looking like this:

- Week 1
    - Monday: 1%
    - Thursday: 10%
- Week 2
    - Monday: 25%
- Week 3
    - Monday: All Workstations

The thought being, after pilot groups, we are sitting at around 40% of devices covered in a random selection. If something were to happen after this rollout that causes an issue, it's probably more just bad luck.

We have two variations of this function. One being for ConfigMgr. This is used for ConfigMgr rollouts (Configuration Baselines/Configuration Items) and Active Directory groups (Group Policy). The one I am going to show in this post, is for building Entra groups for Intune rollouts.

In our org, something like this would go through the Change Control process, so we like to dump the output of this to a CSV file, then build the group membership after the fact. This could be easily tweaked to build the pilot groups themselves.

# Walking through the function

First, the function can be found on my [Github](https://github.com/Pacers31Colts18/Entra/blob/main/Export-EntraGroupPilotMembers.ps1).

A lot of our code is very repeatable, and makes it easier for the next person to look at and pick up on.

##  Parameters, Declarations, Graph Check

```powershell
[CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$SourceEntraGroupName,
        [Parameter(Mandatory = $True)]
        [ValidateRange(1, 100)][int]$Percentage
    )

    #region Declarations
    $FunctionName = $MyInvocation.MyCommand.Name.ToString()
    $date = Get-Date -Format yyyyMMdd-HHmm
    if ($outputdir.Length -eq 0) { $outputdir = $pwd }
    $OutputFilePath = "$OutputDir\$FunctionName-$date.csv"
    $LogFilePath = "$OutputDir\$FunctionName-$date.log"
    $graphApiVersion = "beta"
    $resultsArray = @()
    #endregion
    
    # Microsoft Graph Connection check
    if ($null -eq (Get-MgContext)) {
        Write-Error "Connect to Graph"
        Break
    }
```

### Parameters

First up is the parameter block. For $SourceEntraGroupName, we are building this off an Entra group that is already established. Example being, say you have an **SG - All Windows 11** group and you are looking to rollout a new policy to Windows 11 devices. You would input this group, then for $Percentage, provide the percentage of devices you want in your pilot group. We do have a ValidateRange check of 1-100. How is it a pilot if you have 100% of devices? It's not, sometimes we just like to use this as a cheat to quickly return all the group members.

### Declarations

This is in almost all of our code, and makes the format of our logging, output files, and directories very repeatable. We set the $outputdir in our Powershell profiles to our preference location. Then use the $FunctionName parameter to name the log file in a proper manner.

### Graph Check

Finally for this section, just a quick little check to see if you're connected to Graph, and if not, return an error.

## Groups

```powershell
#region Obtain Group
    try {
        $uri = "https://graph.microsoft.com/$graphApiVersion/groups?`$filter=DisplayName eq '$SourceEntraGroupName'"
        $group = (Invoke-MgGraphRequest -uri $uri -Method GET).value
        Write-Output "Obtaining Group: $sourceEntraGroupName"
    }
    catch {
        Write-Error "An error occurred : $_"
    }
    #end region

    #region Obtain Group Members  
    $resultCheck = @()   
    try {
        $uri = "https://graph.microsoft.com/$graphApiVersion/groups/$($group.Id)/members"
        #pagination
        do {
            $groupmembers = (Invoke-MgGraphRequest -Uri $uri -Method GET)
            $resultCheck += $groupmembers
        
            $uri = $groupmembers.'@odata.nextLink'
        } while ($uri)
        $groupmembers = $resultCheck.value

        Write-Output "Obtaining '$($group.DisplayName)' with $($groupmembers.count) members." -ForegroundColor Cyan
    }
    catch {
        Write-Error "An error occurred : $_"
    }
    #endregion
```

### Obtaining the Group

From here, we're going to use the Graph API to get the group and all the details associated with it. In the beginning, we tried to stick with the Graph SDK cmdlets. Honestly, I've grown to hate them, and have reverted to using the API, or just relying on the Invoke-MgGraphRequest for nearly everything. I found the SDK to be a pain, with a lack of documentation, examples, and just super long cmdlet names. Finding them, and then finding that they don't work properly became a headache. Once the syntax of the API is figured out (which just takes some repetition), I find this way to be sooooo much easier. From what I've gathered, the SDK is just a wrapper for the API anyways, so I don't really see the point of it to be honest.

### Obtaining Group Members

Same concept here, once we have the Group details (from the $group variable), we can then obtain the membership using the **$group.id**. Based on the size of your Source Group, you might run into pagination issues. In simple terms, pagination is a limit on how much data you can get back at a time with Graph, so you're not slamming the system. More information can be found [here](https://practical365.com/pagination-graph-sdk/) and from [Microsoft](https://learn.microsoft.com/en-us/graph/paging?tabs=http)

## Randomization

```powershell
#region Randomization
    $Decimal = $Percentage / 100
    $NumberofMembers = [int]($($groupMembers).Count * $Decimal)
    $NumberofMembers = [Math]::Ceiling($NumberofMembers)

    Write-Output "Randomizing group and gathering $NumberofMembers workstations."
    $GroupMembers = $GroupMembers | Sort-Object { Get-Random }
    $GroupMembers = $GroupMembers | Select-Object -First $NumberofMembers

    #endRegion
```

Once the group members are returned, we then move onto the randomization of the script. What we're doing here is just simple math, and converting the percentage to a decimal and multiplying to get the count. From there, we are using a Sort-Object with Get-Random, which literally just does what it says and gets a random output of the devices. We're then selecting those members.

## Building the PSCustomObject

```powershell
#region Build Object
    foreach ($member in $groupMembers) {
        $result = New-Object -TypeName PSObject -Property @{
            EntraDeviceID = $member.deviceId
            DeviceName    = $member.displayName
        }
        $ResultsArray += $result
    }
    #endregion
```
Now we're building the data and will be outputting the data. Any property can be added here from what is stored on the device in Entra, but in my case, all I am looking for is the EntraDeviceID and DeviceName. DeviceName, mainly for change control purposes. EntraDeviceID, for when I create the group and add the members.

## Outputting the Results

```powershell
 #region Results
    if ($ResultsArray.Count -ge 1) {
        $ResultsArray | Export-Csv -Path $outputfilepath -NoTypeInformation
    }

    # Test if output file was created
    if (Test-Path $outputfilepath) {
        Write-Output  "Output file = $outputfilepath."
    }
    else {
        Write-Warning "No output file created."
    }
    #endregion
}
```

This is another repeatable section we have in our code. Like I said, we typically output a lot of our data to CSV files for change control purposes. This is a repeatable piece of code that we typically have in every output. What we are doing here is checking if the $ResultsArray (from the PSCustomObject) has any data, and if so, exporting the data to a CSV file, where the Path is in our declarations section. We are then testing to make sure the file was created successfully.

## Conclusion

So now, we have a list of devices that are randomized, and based off a percentage from a source group. You can then repeat this process to build out other wave groups. Rather than have static groups to do the rollout, you can randomize it and get different results each time.

Next week I'll be at MMS. If you happen to see me, be sure to say hi!