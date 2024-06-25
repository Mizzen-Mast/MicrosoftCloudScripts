<# 
.SYNOPSIS
        Compares users taken from CSV to users with License in o365
.DESCRIPTION
        This powershell script takes a csv with a list of users. It spits out 3 csvs in return
        1 with a list of users that don't have licenses
        1 with a list of users that have business basic licenses
        1 with a list of users that have business premium license
.EXAMPLE 
        licenseAudit.csv -UserList C:\User\<username>\Downloads\Userlist.csv
.LINK
        tbd
.NOTES
        Author: Mizzen Mast
        Requires: Microsoft Grpah 
#>
param( 
    [Alias("Path")]    
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the path to the user list csv",
        Position = 0
    )]
    [ValidateNotNull()]
    [ValidateScript ( { 
        if (-not (Test-Path -Path $_ )) { throw "File Not found."}
        elseif (-not (Test-Path $_ -PathType Leaf) ) { throw "That's a directory, please enter a file"}
        return $true
    })]
    [string]$userListPath ) 


#Get set up. 
#connect to Microsoft Graph
#Pull data from csv

#connect to Graph
# First connect to Microsoft Graph and Exchange Online
Write-Host "Connecting to Micorosoft Graph"
$mgSession = Get-MgContext
$domain = ($mgSession.Account -split '@')[1]

if ( $mgSession ) { 
       ($mgSession.Account -Split '@')[2]
        
        $title    = ''
        $question = "Connected with Microsoft Graph to $domain. Continue"
        $choices  = '&Yes', '&No'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 0) {
                Write-Host 'confirmed'
        } else {
                Disconnect-MgGraph
                Connect-MgGraph -ContextScope Process -Scopes Organization.ReadWrite.All -NoWelcome
        }
} Else { 
        Connect-MgGraph -ContextScope Process -Scopes Organization.ReadWrite.All -NoWelcome
}

Import-CSV -Path $userListPath

