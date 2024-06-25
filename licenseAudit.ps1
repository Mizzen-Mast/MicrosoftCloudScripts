<# 
.SYNOPSIS
        Compares users taken from CSV to users with License in o365
.DESCRIPTION
        This powershell script takes a csv with a list of users. It spits out 3 csvs in return
        1 Modified copy of the list of users, with whether they have a prem license or basic. 
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
    [string]$userListPath, 
    [Alias("ExportPath")]    
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the path to the export directory",
        Position = 0
    )]
    [ValidateNotNull()]
    [ValidateScript ( { 
        if (-not (Test-Path -Path $_ )) { throw "File Not found."}
        elseif (-not (Test-Path $_ -PathType Container) ) { throw "That's a file, please enter a directory"}
        return $true
    })]
    [string]$exportDirPath 
    ) 


#Get set up. 
#connect to Microsoft Graph
#Pull data from csv

$basicSku = "3b555118-da6a-4418-894f-7df1e2096870"
$premSku = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"

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

#pull data from CSV
$hrUsers = Import-CSV -Path $userListPath
$confirmedBasicUsers = @()
$confirmedPremUsers = @()

#get users with basica and prem license
$basicUsers = Get-Mguser -Filter "AssignedLicenses/any(x:x/SkuID eq $basicSku)" -All
$premUsers = Get-Mguser -Filter "AssignedLicenses/any(x:x/SkuID eq $premSku)" -All


for (( $i = 0); ($i -lt $hrUsers.Length); $i++ ) { 
    for (( $j = 0); ($j -lt $basicUsers.Length); $j++ ) { 
        if ( ($hrUsers[$i].LastName -ieq $basicUsers[$j].Surname) -and ($hrusers[$i].FirstName -ieq $basicUsers[$j].GivenName)) {
                
                $basicUsers[$j] | Add-Member -NotePropertyName 'Hr User' -NotePropertyValue Y
                $confirmedBasicUsers += $basicUsers[$j]

                $hrUsers[$i] | Add-Member -NotePropertyName BasicLicense -NotePropertyValue Y
                <#if ($hrUsers[$i].BasicLicense) { 
                        $hrUsers[$i].BasicLicense = Y
                        WRite-Host "Basic license, member added"
                } else { 
                        $hrUsers[$i] | Add-Member -NotePropertyName BasicLicense -NotePropertyValue Y
                        Write-Host "Basic License, adding member"
                } #>
        } 
    }
    
    for(( $k = 0); ($k -lt $premUsers.Length); $k++) {
        if ( ($hrUsers[$i].LastName -ieq $premUsers[$k].Surname) -and ($hrusers[$i].FirstName -ieq $premUsers[$k].GivenName)) {
                
                $premUsers[$k] | Add-Member -NotePropertyName 'HrUser' -NotePropertyValue Y
                $confirmedPremUsers += $premUsers[$k]
                
                $hrUsers[$i] | Add-Member -NotePropertyName PremLicense -NotePropertyValue Y
                <# if ($hrUsers[$i].PremLicense) { 
                        $hrUsers[$i].PremLicense = Y
                        Write-Host "prem License, member added"
                } else { 
                        $hrUsers[$i] | Add-Member -NotePropertyName PremLicense -NotePropertyValue Y
                        Write-Host "prem License, adding member"
                } #>
            
        } 
    }
}


$hrUsers | Select-Object FirstName,LastName,PremLicense,BasicLicense | Export-Csv -Path "$exportDirPath\hrUsers.csv" -NoTypeInformation
$confirmedBasicUsers | Select-Object UserPrincipalName,HrUser | Export-Csv -Path "$exportDirPath\basicUsers.csv" -NoTypeInformation
$confirmedPremUsers  | Select-Object UserPrincipalName,HrUser | Export-Csv -Path "$exportDirPath\premUsers.csv" -NoTypeInformation