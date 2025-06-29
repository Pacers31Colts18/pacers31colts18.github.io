---
title: "Tech tools I use at home and at work"
description: An overview of the random tech I use at home and at work.
slug: tech-tools-I-use
date: 2025-06-28 00:00:00+0000
image: cover.png
categories:
    - Other
---

I don't have a whole lot to write about this week, summer is in full swing, which means I'm pretty swamped with the kids and doing different activities. Right now I'm studying (again) for the AZ-104 test, blogging, and being slammed at work. My motivation hasn't fully been there since the RTO announcement, but the tech motivation is always there. Just a lot of anxiousness on what the future holds, which the HR department seems to change minute by minute while the agency has promoted telework as the future for the past five years.

But, I wanted to post something a little bit different. This post is a rundown of the tech I use both at home and at work.

## Home Tech

### Hardware
- Intel Nuc (8th generation?)
  - I use this running ProxMox to run my Home Assistant and Plex VMs. Probably a little overkill for the use case. My Plex setup is as basic as you can get, with an 8 TB external HD plugged into it.
- Dell Optiplex 7070 SFF
  - I bought this used off eBay. I was supposed to get a Mini Tower, but the seller sent me a SFF. My dream of beefing it up with multiple hard drives died there. Instead, PayPal refunded me and I have a free SFF PC. I use this for my home lab stuff, blogging, etc.
- Lenovo Thinkpad Yoga 370
  - I recently discovered how much I love the tablet mode, never used that before. I've been using this for note taking for AZ-104 using OneNote. Makes me want to buy an actual tablet. Mainly I have this on my desk with Discord open during the day, and maybe random podcasts playing.
- Google Pixel 6
  - My phone, I recently put GrapheneOS on this instead of stock Android. I don't have any complaints about it, I don't see random news articles anymore, and I've basically de-googled at this point which is nice. The ability to still download apps from the Play Store is there, with everything being sandboxed.
- Eero Mesh
  - I use the Eero Mesh for my wifi in my office, basement, and main floors. Would I buy it again? Probably not, I'm not a fan of how locked down some of it is. Fiber is supposed to come to my house in the fall, so I might look at upgrading then to something else. Maybe I'll go the Ubiquiti route.
- Starlink
  - No options really, either Starlink or some crappy DSL provider. I'm looking forward to the fiber option and can't wait to cancel. It does well for the most part, heavy rain interferes with it (not really snow though). But it's $120 bucks a month, and Elmo seems like a douche.
- PS5
  - I have a PS5 for gaming, mainly for my kids, but I'm a big kid at heart. Since getting it last year, I've played the God of War games, and now am hooked on Call of Duty. I'll probably get a new game here soon. Gamertag: Pacers31Colts18.
- Zwift Hub
  - I bought this for indoor cycling in the winter. Turns out indoor cycling is super f'n boring. I don't use it all that much.
- Google Chromecast TV
  - I use Google TVs for streaming purposes. I wish the storage was a little bit bigger, but I also don't run a lot of apps so it isn't too bad. No complaints.
- Google Hubs
  - I have two of these, honestly, I barely use them anymore. I find them to get dumber and dumber as the days go on and have basically given up trying.

### Software

- [Plex](https://plex.tv)
  - I use Plex to stream my home media. My kids (14 and 12) have a specific niche of Star Wars, Marvel, Avatar, Monsterverse, Jurassic Park, any anything else that involves giant monsters or cool superheroes. That is mainly what I watch too.
- [Sonarr](https://sonarr.tv/)
  - Sonarr for grabbing TV shows I already own.
- [Radarr](https://radarr.video/)
  - Radarr for grabbing movies I already own.
- [Bazarr](https://www.bazarr.media/)
  - Bazarr for grabbing subtitles for said movies and tv shows I already own.
- [NZBGet](https://nzbget.net/)
  - Sonarr/Radarr tell NZBGet what to grab.
- [Prowlarr](https://prowlarr.com/)
  - Prowlarr sync's everything together in one spot so I don't have to.
- [Home Assistant](https://www.home-assistant.io/)
  - Home Assistant is the home automation platform. My setup is super basic. I have some smart bulbs, smart switches, the hubs, and a propane tank sensor. I've always dreamed of having more automation, but I don't use it all that much. I also use it for watching HD space on my external HD for Plex.
- Hyper-V
  - I use Hyper-V to run my home lab, off the Dell Optiplex 7070. This is connected to my Azure tenant that I use for testing stuff out.
- OneNote
  - OneNote for random note taking
- [BitWarden](https://bitwarden.com/)
  - BitWarden is my password vault. I recommend it, $10 bucks a year. Does have random autofill issues on Android it seems.
- [PipePipe](https://github.com/InfinityLoop1308/PipePipe/releases)
  - Open source alternative to Youtube. Fork of NewPipe. I use this over YouTube in my attempt to DeGoogle as much as possible.
- VSCode
  - I use VSCode to either write scripts, or write blog posts in Markdown format.
- GitHub
  - My site is tied to GitHub pages with branching and source control.
- Squarespace
  - I purchased my domain name on Google Domains initially, then that got sold off to Squarespace. Seems simple enough.
- Hugo
  - The platform I use for blogging. I mainly followed the guide from [Mike Robbins](https://mikefrobbins.com/2023/10/26/building-and-deploying-a-blog-with-hugo-and-github-pages/) to get started.

## Work Tech

### Hardware

- Dell Latitude 5440
  - Run of the mill Dell Latitude laptop running a 13th gen i5 with 32 GB ram.
- Some Herman Miller chair
  - I have back problems, decent enough chair, I'm also not going to go out and buy one, so work let me use this at home.
- Custom made standing desk
  - I had some leftover butcher block, and ordered a standing desk kit off Amazon and put the butcher block onto it. My goal was to automate it into Home Assistant, but I never got there. One day.
- 3 monitors
  - 1 32 inch monitor
  - 2 27 inch monitors
    - 1 vertical
    - 1 horizontal
- Blue Yeti Microphone
  - Given to me by Fabian Rodriguez at TCSMUG. 
- MMS Playing Cards
  - When in meetings I need something to keep me occupied while talking. So I shuffle a deck of playing cards I got at MMS 2024. Other random toys I have are a koosh ball and a fidget spinner.

### Software
- Microsoft Office
  - Typical Microsoft shop, running Office and Teams.
- Azure Virtual Desktop
  - AVD multi-session host for nearly all my administrative work.
- ADUC/GPMC (Active Directory and Group Policy)
  - ADUC and GPMC inside the AVD host to be able to manage all the domains we manage.
- Configuration Manager
  - Where and how I really got going in tech, still love it to this day and will die on the ConfigMgr hill.
- VSCode
  - I use VSCode extensively for writing PowerShell scripts.
- GitHub Enterprise
  - Where our team stores all our repos.
- VSCode Extensions
  - I run a pretty vanilla setup, we migrated from Horizon Virtual Desktops to AVD, and I'm trying not to run as many extensions this time around.
    - PowerShell
      - All my coding is done in PowerShell.
    - Prettier - Code Formatter
      - I like how this will format the file for me.
    - GitHub Actions
      - For managing everything we have tied to GitHub Actions.
    - GitHub Pull Requests
      - So much easier than knowing the proper Git syntax and workflow. 10/10.
    - Azure Automation
      - Used for managing the runbooks in Azure, with proper source control to GitHub tied to it.
