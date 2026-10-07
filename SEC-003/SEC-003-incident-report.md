# SEC-003 — Linux Workload Compromise Investigation

## Severity
Critical — Confirmed Host Compromise

## Executive Summary

Northstar Financial Services detected abnormal CPU utilization and unexplained outbound network activity on the production Linux workload `northstar-api-01`.

Initial live-state investigation did not identify active CPU pressure, suspicious established connections, abnormal disk utilization, or an obvious malicious process.

Historical investigation subsequently identified suspicious activity associated with the `deploy` account.

The account authenticated through SSH and subsequently accessed application configuration, prepared and executed `/tmp/.system-update` with root privileges.

Further telemetry established that the executable accessed application secrets and SSH credential material, communicated with external infrastructure, and established persistence through a systemd service.

The host should therefore be treated as fully compromised.

## Investigation

### Initial Host Triage

Live investigation included review of:

- System load
- Running processes
- Listening network services
- Established connections
- Filesystem utilization
- Process relationships
- Authentication telemetry

No active compromise was visible during initial live-state investigation.

This demonstrated the importance of historical evidence when suspicious activity is no longer occurring.

## Authentication Activity

At 02:14:42, the `deploy` account successfully authenticated using an SSH public key from:

`203.0.113.42`

The session remained active for approximately 13 minutes.

During the session, the account:

1. Checked the status of `northstar-api`.
2. Read `/etc/northstar-api/app.env`.
3. Made `/tmp/.system-update` executable.
4. Executed `/tmp/.system-update` with root privileges.

## Suspicious Artifact

Artifact:

`/tmp/.system-update`

Characteristics:

- ELF 64-bit executable
- Approximately 1.8 MB
- Owned by `deploy`
- Executed with root privileges

SHA-256:

`7c92b73c5a8d41f6e91877e934f7a53b9b24c72334f95d6c2f4eec739a782115`

## Post-Execution Activity

Telemetry showed the suspicious executable:

- Accessed `/etc/northstar-api/app.env`
- Accessed `/home/deploy/.ssh/id_ed25519`
- Established a connection to `45.77.89.12:443`
- Created `/etc/systemd/system/system-update.service`
- Enabled the new systemd service
- Started the service
- Continued outbound communication through `/usr/local/bin/system-update`

## Persistence

Persistence was established through:

`system-update.service`

The service was enabled through systemd, allowing the malicious process to restart independently of the original SSH session.

This meant terminating the SSH session alone would not contain the compromise.

## Credential Exposure

The following should be treated as compromised:

- `deploy` SSH private key
- Secrets contained within `/etc/northstar-api/app.env`

Any identities, databases, APIs, storage systems or other resources accessible using these credentials require investigation.

## Blast Radius

### Confirmed Compromise

- `northstar-api-01`
- Unauthorized `system-update.service`
- Application secrets accessed by the malicious process
- `deploy` SSH private key

### Potential Compromise

- Systems accessible using the deploy SSH identity
- Production database
- APIs referenced by application secrets
- Cloud resources accessible using exposed credentials
- Additional hosts contacted using compromised credentials

## Containment and Recovery

Recommended response:

1. Preserve relevant logs, suspicious artifacts, hashes and forensic evidence.
2. Isolate `northstar-api-01` from unnecessary network communication.
3. Revoke and replace the compromised deploy SSH credential.
4. Rotate secrets exposed through `app.env`.
5. Investigate use of exposed credentials across the environment.
6. Remove identified malicious persistence after evidence preservation.
7. Rebuild the compromised workload from a trusted source where appropriate.
8. Hunt across the environment for the malicious hash, suspicious IP, persistence mechanism and compromised credentials.
9. Increase monitoring following recovery.

## Key Engineering Lessons

Live system state alone cannot establish whether historical compromise occurred.

Suspicious artifacts should be preserved and investigated before destructive remediation.

Removing malware does not necessarily remove attacker access.

Incident response must address identity compromise, persistence, credential exposure, lateral movement and downstream blast radius.

A root-level compromise can require recovery from a known-good state rather than relying solely on manual artifact removal.

## Environment

This investigation was performed as a controlled security engineering simulation. No production infrastructure or real customer systems were affected.
