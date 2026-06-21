#requires -Version 5.1
<# Created by Dewald Pretorius. Read-only Exchange Online mailbox validator. #>
[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)][string]$Identity,
 [ValidateRange(1,100)][int]$MaximumDeletedItemPercent=80,
 [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Exchange_Mailbox_Health_Reports')
)
$ErrorActionPreference='Stop';$ExitHealthy=0;$ExitWarning=1;$ExitPrerequisite=3;$ExitFailure=5
try{
 New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss
 if(-not(Get-Command Get-EXOMailbox -ErrorAction SilentlyContinue)){Write-Error 'Connect-ExchangeOnline is required before running this validator.';exit $ExitPrerequisite}
 $mailbox=Get-EXOMailbox -Identity $Identity -Properties DisplayName,PrimarySmtpAddress,RecipientTypeDetails,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota -ErrorAction Stop
 $stats=Get-EXOMailboxStatistics -Identity $Identity -Properties ItemCount,DeletedItemCount,TotalItemSize,TotalDeletedItemSize,LastLogonTime -ErrorAction Stop
 $deletedPercent=if(($stats.ItemCount+$stats.DeletedItemCount)-gt 0){[math]::Round(($stats.DeletedItemCount/($stats.ItemCount+$stats.DeletedItemCount))*100,2)}else{0}
 $warnings=@();if($deletedPercent -ge $MaximumDeletedItemPercent){$warnings+="Deleted item ratio is $deletedPercent%."};if(-not $stats.LastLogonTime){$warnings+='No last logon time was returned.'}
 $result=[ordered]@{Generated=(Get-Date);Identity=$Identity;Mailbox=$mailbox;Statistics=$stats;DeletedItemPercent=$deletedPercent;Findings=$warnings;Status=$(if($warnings.Count){'Warning'}else{'Healthy'})}
 $result|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $OutputPath "mailbox_health_$stamp.json") -Encoding UTF8
 if($warnings.Count){$warnings|ForEach-Object{Write-Warning $_};exit $ExitWarning}
 Write-Host 'Mailbox health validation passed.' -ForegroundColor Green;exit $ExitHealthy
}catch{Write-Error $_.Exception.Message;exit $ExitFailure}
