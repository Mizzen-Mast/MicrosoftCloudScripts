<# 
.SYNOPSIS
        Closes out a former employees account
.DESCRIPTION
        This PowerShell script uses the exchange online commandlets and mggraph commandlets to close a users account. 
.EXAMPLE 
        
.LINK
        tbd
.NOTES
        Author: Mizzen Mast
        Requires: Exchange Online, Microsoft Graph
    #>

[cmdletBinding(DefaultParameterSetName="Default")]
param( 
    [Alias("User")]    
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the Users Principle Name",
        Position = 0
    )]
    [ValidateNotNull()]
    [mailaddress]$UPN,
    [Alias("Manager")]
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the Managers Principle Name",
        Position = 1
    )]
    [ValidateNotNull()]
    [mailaddress]$managerUPN
)

function Split-Upn($userPrincipalName) {

    $username,$domain = $userPrincipalName -Split '@'

    Return $username, $domain
}

#set up variables needed
$username,$domain = Split-Upon $upn
$deviceNameBegin = $username
$deviceDisabled = $false

#first disconect from Microsoft Graph if a session exists
if (get-mgcontext) { 
    Disconnect-MgGraph
    Connect-MgGraph -Scope Device.ReadWrite.All, Directory.ReadWrite.All -ContextScope Process
} else {
    Connect-MgGraph -Scope Device.ReadWrite.All, Directory.ReadWrite.All -ContextScope Process
}



#disable User account, Set department and title to blank
Clear-Variable user -ErrorAction SilentlyContinue
$user = Get-MgUser -Filter "startsWith(UserPrincipalName, '$upn')"

If ($user) {
    Update-MgUser -UserId $user.Id -AccountEnabled:$false -Department '' -Title ''
} Else { 
    Write-Host "No User found, closing"
    Pause
    Exit
}

Clear-Variable user -ErrorAction SilentlyContinue
$device = Get-MgDevice -Filter "startsWith(DisplayName, '$deviceNameBegin)"
If ($device) { 
    Update-MgDevice -DeviceId $device.Id -AccountEnabled:$false
} Else { 
    Write-Host "No device found, it probably wasn't renamed appropriately"
    $deviceDisabled = $true
    Pause
}





if (!$deviceDisabled) { 
    Write-Host "Please go find the device and disable it."
    Pause
}


