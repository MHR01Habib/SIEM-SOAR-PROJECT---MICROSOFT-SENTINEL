# Scripts

| Script | Runs on | Purpose |
|---|---|---|
| `01-enable-script-block-logging.ps1` | vm-soc-win | Turns on Event 4104 logging |
| `02-prepare-target.ps1` | vm-soc-win | Creates `testvictim`, opens SMB, disables lockout (lab only) |
| `03-attack-simulation.ps1` | vm-attacker | SMB brute force, then a successful logon |
| `04-post-compromise-simulation.ps1` | vm-soc-win | Suspicious PowerShell, backdoor account, admin group add |
| `05-cleanup.ps1` | vm-soc-win | Undoes everything above |

Passwords are prompted at runtime, so none are stored in this repo. Run these only against machines you own.
