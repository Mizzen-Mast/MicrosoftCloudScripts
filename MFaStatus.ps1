<# 
.SYNOPSIS
        Generates a CSV's of all accounts without MFA Enabled or Enabled, but not registered.
.DESCRIPTION
        This PowerShell script uses the Microsoft Graph Commandlets to get a list of all enabled account within a tenant and displays the status. 
.EXAMPLE 
        ./Get-MFAStatusAllUsers.ps1
.LINK
        tbd
.NOTES
        Author: Mizzen Mast
        Requires: Micorosft Graph
        Scope: Reports.Read.All,User.Read.All
        
#>

[cmdletBinding(DefaultParameterSetName="Default")]
param( 
    # Parameter help description
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the full path of the Folder you'd like these CSVs stored in",
        Position = 0
    )]
    [string]$path
)

Connect-MgGraph -Scopes Reports.Read.All,User.Read.All -ContextScope Process -NoWelcome

#Get All users MFA is enabled for
$NotEnabled = Get-MgReportAuthenticationMethodUserRegistrationDetail | Where-Object { $_.IsMfaCapable -eq $False }

# Get all users mfa is enabled, but not registered
$EnabledNotRegistered = Get-MgReportAuthenticationMethodUserRegistrationDetail | Where-Object ( { $_.IsMfaCapable -eq $True } -and { $_.IsMfaRegistered -eq $False} )

#Get all users with display name

$accounts = Get-MGuser -All -Property Displayname,ID,UserPrincipalName -Filter "UserType eq 'Member'"

$NotEnabledAccounts = @()
$EnabledNotRegisteredAccounts = @() 

#Convert Object ID to Name.
ForEach ( $mfaUser in $NotEnabled ) { 
    ForEach ( $account in $accounts ) {
        If ( $MfaUser.ID -eq $account.ID ) { $NotEnabledAccounts += $account; }
    }

} 

ForEach ($mfauser in $EnabledNotRegistered) {
        ForEach ( $account in $accounts ) { 
            if ( $MfaUser.ID -eq $account.ID ) { $EnabledNotRegisteredAccounts += $account }
    }
}

$NotEnabledAccounts | Select-Object DisplayName,UserPrincipalName| Export-Csv -Path "$path\MfaNotEnabled.csv" -NoTypeInformation
$EnabledNotRegistered | Select-Object DisplayName,UserPrincipalName | Export-Csv -Path "$path\MFAEnabledNotRegistered.csv" -NoTypeInformation 
