Foreach ( $dept in $departments ) { 
    $groupBody = @{ 
        DisplayName = "$dept Manager"
        SecurityEnabled = $true
        MailEnabled = $false
        MailNickName = $dept.toString()+"manager" 
        GroupTypes = "DynamicMembership"
        MembershipRule = "(user.jobTitle -contains ""manager"") and (user.department -eq ""$dept"")"
        MembershipRuleProcessingState = 'On'
    }
    
    New-MgGroup -BodyParameter $groupBody

}