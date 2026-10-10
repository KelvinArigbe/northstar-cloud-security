# SEC-004 — Excessive Azure Privilege & Cloud Compromise

## Severity
Critical

## Summary
A former intern account remained enabled four months after departure with Contributor access across the production Azure subscription.

The identity authenticated and performed unauthorized actions including retrieving Storage Account keys, modifying a production VM, and changing an NSG rule to permit SSH from any source.

Subsequent investigation identified successful external SSH access to the production VM, root-level script execution, persistence mechanisms, application-secret exposure, monitoring disruption, unauthorized Storage access, and production database access.

## Key Findings

- Former intern account remained enabled with excessive production privileges.
- `finance-api-sp` had unnecessary Owner access at subscription scope.
- Production Storage Account keys were retrieved and subsequently used.
- NSG SSH source was changed from `10.20.0.0/16` to `*`.
- External SSH authentication to `vm-finance-api-02` succeeded.
- Malicious script executed with root privileges.
- Root SSH and SUID-based persistence were established.
- Application secrets were exposed.
- Azure monitoring was stopped.
- Production Storage and database resources were accessed using compromised credentials.
- A query against `customer_transactions` returned 18,432 rows.

## Containment & Remediation

1. Block the compromised identity and revoke active sessions.
2. Isolate the compromised VM while preserving forensic evidence.
3. Revoke and replace compromised SSH credentials.
4. Rotate Storage Account keys and exposed application secrets.
5. Restore the unauthorized NSG modification.
6. Investigate Storage and database activity for unauthorized access.
7. Rebuild the compromised VM from a trusted source.
8. Hunt for related indicators and persistence across the environment.
9. Review privileged Azure RBAC assignments.
10. Implement stronger identity offboarding and periodic access reviews.

## Root Cause

The incident was enabled by inadequate identity lifecycle management and excessive Azure RBAC permissions. A temporary account remained enabled after the user's departure and retained Contributor access across the production subscription.

## Security Lessons

- Apply least privilege at the smallest practical scope.
- Remove temporary access when the business requirement ends.
- Offboarding must revoke identities, sessions, credentials, and privileged assignments.
- Credential compromise can allow an attacker to retain access after the original identity is disabled.
- Cloud incident response must follow the complete attack path and determine blast radius rather than focusing only on the initial compromised identity.

## Lab Note

This case is a controlled security engineering simulation. No production or customer systems were affected.
