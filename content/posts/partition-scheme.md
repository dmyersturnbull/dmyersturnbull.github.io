---
title: "Partitioning scheme"
date: 2021-02-22:10:00-08:00
draft: false
slug: partitioning-scheme
---

------------------------------------------------------------------------

## [#](#-a-partition-scheme-for-a-scientific-workstation) A partition scheme for a scientific workstation

This is the rather strange partitioning scheme I used for my workstation, with justification.
Ubuntu 20.10 on a [1 TB Samsung 980 Pro NVMe drive / PCI-E 4 drive](https://www.newegg.com/samsung-1tb-980-pro/p/N82E16820147790):

| mount point   | size (GB) | filesystem |
| ------------- | --------- | ---------- |
| (efi)         | 0.5       | FAT32      |
| (swap)        | 64        | swap       |
| `/tmp`        | 96        | btrfs      |
| `/`           | 160       | btrfs      |
| `/data`       | 624       | btrfs      |

Here’s the rationale:
- **Swap:** Having swap enables a really ugly failure mode where the system slows to a crawl;
  the amount doesn’t matter. I will very occasionally want to use swap for hastily written codes
  that don’t properly offload memory. If I’m going to have swap at all, it might as well be big.
  (FYI I have 64 GB of memory as well.)
- **No separate home:** I can save `dd` images of the root (including `/home`) every night.
  `/home` only contains files typically generated by user software, such as configs and caches.
- **/data partition:** `/data` is where I put all of my actual files. Some are documents, which are backed up to the cloud
  and external drives, some are permanent data files that I handle backup/versioning for manually (like trained ML files),
  and some are temporary files or files that can just be redownloaded.
  These types can happily reside on the same partition and have different backup schemes.
- **Separate /tmp**: Although there is a security advantage, the main reason for splitting this out is that it can get large,
  and I don’t need my `dd` images to include it.
