# SEC-001 — Azure Infrastructure Security Review

## Scenario

Northstar Financial Services planned to deploy an internet-facing customer
application using Terraform.

As the Cloud Security Engineer, I was tasked with reviewing the proposed
Azure infrastructure before production deployment.

## Objectives

- Review Terraform infrastructure for security weaknesses
- Identify and assess cloud security risks
- Recommend remediation
- Implement security improvements in Terraform
- Validate the remediated configuration

## Key Findings

The review identified:

- Anonymous blob-level access to customer documents
- Overly permissive inbound NSG access
- Disabled Azure Key Vault purge protection
- Unnecessary public network exposure of backend storage
- Insufficient centralized security logging and monitoring
- A resilience concern requiring validation of LRS against business RPO/RTO

## Remediation

The Terraform configuration was modified to:

- Require private access to the customer document container
- Disable unnecessary public network access to storage
- Remove unrestricted inbound network access
- Permit only required HTTPS traffic
- Enable Key Vault purge protection

## Validation

The remediated Terraform configuration was formatted and validated locally using:

`terraform fmt`

`terraform validate`

Terraform validation completed successfully.

No Azure resources were deployed as part of this lab.

## Skills Demonstrated

Azure Security • Terraform • Infrastructure as Code • Network Security •
Azure Storage Security • Azure Key Vault • Defense in Depth • Least Privilege •
Security Architecture Review


## Additional implementation boundary

The secure Terraform variant disables public network access to the storage account but does not create a Private Endpoint, subnet integration, or private DNS zone. This is an intentional scope boundary for this review exercise, not a complete working application connectivity design. Before deploying the secure configuration, design and validate the private connectivity path required by the application. The resource names are illustrative and may need to be changed to meet Azure global naming requirements.


## Remediation status

| Review item | Current secure Terraform state | Status |
|---|---|---|
| Anonymous blob access | Container access set to `private` | Implemented in configuration |
| Unrestricted inbound management rule | Broad `Allow-Management` rule removed; HTTPS 443 remains | Implemented in configuration |
| Key Vault purge protection | `purge_protection_enabled = true` | Implemented in configuration |
| Centralized diagnostic logging | No diagnostic settings or Log Analytics resources in this case's Terraform | Open — not implemented |
| Storage public network access | `public_network_access_enabled = false` | Implemented in configuration; private endpoint and private DNS path remain open |
| Storage resilience | Replication remains LRS | RPO/RTO review remains open |

The CI workflow checks Terraform formatting and runs `terraform validate` for both variants. It does not run `terraform plan` against a subscription or deploy resources. A successful validation is a syntax/provider-schema check, not deployment evidence.
