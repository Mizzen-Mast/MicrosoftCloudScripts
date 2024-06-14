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


# First connect to Microsoft Graph and Exchange Online
Write-Host "Connecting to Micorosoft Graph"
$session = Get-MgContext
$company = ($session.Account -split '@')[1]

if ( $session ) { 
        
        ($session.Account -Split '@')[2]
        
        $title    = ''
        $question = "Connected witj Graph to $company. Continue"
        $choices  = '&Yes', '&No'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 0) {
                Write-Host 'confirmed'
        } else {
                Disconnect-MgGraph
                Connect-MgGraph -ContextScope -Process -Scopes Directory.ReadWrite.All
        }
} Else { 
        Connect-MgGraph -ContextScope -Process -Scopes Directory.ReadWrite.All
}

Write-Host "Connecting to Exchange"
Connect-ExchangeOnline


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

$sharedAccounts = @()

foreach ($mailbox in $mailboxesShared) { 

        $groups = Get-MguSermemberOfAsGroup -UserId $mailbox.ExternalDirectoryObjectId

        foreach ($group in $groups ) { 

                switch($group.)
        }
}
