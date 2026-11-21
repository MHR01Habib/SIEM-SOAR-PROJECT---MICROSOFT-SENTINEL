# Detections

Five scheduled analytics rules in Microsoft Sentinel. Each file has the rule's settings in its header comments: severity, MITRE technique, schedule and entity mapping.

| File | Rule | MITRE | Fired in attack test |
|---|---|---|---|
| `01-brute-force-failed-logons.kql` | Brute Force – Multiple Failed Logons | T1110 | ✅ |
| `02-successful-login-after-brute-force.kql` | Successful Login After Brute Force | T1110, T1078 | ❌ account-name mismatch (see below) |
| `02b-successful-login-after-brute-force-improved.kql` | Improved version of rule 2 | T1110, T1078 | ✅ caught the attack when tested on the logs |
| `03-suspicious-powershell-4104.kql` | Suspicious PowerShell Activity | T1059.001 | ✅ (but created duplicate incidents) |
| `04-new-user-account-created.kql` | New User Account Created | T1136 | ✅ |
| `05-user-added-to-privileged-group.kql` | User Added to Privileged Group | T1098 | ✅ |
| `hunting-breach-confirmation.kql` | Hunting: activity by source IP | – | used in investigation |

## Creating a rule
Sentinel → Analytics → Create → Scheduled query rule → paste the query → set the schedule and threshold (> 0 results) → map entities → enable incident creation.

## Why rule 2 missed the breach
Windows recorded the failed logons as `vm-attacker\testvictim` and the successful logon as `vm-soc-win\testvictim`. The rule joined on the full account name, which needs an exact match, so it never paired them. The improved version matches on the username alone and looks for a success within 30 minutes of the failures. Run against the attack logs, it found 34 failures from 172.16.1.4 followed by a successful logon at 04:36:18 UTC.
