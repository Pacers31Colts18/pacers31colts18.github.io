---
title: Testing network connections with a PowerShell function.
description: A quick function for testing network connections with PowerShell.
slug: test-portnetconnections-post
date: 2025-02-25 00:00:00+0000
categories:
    - PowerShell
    - Active Directory

---

I made an introductory post back in November, but work and life, and not knowing what to do or write about has gotten in the way. This is my attempt at actually starting this blog, and seeing where it takes me. I'm trying to put myself out there more, but can honestly say it's scary and nerve wracking to put my thoughts and code out in the world. But here goes...

I've always had dirty code sitting around to test network connectivity to Active Directory domain controllers, but I finally got around to cleaning it up and putting this in a format that I think will be helpful for others.

The gist of this function is to parse through Ports, which are defined in an ParamBlock (which also allows for customization on said ports), and looping through a single domain, or multiple domains and testing against those domain controllers for connectivity. The ports are probably not the most comprehensive list, and I'm sure I'll add more ports over time.

The beauty of this is being able to run against one domain, or multiple domains, or all the domains in your environment. I like to utilize CSV files as the source files, and pipe that to Out-GridView for further customization. Rather than having an "All" switch, or a parameter for a single domain, this allows me to pick and choose which domains I want to scan against.

I'm going to break down the code here, so you can get an idea of what this function does. The full function can be found on my Github page, which is linked to the left.

```powershell
[CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [array]$Domains,
        [Parameter(Mandatory = $False)]
        [array]$Ports = @(53,88,135,137,139,389,445,464,636,3268,3269),
        [Parameter(Mandatory = False)]
        $DomainCSVPath
    )
```

This is the main parameter block. $Domains is an array, so you can add a comma-separated list of your domains. 
- Examples: 
    - joeloveless.com
    - joeloveless.com, contoso.com

$Ports is another array, by default, it's going to scan against the ports listed above. Putting the ports in the Parameter block allows you to customize what you want to scan against. If you do not necessarily want to scan against the ports listed above, no problem? Enter your own.

$DomainCSVPath. I use this extensively at my line of work. Header should be a Title, with the FQDN of the domains listed below. I then typically store this in my GitHub repos for easy access. In my code at work, I'll hacve the path pre-determined so I do not need to input the CSV file everytime, but for this code example, I am leaving it out.

```powershell
#region Parameter Logic
    if ($Domains.Count -eq 0) { $Domains = (Import-CSV -path $DomainCSVPath | Out-GridView -PassThru).Title }   
    #endregion

    #region Declarations
    $FunctionName = $MyInvocation.MyCommand.Name.ToString()
    $date = Get-Date -Format yyyyMMdd-HHmm
    if ($outputdir.Length -eq 0) { $outputdir = $pwd }
    $OutputFilePath = "$OutputDir\$FunctionName-$date.csv"
    $LogFilePath = "$OutputDir\$FunctionName-$date.log"
    $ResultsArray = @()
    #endregion
```

This section of the function, I put in nearly all the functions I write.

Parameter logic. If the domain is not specified (-eq 0), then the CSV will be imported and passed to Out-GridView. From there, you'll be able to select your domain(s)

Declarations. This is really solely for the output and logging. I like to have consistency in my code, and define the same spot for output, and not necessarily have C:\Temp as a dumping ground. The $FunctionName parameter also allows me to structure the name of the .csv and .log files, so I know what ran it, and when (Date).

```powershell
Foreach ($domain in $domains) {
        [array]$IPAddresses = (Resolve-DnsName -Name $domain).ipaddress

        Foreach ($IP in $ipAddresses) {
            Foreach ($Port in $Ports) {
                $TestPort = (Test-NetConnection -Computername $IP -Port $Port).TcpTestSucceeded
                If ($TestPort -eq $False) {
                    $TestPort = "Fail"
                }
                If ($TestPort -eq $True) {
                    $TestPort = "Pass"
                }
                $result = New-Object -TypeName PSObject -Property @{
                    DomainName = $Domain
                    IPAddress  = $IP
                    Port       = $Port
                    Result     = $TestPort 
                }
                $ResultsArray += $result
            }
        }
    }
```

This region is the guts of the function really.

 - We're going to run Resolve-DNSNames and pull back the IP addresses and store in an array. https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname?view=windowsserver2025-ps

 - From each IP address in the domain, we're then going to do a Test-NetConnection and only pull back if the TCPTestSucceeded. Then for cleanliness, if $True, we're going to name it "Pass". If the results are $False, we're going to name it "Fail".

 - I then like to store everything in a pscustomobject, and then output that to an array. Here I am grabbing the DomainName, IPAddress, Port, and the Result.

 ```powershell
 #region Results
        if ($resultsArray.count -ge 1) {
            $ResultsArray | Select-Object DomainName, IPAddress, Port, Result | Sort-Object -Property DomainName, IPAddress | Export-Csv -Path $outputfilepath -NoTypeInformation
        }
    
        #Test if results file was created
        If (Test-Path $outputfilepath) {
            Write-Output "Results found. Results file=$outputfilepath."
        }
        else {
            Write-Warning -message "No results found." -level Warning
        }
        #endregion
```

This is another area that is in almost all my code, at least the code where I am gathering data. From here, I am taking the $ResultsArray, and exporting to a CSV file. Once that runs, I make sure the file is created, and the function is then finished.

I hope this is helpful for someone out there, whether new to coding, or someone has been doing it quite a while. I'm not sure this is the best way or not, but this is what seems to work for me. I'll try to post more here in the future.

-Joe Loveless 2/25/25