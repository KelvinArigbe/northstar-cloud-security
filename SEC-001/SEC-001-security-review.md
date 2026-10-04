# SEC-001 — Infrastructure Security Review

**Environment:** Northstar Financial Services — Production  
**Review Type:** Terraform / Azure Infrastructure Security Review  
**Status:** Changes Required

## Executive Summary

The proposed Terraform configuration contains several security weaknesses that should be addressed before production deployment.

The most significant risks involve anonymous access to customer documents, unrestricted inbound network traffic, unnecessary public exposure of backend storage, insufficient protection against permanent deletion of Key Vault objects, and lack of centralized security logging.

The current configuration should **not be approved for production deployment** until the High-severity findings are remediated.

---

## Finding 1 — Customer Document Container Allows Anonymous Blob Access

### Risk

The `customer-documents` storage container is configured with:

`container_access_type = "blob"`

This permits anonymous read access to individual blobs when their URLs are known or obtained.

Because the container will hold customer documents, leaked, exposed, logged, shared, or otherwise discovered blob URLs could result in unauthorized access to customer information without authentication.

### Severity

**High**

### Recommended Remediation

Configure the container for private access:

`container_access_type = "private"`

Access to customer documents should require authenticated and authorized identities. Where possible, Microsoft Entra ID and Azure RBAC should be preferred over broadly distributed storage credentials.

### Reasoning

Customer documents should not rely on the secrecy of blob URLs for protection. Authentication and authorization should be required before sensitive customer information can be retrieved.

---

## Finding 2 — Overly Permissive NSG Management Rule

### Risk

The `Allow-Management` NSG rule permits inbound traffic:

- From any source
- Using any protocol
- To any destination port
- To any destination covered by the rule

The rule therefore exposes workloads associated with the NSG to substantially more network traffic than required.

Its priority of `100` also means matching traffic is permitted before the more restrictive HTTPS rule at priority `110` needs to be evaluated.

An attacker could potentially reach unnecessary services running on protected workloads, increasing the attack surface and opportunities for exploitation.

### Severity

**High**

### Recommended Remediation

Remove the unrestricted `Allow-Management` rule.

If administrative access is required, create a separate least-privilege management path restricted to approved administrative sources and only the required protocols and ports.

The existing TCP/443 rule should remain because public HTTPS access is a legitimate requirement for the customer-facing application.

### Reasoning

Changing the priority of the unrestricted rule would not resolve the vulnerability because non-HTTPS traffic could still eventually match the permissive rule.

The rule itself must therefore be removed or significantly restricted.

This follows the principle of least privilege: permit only the network connectivity required for the workload to operate.

---

## Finding 3 — Key Vault Purge Protection Disabled

### Risk

The production Key Vault has:

`purge_protection_enabled = false`

If an attacker compromises a sufficiently privileged identity, or an authorized administrator makes a destructive mistake, deleted production secrets, keys, or certificates could potentially be permanently purged during the recovery period.

Loss of critical cryptographic material or application secrets could cause significant service disruption and may make some protected data inaccessible.

### Severity

**High**

### Recommended Remediation

Enable purge protection on the production Key Vault:

`purge_protection_enabled = true`

Access to destructive Key Vault operations should also follow least-privilege principles.

### Reasoning

Production secrets and cryptographic material are critical assets.

Purge protection provides an additional resilience control by preventing permanent destruction of deleted vault objects until the configured retention period expires.

This reduces the impact of both compromised privileged identities and accidental destructive actions.

---

## Finding 4 — Insufficient Centralized Security Logging and Monitoring

### Risk

The Terraform configuration does not demonstrate centralized collection of security-relevant resource telemetry through diagnostic settings or an equivalent monitoring architecture.

Without sufficient telemetry, the security team may have difficulty detecting or investigating activities such as unauthorized document access, suspicious Key Vault operations, configuration changes, or other malicious behavior.

For example, a compromised legitimate identity could potentially access large amounts of customer information without an appropriate detection mechanism alerting the security team.

### Severity

**Medium**

Severity should be reconsidered if Northstar has regulatory logging requirements or if no alternative centralized monitoring controls exist.

### Recommended Remediation

Configure appropriate diagnostic settings and security-relevant logging for production resources.

Required telemetry should be routed to Northstar's centralized security monitoring platform, such as Azure Log Analytics and Microsoft Sentinel where applicable.

Appropriate retention periods, detection rules, alerting, and access controls should also be established.

### Reasoning

Preventive controls cannot guarantee that compromise will never occur.

Security teams require sufficient telemetry to detect suspicious activity, investigate incidents, determine blast radius, and establish what actions occurred during a compromise.

Logging therefore forms an important component of defense in depth.

---

## Finding 5 — Unnecessary Public Network Exposure of Customer Storage

### Risk

The customer storage account has:

`public_network_access_enabled = true`

The business requirement states that customers need internet access to the web application. This does not necessarily require the backend storage service itself to be directly reachable through its public network endpoint.

Leaving the storage service publicly reachable increases the attack surface and places greater dependence on authentication and authorization controls.

If credentials, identities, SAS tokens, or other authorization mechanisms are compromised or misconfigured, an attacker already has network reachability to the storage service.

### Severity

**High**

### Recommended Remediation

Disable unnecessary public network access to the storage account and provide the application with an appropriately restricted connectivity path.

Where architecture and service requirements permit, consider private connectivity such as an Azure Private Endpoint and restrict access through network controls.

The application should authenticate to Storage using an appropriately scoped identity mechanism, such as a managed identity with Azure RBAC, rather than embedded long-lived credentials.

### Reasoning

The web application is the public-facing application layer; the storage account is part of the backend data layer.

There is no inherent requirement for both layers to have identical network exposure.

Restricting backend connectivity implements:

- Defense in depth
- Reduced attack surface
- Least privilege
- Zero Trust / assume breach principles

Authentication should not be the only security boundary protecting sensitive customer information.

---

## Architecture Observation — Storage Resilience

The storage account currently uses:

`account_replication_type = "LRS"`

LRS is not automatically a security vulnerability. However, because this storage account will contain production customer documents, the selected redundancy model should be validated against Northstar's business-continuity and disaster-recovery requirements.

Before approving the architecture, Security should request the application's required **Recovery Point Objective (RPO)** and **Recovery Time Objective (RTO)** and confirm whether LRS provides sufficient resilience.

Depending on those requirements, alternatives such as zone-redundant or geo-redundant storage may need to be evaluated.

The use of the `Standard` storage tier is not, by itself, considered a security finding.

---

# Security Review Decision

**CHANGES REQUIRED**

Production deployment should not proceed until the High-severity findings have been appropriately remediated or formally risk-accepted.

Following remediation, Security should perform a second review of the Terraform configuration before deployment approval.
