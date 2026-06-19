# Exchange Mailbox Health Toolkit

A read-only PowerShell toolkit for Exchange mailbox review preparation.

## Features

- Exchange Online module check
- Mailbox assessment checklist
- Sample CSV import mode for offline demonstrations
- CSV, JSON, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Exchange_Mailbox_Health_Toolkit.ps1
```

Use a sample CSV:

```powershell
.\Exchange_Mailbox_Health_Toolkit.ps1 -InputCsv .\mailboxes.csv
```

## Safety

Read-only and documentation-focused. It does not change mailbox settings.
