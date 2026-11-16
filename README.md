# SIEM-SOAR-PROJECT---MICROSOFT-SENTINEL
I built my own security operations center in Microsoft Azure. It collects logs from a Windows server, uses Microsoft Sentinel to catch attacks, and automatically locks the hacked account. Then I attacked it myself and investigated what happened.

<img width="3200" height="3488" alt="soc-lab-monitoring-dashboard (1)" src="https://github.com/user-attachments/assets/474ea304-4901-4c1c-b4fb-0e8b48214fb7" />

## Overview

This project is a cloud-based Security Operations Center (SOC) that I designed, built, and tested in Microsoft Azure.

My environment collects security logs from a Windows server and sends them to **Microsoft Sentinel**, Microsoft's cloud SIEM (Security Information and Event Management) platform. Custom detection rules watch those logs for signs of an attack. When a threat is found, Sentinel creates an incident. An automated playbook (SOAR: Security Orchestration, Automation, and Response) then alerts me by email and disables the compromised account on its own.

To prove the system works, I attacked my own environment from a second machine, investigated the alerts like a SOC analyst, and documented the results, including what worked and what didn't.

The dashboard above is a custom Sentinel workbook I built to monitor the environment in one place.

---

## Why I Built This

I am working toward a career in cybersecurity, with a focus on identity and access management (IAM) and security operations. I wanted hands-on experience with the same tools and workflows used by real SOC teams, not just knowledge from reading.

My goals for this project were to:

- Understand how security data moves from a server into a SIEM
- Write my own detection rules instead of relying only on built-in ones
- Automate a response so threats are contained faster than a person could react
- Experience an attack from both sides, as the attacker and as the defender
- Practice investigating and documenting an incident professionally

---

## How the Environment Works

1. **Two virtual machines** run inside the same Azure virtual network:
   - `vm-soc-win`: the Windows Server being monitored (the target)
   - `vm-attacker`: a second machine used to simulate a hacker
2. **The Azure Monitor Agent** on the target collects Windows Security logs and PowerShell activity logs.
3. **Data collection rules** send those logs to a **Log Analytics workspace**, where they are stored and searchable.
4. **Microsoft Sentinel** runs my detection rules against the logs every few minutes and creates incidents when something matches.
5. **An automation rule** hands certain incidents to a **Logic App playbook**, which emails me and disables the affected account on the server.

**Security controls:** Remote Desktop access to the server is limited to my IP address only through a network security group. The playbook uses a managed identity with permission to manage only that one server, so no passwords or keys are stored anywhere.

---

## Detection Rules

I wrote five detection rules in **KQL (Kusto Query Language)**. Each one is mapped to a technique in the **MITRE ATT&CK** framework, the industry-standard catalog of attacker behavior.

| Rule | What It Detects | Severity | MITRE ATT&CK |
|---|---|---|---|
| Brute Force – Multiple Failed Logons | 10 or more failed logins in a short time | Medium | T1110 – Brute Force |
| Successful Login After Brute Force | A successful login following repeated failures | High | T1078 – Valid Accounts |
| Suspicious PowerShell Activity | PowerShell commands commonly used to download or hide malware | Medium | T1059.001 – PowerShell |
| New User Account Created | A new local account appearing on the server | Medium | T1136 – Create Account |
| User Added to Privileged Group | An account being added to the Administrators group | High | T1098 – Account Manipulation |

Each rule also maps the account, computer, and IP address involved, so Sentinel can link related alerts together during an investigation.

---

## Automated Response (SOAR)

I built a playbook called **AutoDisableAndNotify** using Azure Logic Apps. When it runs, it:

1. Sends me an email with the incident name and severity
2. Connects to the server through the Azure VM Run Command API
3. Runs a PowerShell command that disables the compromised account

This turns a response that could take an analyst several minutes into one that happens within seconds of an alert.

---

## Attack Simulation

On October 26, 2026, I ran a full attack against my own environment to test every part of the system.

| Step | Attacker Action | Result |
|---|---|---|
| 1 | Guessed passwords over the network against two accounts | 64 failed logins recorded |
| 2 | Guessed the correct password for a test account | Attacker successfully logged in |
| 3 | Ran PowerShell commands that look like a malware download | Logged and flagged |
| 4 | Created a hidden "backdoor" account | Logged and flagged |
| 5 | Added the backdoor account to the Administrators group | Logged and flagged as High severity |

The entire attack, from the first failed login to the new admin account, took about **13 minutes**.

---

## Investigation

After the alerts came in, I investigated using KQL. By searching for all activity from the attacker's IP address, I confirmed:

- **64 failed login attempts** against the `administrator` and `testvictim` accounts
- **2 successful logins** to `testvictim` from the same IP address immediately afterward

Many failed logins followed by a success from the same source is a clear sign that the password was guessed. I then built a full timeline, identified the backdoor account as the attacker's persistence method, and recorded the findings in an incident report.

---

## Results

- **22 incidents** were created by Sentinel during testing
- **4 of my 5 rules** detected the attack as designed
- The playbook **disabled the compromised account** and sent the email alert automatically
- The dashboard gave a clear, single view of the attack as it happened

### What Didn't Work

My **"Successful Login After Brute Force"** rule did not fire, even though the attacker did break in. The rule grouped events into fixed 10-minute blocks of time. The failed logins started in one block, and the successful login happened in the next, so the rule never saw them together.

This was the most valuable finding of the project. It showed me that detection rules have to be tested against real attacks, because a rule that looks correct on paper can still miss a breach. The fix is to compare events across a sliding time window instead of fixed blocks.

I also noticed that the PowerShell rule created several duplicate incidents for the same activity. In a real SOC this creates alert fatigue, so grouping related alerts together would be the next improvement.

## Tools & Technologies

Microsoft Azure · Microsoft Sentinel · Log Analytics · Azure Monitor Agent · KQL · Azure Logic Apps · Managed Identity · Azure RBAC · Network Security Groups · PowerShell · Windows Server 2025 · MITRE ATT&CK

---
*This project was built in an isolated lab environment that I own. All attacks were performed against my own virtual machines for learning purposes.*
