# Playbook: AutoDisableAndNotify

A Logic App (Consumption) in resource group `rg-soc-automation`, North Central US.

## Flow
1. **Trigger:** Microsoft Sentinel incident
2. **Entities - Get Accounts:** pulls the account entities from the incident (ready for the planned upgrade below)
3. **HTTP:** POST to the Azure VM Run Command API (see [`http-action.json`](http-action.json)), which runs `Disable-LocalUser` on `vm-soc-win`
4. **Send an email (V2):** subject `Sentinel Alert: [Incident Title] Severity: [Incident Severity]`

## Identity and permissions
| Who | Role | Scope | Why |
|---|---|---|---|
| Playbook system-assigned managed identity | Virtual Machine Contributor | `vm-soc-win` | Lets the playbook call Run Command, and nothing else |
| Azure Security Insights (Sentinel service principal) | Microsoft Sentinel Automation Contributor | `rg-soc-automation` | Lets Sentinel trigger playbooks in that RG |

No passwords, keys or connection secrets are stored for the VM action. The HTTP action authenticates as the managed identity with audience `https://management.azure.com`.

## Automation rule
- **When:** incident is created
- **Condition:** analytics rule name contains *Successful Login After Brute Force*
- **Action:** run playbook `AutoDisableAndNotify`

## Limitations
- The account to disable (`testvictim`) is **hardcoded** in the script. Next step: read the Account entity from the incident (`Entities - Get Accounts`) and pass it into the script.
- The automation rule depends on Rule 2, which missed the breach in testing because the account name was recorded differently in the failed and successful logons (see the detections README). The playbook itself works (the alert email came from a run on a Suspicious PowerShell incident), but automatic containment is only as good as the detection in front of it.
- The attacker's `backdoor_svc` admin account was not touched by the playbook. A T1098 response path would be the next addition.
- Run Command is asynchronous. The HTTP action returns 202 before the script finishes.
