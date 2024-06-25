<# 
.SYNOPSIS
        Removes all sharead accounts from groups. 
.DESCRIPTION
        This PowerShell script gets all shared accounts, then removes them from groups. Supports exclusions of specific groups and/or shared account accounts. 
.EXAMPLE 
        ./SharedMailbox.ps1
.LINK
        tbd
.NOTES
        Author: Mizzen Mast
        Requires: Exchange Online,Microsoft Grpah 
#>

$path = "C:\Users\kyleclayson\Downloads\filter.txt"

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
                Connect-MgGraph -ContextScope Process -Scopes Directory.ReadWrite.All
        }
} Else { 
        Connect-MgGraph -ContextScope Process -Scopes Directory.ReadWrite.All
}

Write-Host "Connecting to Exchange"

$exoSession = Get-ConnectionInformation
if ( !($exoSession.UserPrincipalName -split '@')[1] -eq $domain ) { 
        Disconnect-ExchangeOnline
        Connect-ExchangeOnline -ShowBanner:$false
 }

#Get the Shared Mailboxes
$mailboxesShared = Get-Mailbox -Filter {(RecipientTypeDetails -eq 'SharedMailbox')}

<#
365 Business Basic License Skues
       3b555118-da6a-4418-894f-7df1e2096870
      
365 Business Standard
        f245ecc8-75af-4f8e-b61f-27d8114de5f3

365 Business Premium
        cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46

#>

$dataExport = @()

$cont = $false

foreach ($mailbox in $mailboxesShared) { 

        #filter out the emails we don't want.
        #this is done with a terrible hack of Continue: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_continue?view=powershell-7.4
        if (Test-Path -Path $pathFilterdEmails) {
                $emailsToFilter = Get-Content -Path $path
                foreach ($email in $emailsToFilter) {                    

                        #Write-Host "MailBox" $mailbox.Alias
                        #Write-Host "Email" $Email

                        if ($email -ilike $mailbox.alias) { 
                                Write-Host "Found filtered email address, skipping, well trying" $email $Mailbox.Alias
                                Read-Host -Prompt "Press any key to continue..."
                                $cont = $true
                                break
                        }
                        else { 
                                #Write-Host "COntinuing with" 
                                $cont = $false
                        }
                }
        }

        #skip this email we found it in the filtered
        if ($cont) { Continue }
        #Write-host "didn't continue: $cont"
        
        $groups = Get-MgUserMemberOfAsGroup -UserId $mailbox.ExternalDirectoryObjectId

        #add first group 
        If ([string]::IsNullorEmpty($dataExport.GroupId) ) { 
        $dataExport += New-Object -TypeName PsObject -Property @{"Group"=$Group.DisplayName; "GroupId"=$group.Id; "Member1"=$mailbox.UserPrincipalName; "NumOfMem"=1 }
        }
        foreach ($group in $groups ) { 


                $index = [array]::indexof($dataExport.groupid, $group.Id) 
                #$group.Id
                <#
                Write-Host "Group: $group.DisplayName"
                Write-Host "Index: $index"
                #>
                <#
                if ($group.Displayname -ilike 'All Members') { 
                        #do nothing if this group is found 
                }
                elseif ($group.Displayname -iLike 'All Users') { 
                        #do nothing if this group is found 
                }
                Elseif ($group.DisplayName -iLike 'App') { 
                        #do nothing if this group is found 
                }
                elseif 
                #>
                if ($index -eq '-1'){ 
                        Write-Host "In index negative one, adding new group"
                        Write-Host $Group.DisplayName
                        $DataExport += New-Object -TypeName PsObject -Property @{"Group"=$Group.DisplayName; "GroupId"=$group.Id; "Member1"=$mailbox.UserPrincipalName; "NumOfMem"=1 }
                        #Read-Host -Prompt "Press Any Key to continue"

                }
                elseif ($index) {
                        #Write-Host "Index found, Appending"
                        #Write-Host "Length Before" + $dataExport[$index].NumOfMem
                        $memberNum = ($dataExport[$index].NumOfMem + 1)
                        $dataExport[$index] | Add-Member -NotePropertyName "Member$memberNum" -NotePropertyValue $mailbox.UserPrincipalName
                        $dataExport[$index].NumOfMem += 1
                        #Write-Host "Length After" + $dataExport[$index].NumOfMem
                        #Read-Host -Prompt "Press Any Key to continue"
                }
                
        }
        #inside the mailbox foreach and outside of the group for each

        #>
}
