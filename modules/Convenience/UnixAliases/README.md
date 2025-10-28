# UnixAliases

This module is part of the PowerShell monorepo.

## Installation

```powershell
Import-Module (Join-Path $(PSScriptRoot) UnixAliases.psm1)
```

## Description

Wraps Windows commands in Unix-like aliases. For example, `touch example.txt` calls `'' | Out-File example.txt -Encoding ASCII` and creates an empty file named `example.txt` at the current path, just like how the `touch` command works on Linux.
