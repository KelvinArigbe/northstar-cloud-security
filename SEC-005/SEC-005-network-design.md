# SEC-005 — Secure Azure Network Architecture

## Scenario

Northstar Financial Services is deploying a customer-facing payment application.

The original architecture placed the Web, API, and database tiers within a single subnet and allowed direct administrative access from the internet.

## Security Findings

1. SSH port 22 was exposed to the internet.
2. Web, API, and database workloads lacked network segmentation.
3. The production database had a public endpoint.
4. Key Vault allowed public network connectivity.
5. Administrators connected directly to VM public IP addresses.
6. Outbound network traffic was unrestricted.

## Proposed Architecture

Internet
    |
    v
Application Gateway + WAF
    |
    v
Web Subnet
    |
    | Required application traffic only
    v
API Subnet
    |
    +----> Key Vault
    |      Private Endpoint
    |      Managed Identity + RBAC
    |
    v
Database
Private connectivity only

Administrative Access:

Administrator
    |
    v
Azure Bastion
    |
    v
Private VM addresses

## Network Security Principles

### Internet Access

Allow HTTPS traffic required by the customer-facing application through the Application Gateway/WAF.

Backend workloads should not require direct public exposure.

### Administrative Access

Remove direct internet SSH/RDP access to application VMs.

Use Azure Bastion or approved private administrative connectivity.

### Segmentation

Separate Web, API, and data components into appropriate network security boundaries.

Permit only required communication between application tiers.

Example:

- Internet -> Application Gateway/WAF: Allow HTTPS 443
- Web -> API: Allow required application traffic
- API -> Database: Allow required database traffic
- API -> Web SSH 22: Deny
- Internet -> Database: Deny
- Internet -> Backend VMs SSH 22: Deny

### Key Vault

Disable unnecessary public network access.

Use a Private Endpoint for private connectivity where appropriate.

Use Managed Identity and RBAC so the application can access required secrets without storing Azure credentials.

### Database

Remove unnecessary public exposure and use private connectivity.

Restrict database access to the application components that require it.

## Security Outcome

The redesigned architecture reduces public exposure, improves segmentation, limits lateral movement, protects administrative access, and applies least-privilege principles to network and identity access.

## Lab Note

This case is a controlled cloud security engineering simulation. No production or customer systems were affected.
