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

#first disconect from Microsoft Graph if a session exists
if (get-mgcontext) { 
    Disconnect-MgGraph
    Connect-MgGraph -Scope Device.ReadWrite.All, Directory.ReadWrite.All -ContextScope Process
} else {
    Connect-MgGraph -Scope Device.ReadWrite.All, Directory.ReadWrite.All -ContextScope Process
}





Clear-Variable user -ErrorAction SilentlyContinue
$user = Get-MgUser -Filter "startsWith(UserPrincipalName, '$upn')"

If (!$user) { 
    Write-Host "No User found, closing"
    Pause
    Exit
}



Update-MgUser -UserId $user.Id -AccountEnabled:$false -Department '' -Title ''

