# Run on vm-soc-win (elevated). LAB ONLY: weakens the host so the attack can run.
# Undo everything with 05-cleanup.ps1 when you are done.

# Victim account with a deliberately weak password (choose your own lab-only value)
$pw = Read-Host -AsSecureString "Weak lab password for testvictim"
New-LocalUser -Name "testvictim" -Password $pw -FullName "Test Victim Account" -Description "Making this account for a home lab"

# Allow SMB from the attacker VM. The NSG already allows traffic inside the VNet,
# but the Windows firewall blocked it ("network path not found") until this group was enabled.
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

# Disable account lockout so the brute force isn't stopped at the threshold
net accounts /lockoutthreshold:0
