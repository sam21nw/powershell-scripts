﻿<#
.SYNOPSIS
	Checks the swap space
.DESCRIPTION
	This PowerShell script queries the current status of the swap space and prints it.
.PARAMETER minLevel
	Specifies the minimum level in GB (10 GB by default)
.EXAMPLE
	PS> ./check-swap-space.ps1
	✅ Swap space uses 42%, 748MB free of 1GB
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([int]$minLevel = 10)

function MB2String { param([int64]$Bytes)
        if ($Bytes -lt 1000) { return "$($Bytes)MB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)GB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)TB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)PB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)EB" }
}

try {
	[int64]$Total = [int64]$Used = [int64]$Free = 0
	if ($IsLinux) {
		$Result = $(free --mega | grep Swap:)
		[int64]$Total = $Result.subString(5,14)
		[int64]$Used = $Result.substring(20,13)
		[int64]$Free = $Result.substring(32,11)
	} else {
		$Items = Get-WmiObject -class "Win32_PageFileUsage" -namespace "root\CIMV2" -computername localhost 
		foreach ($Item in $Items) { 
			$Total += $Item.AllocatedBaseSize
			$Used += $Item.CurrentUsage
			$Free += ($Total - $Used)
		} 
	}
	if ($Total -eq 0) {
        	Write-Output "⚠️ No swap space configured"
	} elseif ($Free -eq 0) {
		Write-Output "⚠️ Swap space of $(MB2String $Total) is full"
	} elseif ($Free -lt $minLevel) {
		Write-Output "⚠️ Swap space of $(MB2String $Total) is nearly full, only $(MB2String $Free) free"
	} elseif ($Used -eq 0) {
		Write-Output "✅ Swap space of $(MB2String $Total) reserved"
	} else {
		[int]$Percent = ($Used * 100) / $Total
		Write-Output "✅ Swap space uses $Percent%, $(MB2String $Free) free of $(MB2String $Total)"
	}
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
