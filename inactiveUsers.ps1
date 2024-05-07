#first set permissions to allow reading from audit log and Directory. 
Connect-MgGraph -Scope AuditLog.Read.All,Directory.Read.All -NoWelcome
Connect-ExchangeOnline -ShowBanner:$false


$dateConsideredInactive = (Get-Date).AddDays(-90)
$accountCreatedBefore = (Get-Date).AddDays(-30)

#get all users that have accounts enabled and not guest accounts
$users = Get-MgUser -All -Property DisplayName,Mail,UserPrincipalName,UserType,SignInActivity,AccountEnabled,CreatedDateTime | Where-Object { ($_.AccountEnabled -eq $true ) -and ( $_.UserType -eq 'Member' ) -and ( $_.CreatedDateTime -lt $accountCreatedBefore ) }

#filter for the last sign in date time before 90 days. 
$inactiveUsers = $users | Where-Object { $_.SignInActivity.LastSignInDateTime -lt $dateConsideredInactive -and $_.SignInACtivity.LastNonInteractiveSignInDateTime -lt $dateConsideredInactive }

$sharedInactive = @()
$notSharedInactive = @()

#filter for sharedmailbox. 
ForEach($account in $inactiveUsers) { 

    If ((Get-Mailbox $account.Mail).RecipientTypeDetails -eq 'SharedMailbox') { 

            $sharedInactive += $account
    }
    Else { 
        $notSharedInactive += $account
    }

}


$sharedInactive | Select-Object -Property DisplayName,UserPrincipalName | Export-Csv -Path C:\Users\KyleClayson\Downloads\SharedinActive.csv -NoTypeInformation
$NotsharedInactive | Select-Object -Property DisplayName,UserPrincipalName | Export-Csv -Path C:\Users\KyleClayson\Downloads\NotSharedinActive.csv -NoTypeInformation
