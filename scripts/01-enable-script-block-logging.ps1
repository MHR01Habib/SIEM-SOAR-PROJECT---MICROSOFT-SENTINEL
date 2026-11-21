# Run on vm-soc-win (elevated). Enables PowerShell Script Block Logging -> Event 4104
# in Microsoft-Windows-PowerShell/Operational.
$p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $p -Force | Out-Null
Set-ItemProperty -Path $p -Name EnableScriptBlockLogging -Value 1
Write-Output "Script Block Logging enabled"
