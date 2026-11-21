# Run on vm-soc-win (elevated) to simulate what an attacker does after getting in.
# LAB ONLY. The PowerShell is harmless: it only prints the strings the detection looks for.

# --- Execution (T1059.001) -> 4104 with download-cradle keywords ---
Invoke-Expression "Write-Output 'IEX New-Object Net.WebClient DownloadString FromBase64String EncodedCommand attack-phase'"

# --- Persistence (T1136) -> 4720 ---
$pw = Read-Host -AsSecureString "Lab password for backdoor_svc"
New-LocalUser -Name "backdoor_svc" -Password $pw -Description "simulated backdoor"

# --- Privilege escalation (T1098) -> 4732 ---
Add-LocalGroupMember -Group "Administrators" -Member "backdoor_svc"
