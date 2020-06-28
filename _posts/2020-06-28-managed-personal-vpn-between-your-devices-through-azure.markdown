---
layout: post
title:  "Managed personal VPN between your devices through Azure"
date:   2020-06-28 20:52:27 +0200
author: Petr Houška
---

Let's say you have a few Windows devices, for example, a powerful desktop and laptop. You mostly work on the desktop but when being remote on the laptop you want to be able to remote to the desktop and harvest it's power / avoid having to sync data. 

Unfortunately, your ISP NATs you into oblivion and/or doesn't provide static IP so RDP/SSH'ing directly is out of the question. [Self-hosted Visual Studio Codespace](https://docs.microsoft.com/en-us/visualstudio/online/how-to/self-hosting-vscode) works for most things but don't cut it for everything. At the same time, you neither want to rent a VM and manage your own VPN (too much work) nor want to use off the shelf 3rd party product s.a. hamachi/TeamViewer/Parsec because you have this irrational detest towards 3rd party remoting software (I know, I know...[^1]).

This brings you to a situation in which you're looking for a managed VPN, ideally one payable with your free Azure credits. Luckily, it's a situation that has a relatively easy solution.

1. Follow [this Point-to-Site VPN tutorial](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal).
	- Basic SKU should be perfectly fine and will run you < ~30 USD/month. 
2. Distribute client certificates created in 1) to your devices, download VPN configuration.
3. Connect on all desired devices to the VPN.
4. Find the IP address of each device within the VPN.
	- Run `ipconfig /all` and find the assigned address within the correct Network interface on every device. Beware, the list might contain the true VPN network interface's HyperV relay.
	- Run `arp -a`, identify the correct network device, and guess the association of IP addresses and devices.
	- Go to `Azure Portal/<Your VPN_gateway>/User VPN Configuration/Allocated IP addresses` and guess the association of IP addresses and devices.
5. Use the IP address to SSH/RDP to your desired device.

For RDP two more things might be relevant.
- By default the VPN's network interface doesn't have DNS configured and so connecting via Computer names won't work. You'll either have to configure DNS or just use IP addresses directly.
- I was unable to login into a Windows 10 2004 that was configured as [passwordless](https://www.microsoft.com/en-us/security/business/identity/passwordless) despite both computers using Microsoft account and Windows hello authentication. I believe it should be possible to make it work, as I know it can work in enterprise setting but just wasn't worth it for me.

---
[^1]: I'm also fully aware that VSCode Codespace is essentially 3rd party remote software, somehow I'm fine with that ¯\\_(ツ)_/¯.
