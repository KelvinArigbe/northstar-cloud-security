![GitHub Actions](https://github.com/KelvinArigbe/northstar-cloud-security/actions/workflows/validate.yml/badge.svg?branch=main)

# Northstar Cloud Security — Engineering Case Studies

A portfolio of Azure cloud-security engineering exercises covering infrastructure security reviews, identity compromise investigations, Linux workload compromise, excessive privilege, and secure network design.

**Scope:** These are controlled portfolio simulations and infrastructure-review exercises. Names, organizations, identities, tenant data, log records, and incident details are fictional. No real customer environment or Northstar production system is represented.

## Case-study index

| ID | Case | Work performed | Evidence in repository | Status / boundary |
|---|---|---|---|---|
| SEC-001 | Azure infrastructure security review | Compared intentionally insecure and remediated Terraform configurations; documented storage, NSG, Key Vault, logging and resilience findings | Insecure and secure Terraform files; review report | Terraform syntax validation; no Azure resources deployed. Secure variant disables public storage access but does not yet provide a Private Endpoint or private DNS path |
| SEC-002 | Entra ID identity compromise | Investigated suspicious sign-ins, privilege changes, service-principal credential creation and Key Vault secret access | Synthetic sign-in and audit CSVs; incident report | Tabletop/data-driven simulation; no live Entra tenant or KQL query files included |
| SEC-003 | Linux workload compromise | Reconstructed SSH access, privileged execution, credential exposure and persistence | Synthetic `auth.log`; incident report | Simulated incident. Additional endpoint/process/network telemetry is described in the report but not included as raw evidence files |
| SEC-004 | Excessive Azure privilege and cloud compromise | Assessed over-privileged identities and traced a simulated attack path from RBAC and Storage key exposure to VM compromise | Synthetic role-assignment CSV; disarmed script sample; incident report | Simulated incident. Full Azure/VM/Storage/database telemetry is not included |
| SEC-005 | Secure Azure network architecture | Designed web/API/data segmentation, WAF ingress, Bastion administration, private Key Vault and database connectivity | Network design document | Architecture proposal only; no Terraform implementation or live network deployment |

## Repository structure

```text
northstar-cloud-security/
├── .github/
│   └── workflows/
│       └── validate.yml
├── SEC-001/
│   ├── insecure/
│   │   └── main.tf
│   ├── secure/
│   │   ├── main.tf
│   │   └── .terraform.lock.hcl
│   ├── README.md
│   └── SEC-001-security-review.md
├── SEC-002/
│   ├── evidence/
│   │   ├── audit_logs.csv
│   │   └── signin_logs.csv
│   └── SEC-002-incident-report.md
├── SEC-003/
│   ├── evidence/
│   │   └── auth.log
│   └── SEC-003-incident-report.md
├── SEC-004/
│   ├── evidence/
│   │   ├── role_assignments.csv
│   │   └── update-script.txt
│   └── SEC-004-incident-report.md
├── SEC-005/
│   └── SEC-005-network-design.md
└── README.md
```

## How to use the case studies

Each case is intended to be read as a small engineering engagement:

1. Read the scenario and identify the business assets and security objectives.
2. Review the supplied code or evidence before reading the conclusions.
3. Separate directly observed facts from hypotheses, assumptions and recommended actions.
4. Check whether the proposed remediation is actually represented in code or is only a recommendation.
5. Record validation performed and remaining gaps.

Do not treat an incident narrative as proof of a real compromise. Evidence files are synthetic training data, and some case reports include scenario details that are not reproduced as raw telemetry in the repository.

## SEC-001 — Terraform security review

The two Terraform variants illustrate an intentionally insecure baseline and a hardened configuration.

Key review topics:

- Anonymous access to customer document blobs.
- Broad inbound NSG management access.
- Key Vault purge protection.
- Public network exposure of backend storage.
- Diagnostic logging and monitoring gaps.
- Storage redundancy and business RPO/RTO considerations.

The tenant ID is read from the active Azure CLI context using the AzureRM provider's `azurerm_client_config` data source. Terraform validation does not deploy resources or prove that the architecture is reachable.

**Important networking gap:** The secure variant disables public network access to Storage but does not create the Private Endpoint, subnet integration, or private DNS zone required for a private application connectivity path. That work remains open and is documented in the SEC-001 case README.

### Validate SEC-001 locally

Prerequisites: Terraform CLI and Azure CLI installed. Authentication is not needed for `terraform validate`, but provider installation requires network access.

```bash
cd SEC-001/insecure
terraform init -backend=false
terraform fmt -check
terraform validate

cd ../secure
terraform init -backend=false
terraform fmt -check
terraform validate
```

## SEC-002 — Entra ID identity compromise

The synthetic sign-in and audit records describe a user authenticating from an unfamiliar location/device, followed by service-principal credential creation, privilege assignment, and Key Vault secret retrieval.

Investigation themes:

- Failed-to-successful authentication sequences.
- Unfamiliar device and location context.
- Privilege escalation and persistence.
- Key Vault access and credential exposure.
- Identity containment, session revocation, credential rotation and blast-radius review.

The included CSV files are the source evidence for this exercise. The case report describes investigation patterns, but KQL query files are not currently included.

## SEC-003 — Linux workload compromise

The case examines suspicious SSH authentication, application configuration access, privileged execution, credential exposure, external communication and systemd persistence.

The committed `auth.log` supports the authentication and sudo command sequence. The report also references additional simulated endpoint/process/network telemetry that is not included as raw files. Treat those additional details as scenario-provided context rather than independently reproducible evidence from `auth.log` alone.

The case emphasizes evidence preservation, host isolation, credential rotation, persistence hunting and rebuilding from a trusted image where appropriate.

## SEC-004 — Excessive privilege and cloud compromise

The scenario starts with stale, over-privileged access and follows a simulated path involving Storage key retrieval, NSG modification, remote VM access, persistence, credential exposure and monitoring disruption.

The repository includes a synthetic role-assignment inventory and a **disarmed** script excerpt. The script is commented out and is an analysis artifact only. Do not execute it. Full VM, Azure Activity Log, Storage and database telemetry is not included.

## SEC-005 — Secure network design

The design proposes:

- Application Gateway/WAF for public HTTPS ingress.
- Separate web, API and data subnets.
- Bastion or approved private administration rather than public SSH/RDP.
- Private connectivity to Key Vault and the database.
- Explicitly permitted application-tier flows and denied unnecessary paths.

This is a design document, not deployed infrastructure. No VNet, subnet, route-table, NSG, Bastion, WAF, Private Endpoint or private DNS resources are provisioned by this case.

## Validation automation

GitHub Actions runs Terraform formatting and validation for the SEC-001 insecure and secure variants. The workflow uses `terraform init -backend=false` and `terraform validate`; it does not run `terraform plan` against an Azure subscription and does not deploy resources.

A green validation run proves that Terraform can parse and validate the configuration with the selected provider version. It does **not** prove that resource names are globally available, that the selected region supports every SKU, that Azure policy permits deployment, or that private network connectivity works.

## Safety, privacy and evidence handling

- All incident identities, organization names, logs and role inventories are synthetic.
- Reserved documentation IP ranges are used for illustrative external addresses.
- The SEC-004 script sample is disarmed and must not be executed.
- Do not add real credentials, access tokens, tenant exports, customer data, or unredacted production logs.
- If a real secret is ever committed, revoke or rotate it. Deleting it from the current revision does not remove it from Git history.
- Terraform state, plans and local variable files are excluded through `.gitignore`.

## Planned improvements

1. Add a private endpoint and private DNS implementation to SEC-001, with a clearly defined application access path.
2. Add reproducible KQL query files for SEC-002 and document the tables/fields each query expects.
3. Add synthetic process, network and persistence telemetry to SEC-003 so each key conclusion maps to a committed evidence record.
4. Add a timestamped event timeline and supporting audit/VM/Storage evidence to SEC-004.
5. Implement SEC-005 as a separate Terraform or Bicep network lab and validate the proposed traffic flows.
6. Add a threat-model diagram and a concise executive summary for each case.

## Author

**Kelvin Arigbe** — [GitHub profile](https://github.com/KelvinArigbe)

---

These materials are educational simulations and engineering case studies. They are not a certification of production security, compliance, or successful deployment.
