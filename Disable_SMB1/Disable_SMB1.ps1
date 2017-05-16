<#
.SYNOPSIS
    Script to disable SMBv1.

.DESCRIPTION
    This script detects the computer operating system and applies the appropriate change to disable SMBv1.
    The changes require a reboot to take effect.
    
    By: Todd Whorton
        @onemilewide
        www.onemilewide.com
    On: 2017-05-15
#>

$version = (gwmi Win32_OperatingSystem).Caption

#Configurations for Windows 7, Server 2008 & R2
[scriptblock]$disable7 = {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force  #Set to $true to undo.
    sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi  #Change mrxsmb20 to mrxsmb10 to undo.
    sc.exe config mrxsmb10 start= disabled  #Change start type to auto to undo.
    }

#configurations for Windows 8, Server 2012 & R2
[scriptblock]$disable8 = {
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force  #Set to $true to undo.
    sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi  #Change mrxsmb20 to mrxsmb10 to undo.
    sc.exe config mrxsmb10 start= disabled  #Change start type to auto to undo.
    }

#configurations for Windows 10, Server 2016
[scriptblock]$disable10= {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    }

If ($version -like "Microsoft Windows 7*") {$disable7.Invoke()}
ElseIf ($version -like "Microsoft Windows 8*") {$disable8.Invoke()}
ElseIf ($version -like "Microsoft Windows 10*") {$disable10.Invoke()}
ElseIf ($version -like "Microsoft Windows Server 2008*") {$disable7.Invoke()}
ElseIf ($version -like "Microsoft Windows Server 2012*") {$disable8.Invoke()}
ElseIf ($version -like "Microsoft Windows Server 2016*") {$disable10.Invoke()}
Else {exit}
