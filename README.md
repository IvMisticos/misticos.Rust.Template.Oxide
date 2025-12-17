# Template for Rust (Oxide)

## What this is

Barebones template for building Harmony mods and Oxide plugins for the game Rust. Ships with two sample projects:

- `Mod` for a Harmony mod you can compile (Latest C#)
- `Plugins` for Oxide plugins (C# 11)

## Prerequisites

- [.NET](https://dot.net/download) for the latest [DepotDownloader](https://github.com/SteamRE/DepotDownloader) release. _Usually already present if you are a developer or if you are using GitHub runners._
- Modern [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell). _Usually already present if you are using GitHub runners._

## Updating

Run `Update.PS1` to download the most recent Rust and Oxide files.

| Parameter             | Description                                          |
| --------------------- | ---------------------------------------------------- |
| `-OS <Windows/Linux>` | The OS for which to download the files               |
| `-Clean <1/0>`        | Cleans folders of tools and dependencies when `1`    |
| `-Staging <1/0>`      | Downloads staging version of Rust and Oxide when `1` |
