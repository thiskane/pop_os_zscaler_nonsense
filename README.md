# Overview

Zscaler doesn't "support" Pop_OS 22.04, which is silly. They do support Ubuntu 22.04 and apparently rely on `/etc/os-release` too much.

This script temporarily replaces your Pop_OS `os-release` file with the contents of one from Ubuntu 22.04. Starts all the fancy zscaler nonsense, then replaces the `os-release` contents with that of Pop_OS. 

The stop argument also kills the `zsaservice` which DOESN'T stop when you logout, exit, or kill the client app. This service will prevent you from accessing other VPNs, a la wireguard, if not stopped.

## Requirements

- Pop_OS 22.04
- An already configured Zscaler client
- `sudo` access from configured zscaler profile account

## Install for global usage

```bash
sudo wget -P /bin/ https://raw.githubusercontent.com/thiskane/pop_os_zscaler_nonsense/refs/heads/main/zscaler
sudo chmod +x /bin/zscaler
```

## Usage

```bash
zscaler {start|stop}
```

> First time usage ensure zscaler is not already running

## Notes

This is basic thrown together stuff becuase I was annoyed. If it breaks your system in anyway, thats on you. No gurantees or warranties. 60% of the time it works everytime.

Tested with `Zscaler-linux-3.7.1.71-installer.run` installer.
