Notes: 
When dealing with o365 subscriptions you must cross reference sku. 

```$skus = Get-MgSubscribedSku
$skus | Select SkuPartNumber ```

https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference
https://learn.microsoft.com/en-us/microsoft-365/enterprise/view-licenses-and-services-with-microsoft-365-powershell?view=o365-worldwide

`$user = Get-Mguser -Filter "AssignedLicenses/any(x:x/SkuID eq 3b555118-da6a-4418-894f-7df1e2096870)" -ALl` business basic

`$user = Get-Mguser -Filter "AssignedLicenses/any(x:x/SkuID eq cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46)" -ALl` business prembas$hr