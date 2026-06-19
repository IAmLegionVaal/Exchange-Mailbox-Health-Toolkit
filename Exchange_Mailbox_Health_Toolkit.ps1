#requires -Version 5.1
<#
.SYNOPSIS
    Exchange Mailbox Health Toolkit.
.DESCRIPTION
    Read-only mailbox review and reporting helper for support teams.
#>
[CmdletBinding()]
param([string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Exchange_Mailbox_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$module=Get-Module -ListAvailable ExchangeOnlineManagement -ErrorAction SilentlyContinue|Select-Object -First 1
$checks=@([PSCustomObject]@{Area='Module';Name='ExchangeOnlineManagement';Status=$(if($module){'OK'}else{'Info'});Value=$(if($module){$module.Version}else{'Not installed'});Recommendation='Install when live tenant reporting is required.'})
if($InputCsv -and (Test-Path $InputCsv)){$data=Import-Csv $InputCsv}else{$data=@([PSCustomObject]@{PrimarySmtpAddress='sample.user@contoso.com';DisplayName='Sample User';RecipientType='UserMailbox';ArchiveStatus='None';IssueWarningQuota='49 GB';ProhibitSendQuota='49.5 GB'})}
$data|Export-Csv (Join-Path $OutputPath "mailbox_inventory_$stamp.csv") -NoTypeInformation -Encoding UTF8
$data|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "mailbox_inventory_$stamp.json") -Encoding UTF8
$checks|Export-Csv (Join-Path $OutputPath "readiness_checks_$stamp.csv") -NoTypeInformation -Encoding UTF8
$template='Review mailbox quota usage','Review archive enablement','Review inactive mailboxes','Review forwarding settings','Review shared mailbox licensing','Review retention requirements'|ForEach-Object{[PSCustomObject]@{ReviewItem=$_;Status='Not assessed';Notes=''}}
$template|Export-Csv (Join-Path $OutputPath "mailbox_review_template_$stamp.csv") -NoTypeInformation -Encoding UTF8
$html="<h1>Exchange Mailbox Health</h1><p>Generated $(Get-Date)</p><h2>Readiness</h2>$($checks|ConvertTo-Html -Fragment)<h2>Mailbox Inventory</h2>$($data|ConvertTo-Html -Fragment)<h2>Review Template</h2>$($template|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Exchange Mailbox Health'|Set-Content (Join-Path $OutputPath "exchange_mailbox_health_$stamp.html") -Encoding UTF8
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
