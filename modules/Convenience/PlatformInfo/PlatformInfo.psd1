@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'PlatformInfo.psm1'
	
	# Version number of this module.
	ModuleVersion     = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID              = '461fd804-dd8d-4474-a18c-1cce382da8a8'
	
	# Author of this module
	Author            = 'jack'
	
	# Company or vendor of this module
	CompanyName       = 'MyCompany'
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2025 jack'
	
	# Description of the functionality provided by this module
	Description       = 'Functions for returning information about your platform (OS, CPU/RAM, etc)'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @(@{ ModuleName='PSFramework'; ModuleVersion='1.12.346' })
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\PlatformInfo.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# Expensive for import time, no more than one should be used.
	# TypesToProcess = @('xml\PlatformInfo.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module.
	# Expensive for import time, no more than one should be used.
	# FormatsToProcess = @('xml\PlatformInfo.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Get-PlatformCPU',
		'Get-PlatformMemory',
		'Get-PlatformOS',
		'Get-PlatformDisk',
		'Get-PlatformGPU',
		'Get-PlatformNetwork',
		'Get-PlatformBIOS',
		'Get-PlatformMotherboard',
		'Get-PlatformUsers',
		'Get-PlatformProcesses',
		'Get-PlatformLastBoot',
		'Get-PlatformServices',
		'Get-PlatformEnvironment',
		'Get-PlatformUpdates',
		'Get-PlatformEventLogs',
		'Get-PlatformFirewallRules',
		'Get-SystemTimeZone'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport   = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport   = @(
		'Get-PlatformMobo',
		'Get-PlatformEnv'
	)
	
	# List of all files packaged with this module
	FileList          = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}