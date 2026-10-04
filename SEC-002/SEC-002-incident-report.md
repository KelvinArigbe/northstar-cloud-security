# SEC-002 — Entra ID Identity Compromise Investigation

## Severity
P1 / Critical

## Executive Summary
A privileged finance user's Microsoft Entra ID account exhibited high-risk authentication activity from an unknown device and unexpected geographic location.

Investigation identified successful suspicious authentication followed by privileged Azure activity, including creation of a service principal credential, privilege modification, Key Vault access, and retrieval of a production database credential.

The evidence indicates likely account compromise with additional persistence and potential downstream impact.

## Key Findings

- High-risk authentication originated from an unknown device associated with Frankfurt shortly after legitimate activity from Lagos.
- Multiple failed authentication attempts were followed by successful Microsoft 365 and Azure Portal authentication.
- A new credential was added to `finance-automation-sp`.
- The account obtained Key Vault Secrets Officer privileges.
- An attempted modification of the Finance Administrators MFA Conditional Access policy failed.
- `kv-northstar-prod` was accessed.
- The `db-production-password` secret was successfully retrieved.
- Subsequent legitimate-looking activity from Daniel's known Lagos device strengthened the hypothesis of simultaneous unauthorized access.

## Blast Radius

### Confirmed
- Daniel's Entra ID identity
- Newly added `finance-automation-sp` credential
- `db-production-password`

### Potential
- Additional Key Vault secrets
- `finance-automation-sp`
- Production database
- Other Azure resources accessible through Daniel or the service principal

### No Confirmed Compromise
- Finance-Admins-MFA Conditional Access policy
- FIN-LAPTOP-07

## Containment Recommendations

1. Temporarily block Daniel's account and revoke active authentication sessions.
2. Perform controlled credential recovery for Daniel.
3. Identify and revoke the unauthorized credential added to `finance-automation-sp`.
4. Revert unauthorized privilege assignments.
5. Preserve relevant Entra ID, Azure, Key Vault and application audit evidence.
6. Rotate `db-production-password` and securely update legitimate dependencies.
7. Review production database authentication logs for use of the compromised credential.
8. Hunt for additional persistence, privilege changes and affected resources.

## Detection Engineering

Developed KQL investigation patterns for:

- User-specific authentication investigation
- High-risk sign-in identification
- Suspicious IP hunting
- Failed-to-successful authentication analysis
- Multi-location authentication detection

Detection tuning demonstrated reduction of simulated alert volume from 500 to 80 alerts per day after accounting for verified corporate VPN infrastructure while maintaining intended detection coverage.

Simulated alert reduction: 84%.

## Lessons Learned

MFA satisfaction alone does not prove that authentication was legitimate.

Incident containment must address both the initially compromised identity and any persistence mechanisms established after compromise.

Sensitive credentials retrieved during unauthorized access must be treated as compromised even after the attacker's original access path has been revoked.
