---
title: "Exploring Microsoft Intune Filters"
description: Details on filtering with Microsoft Intune.
slug: exploring-microsoft-intune-filters
date: 2025-10-04 00:00:00+0000
image: cover.png
categories:
    - Intune
keywords: [Intune]
---

# Exploring Microsoft Intune Filters

## Intro

It's been a couple weeks since I've made a post. A lot has been happening at our house. I went camping a few weekends ago with my daughter at Mille Lacs State Park. It was our first time checking out the Brainerd, MN area. We did a lot of hiking, and passed our 50 mile mark for the MN State Park Hiking Club. We visited Mille Lacs State Park, Crow Wing State Park, Father Hennepin State Park, and Lake Maria State Park before heading back home. It was a great weekend camping with her and checking out the area.

![MN Hiking Club](hikingclub.jpg)

I'm a sucker for stopping for a good road-side attraction. When the whole family is in the car, I don't get the chance to stop. But when by myself or the kids, yeah I'll stop at every place I can. I probably get that from my dad. He stopped at the Corn Palace in Mitchell, South Dakota once.
![Paul Bunyan Land](babe.jpg)

I bought this hammock for myself on camping trips. I don't think I've used it for more than 5 minutes, the kids love to chill and read books in it though. It also protects from falling acorns.
![Hammock](hammock.jpg)




Since then, the kids have been back in school. She is starting 9th grade, while my son is starting 7th grade. They've homeschooled the last few years, and now are doing online schooling through Minnetonka. Most likely, they'll transition back to in-person school after this year, depending on if we move or not. Where we live now is pretty damn rural, and not a lot to offer for them. With the RTO fun, we might be on the move (again). We'll see what the future holds, any move probably wouldn't be until the spring.



I wanted to write a bit about using filters with Microsoft Intune, and provide the filters we use.

## What are filters?

[Scott Duffey](https://techcommunity.microsoft.com/blog/intunecustomersuccess/intune-grouping-targeting-and-filtering-recommendations-for-best-performance/2983058/replies/3571242) explains filters the best. My explanation is below.

- Entra has groups.
   - Dynamic or Static groups
      - Dynamic groups take a bit of time to process.
        - This can cause slowness on the processing of policy assignments on a device.
- Intune has "virtual groups". The recommendation is to use these whenever possible.
  - All Devices
  - All Users
- With filters, you can then narrow down the scope of your assignments.
  - This is done at the device check-in, and is faster than the processing of groups.

Recommendation: Use the built-in virtual groups + filters to be granular rather than relying on Dynamic or Static Groups.

Notes: There are limitations to filters, just like there are limitations to the groups. We have not been able to 100% use filters, nor 100% use groups. For the most part, our assignments look like this:

- Base policies will get assigned either All Devices or All Users (depending on the scope of the policy) with a filter assigned for the OS.
- If a group needs to be excluded, we then exclude the group, and assign to an exception profile that will include the same filter.
  - Note: I'll be writing a post on our policy design at a later date. We've gone through many iterations of this and I believe we've landed on something that works best.


## Creating Filters

An admin can create filters by going to [Microsoft Intune](https://intune.microsoft.com), choosing Devices, and then going to Assignment Filters. Once there, you should see a create button with two options:
1. Managed Devices
2. Managed Apps

There are a variety of different rules that you can create, for the full list, see [Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/filters-device-properties).

## Common Windows Filters

Now that you know what filters are, I want to provide you with the common Windows-based filters we use at our organization. Mostly, we use them for operating system criteria, AutoPilot group tags, and enrollment profiles. Obviously, there are other use cases.

### Join Type Filters

| Filter Name | Filter Rule | Description |
|-------------|-------------|-------------|
|ALL_EntraJoin_PROD| `(device.deviceTrustType -eq "Azure AD joined")` | All Entra joined endpoints. |
|ALL_HybridJoin_PROD| `(device.deviceTrustType -eq "Hybrid Azure AD joined")` | All hybrid joined endpoints. |

### Windows 11 Filters

| Filter Name | Filter Rule | Description |
|-------------|-------------|-------------|
| ALL_W11_PROD| `((device.osVersion -startsWith "10.0.22") or (device.osVersion -startsWith "10.0.26"))` | All Windows 11 endpoints. |
| ALL_W11_ENT_PROD | `(device.osVersion -startsWith "10.0.22") or (device.osVersion -startsWith "10.0.26")) and (device.operatingSystemSKU -eq "Enterprise")` | All Windows 11 Enterprise endpoints. |
| ALL_W11_PRO_PROD| `((device.osVersion -startsWith "10.0.22") or (device.osVersion -startsWith "10.0.26")) and (device.operatingSystemSKU -eq "Professional")` | All Windows 11 Professional endpoints. |
| ALL_W11_RDSH_PROD | `((device.osVersion -startsWith "10.0.22") or (device.osVersion -startsWith "10.0.26")) and (device.operatingSystemSKU -eq "ServerRdsh")` | All Windows 11 multi-session endpoints. |
| ALL_W11_LTSC_PROD | `((device.osVersion -startsWith "10.0.22") or (device.osVersion -startsWith "10.0.26")) and (device.operatingSystemSKU -eq "EnterpriseS")` | All Windows 11 LTSC endpoints. |

### Virtual Machine Filters

| Filter Name | Filter Rule | Description |
|-------------|-------------|-------------|
|ALL_WIN_VirtualMachines_PROD| `(device.model -eq "Virtual Machine") or (device.model -eq "VMWare")` | All virtual machines| 
|ALL_WIN_VMWare_PROD | `(device.manufacturer -eq "VMWare, Inc.")` | All VMWare Virtual Machines|
|ALL_WIN_Hyper-V_PROD | `(device.manufacturer -eq "Microsoft Corporation") and (device.model -eq "Virtual Machine")` | All Hyper-V Virtual machines |

### Azure Virtual Desktop Filters

| Filter Name | Filter Rule | Description |
|-------------|-------------|-------------|
|ALL_AVD_PROD| `((device.operatingSystemSKU -eq "ServerRdsh") or (device.operatingSystemSKU -eq "Enterprise")) and (device.manufacturer -eq "Microsoft Corporation") and (device.model -eq "Virtual Machine")` | All AVD hosts. |
|ALL_AVD_Personal_PROD| `(device.operatingSystemSKU -eq "Enterprise") and (device.manufacturer -eq "Microsoft Corporation") and (device.model -eq "Virtual Machine")` | All Personal AVD hosts. |
|ALL_AVD_Pooled_PROD| `(device.operatingSystemSKU -eq "ServerRdsh") and (device.manufacturer -eq "Microsoft Corporation") and (device.model -eq "Virtual Machine")` | All pooled and remote app hosts. |

*Note: If you have Hyper-V based virtual machines that are not AVD hosts, these filters will need to be tweaked. Intune does not have a great way of detecting these with filters other than OS. Naming conventions is probably the easiest way to detect, but that is not fool proof either.*

### AutoPilot Filters
| Filter Name | Filter Rule | Description |
|-------------|-------------|-------------|
|ALL_AutoPilotEnrollment_PROD | `(device.enrollmentProfileName -eq "ProfileName")` | Autopilot example filter

## Conclusion

I'm curious if anyone has a better design for the AVD limitations that we've ran into for filters. We've also noticed that Microsoft really hasn't expanded much on filters past the initial set they released. Hopefully this is something that can be expanded on in the future. I'd love to see this tie into the Properties Catalog more, or to have more WMI based filtering similiar to what Group Policy had.




