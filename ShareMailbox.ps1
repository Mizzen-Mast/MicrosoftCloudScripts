<# 
.SYNOPSIS
        Get's a list of all shared Mailboxes
.DESCRIPTION
        This PowerShell script uses the exchange online commandlets to get the shared mailbox list
.EXAMPLE 
        ./SharedMailbox.ps1
.LINK
        tbd
.NOTES
        Author: Mizzen Mast
        Requires: Exchange Online
        
#>

#First Connect to exchange Online
Connect-ExchangeOnline -ShowBanner:$false

$mailboxesShared = Get-Mailbox -Filter {(RecipientTypeDetails -eq 'SharedMailbox')}

