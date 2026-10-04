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
