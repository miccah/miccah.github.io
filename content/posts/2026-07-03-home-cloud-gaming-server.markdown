---
date: "2026-07-03T09:00:00Z"
tags: misc
title: Home cloud gaming server
---

At the end of 2024 I decided to build a new gaming PC. My existing one was a
typical tower computer from 2012 that was big and loud and too old to run
*Elden Ring*! So I decided it was time to make a new build, but this time, I
wanted to do it a little different. I wasn't thrilled with the idea of having a
large and loud tower at my desk, so I thought it would be fun to build a server
that could stream games to my laptop.

It's 2026 now and it *was* fun and is still working, so I'm documenting what I
did.

The goal of this project was to setup private cloud gaming with medium graphics
and also have a place to store photos.

## Hardware

These are the parts I used for my server. It fits nicely in a 3u case (that
came with liquid cooled fans) and runs *very* quiet. I used [PC Builder](https://pcbuilder.net)
to make sure everything was compatible.

| **Part**         |                                                           |
| ---------------- | ---                                                       |
| **Motherboard**  | GIGABYTE B650 AERO G AMD AM5 ATX Motherboard              |
| **CPU**          | AMD Ryzen 9 7950X3D 16-Core, 32-Thread Desktop Processor  |
| **GPU**          | GIGABYTE GeForce RTX 4060 OC Low Profile 8G Graphics Card |
| **OS Storage**   | Crucial P3 Plus 500GB PCIe M.2 SSD                        |
| **Storage**      | Crucial P3 Plus 2TB PCIe NVMe M.2 SSD                     |
| **RAM**          | G.SKILL Flare X5 Series DDR5 RAM 64GB (2x32GB)            |
| **Power Supply** | Corsair 1000W Fully Modular SFX Power Supply              |
| **Case**         | Sliger CX3150x                                            |

This is the first time that I've built a system with M.2 hard drives! It's
pretty amazing how much wiring and space it saves.

## Software

Since I wanted to do more than just play games with the system, I decided to
run [Proxmox](https://www.proxmox.com/en/) as the hypervisor operating system. This has allowed me
to install multiple virtual machines and containers for running various
services.

I'm currently running the following:

* A bare LXC for notes
* [Immich](https://immich.app/) for photos
* [Jellyfin](https://jellyfin.org/) for videos
* [Vaultwarden](https://github.com/dani-garcia/vaultwarden) for passwords
* [Docker](https://www.docker.com/) for running a [Minecraft server](https://craftycontrol.com/) (and any other docker container)
    * Yeah, it's kind of weird to run docker in a container, but it's different
      technologies so ¯\\\_(ツ)\_/¯

And of course a Windows 11 virtual machine with passthrough graphics configured
in a way to *mostly* trick the OS to think it's not a virtual machine.
On the Windows VM I'm also running [Sunshine](https://app.lizardbyte.dev/Sunshine/),
the cloud gaming server side to the [Moonlight](https://moonlight-stream.org/)
client. This works quite well since Moonlight supports many clients, including
my Smart TV (blegh), Mac, and Linux machines.

I've also installed [tailscale](https://tailscale.com/) on all of my machines
so I can access them (including the gaming server) over the Internet. It works
surprisingly well from outside the network! This has also worked well to
share photo albums with loved ones by giving them access to my `immich` machine
via `tailscale`.

So it's a pretty decent setup, and it gives me a solid playground to try out new
stuff (NixOS??). Most importantly though, I can now *technically* play *Elden
Ring*! Will I though? Only time will tell.

