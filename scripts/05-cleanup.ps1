# Run on vm-soc-win (elevated). Returns the host to a safe state after the lab.
Remove-LocalGroupMember -Group "Administrators" -Member "backdoor_svc" -ErrorAction SilentlyContinue
Remove-LocalUser -Name "backdoor_svc" -ErrorAction SilentlyContinue
Remove-LocalUser -Name "testvictim"   -ErrorAction SilentlyContinue
Disable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
net accounts /lockoutthreshold:5
Write-Output "Lab artifacts removed, SMB closed, lockout restored"
# Then stop/deallocate both VMs in the Azure portal so they stop billing.
