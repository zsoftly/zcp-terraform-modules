# Changelog

This file documents all notable changes to the Apache CloudStack Terraform
modules. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [v1.0.0] - 2026-07-14

Initial public release of the Apache CloudStack Terraform modules by ZSoftly.

### Added

9 modules for Apache CloudStack infrastructure and workload provisioning:

- `networking` - VPCs, VPC tiers/networks, IP ranges, and ACLs
- `compute` - Instances, SSH keypairs, affinity groups, and data disks
- `load-balancing-security` - Public IPs, firewall rules, NAT, and load
  balancing
- `storage` - Volumes, attachments, and snapshot policies
- `kubernetes` - CKS clusters and node sizing
- `accounts-projects` - Domains, accounts, users, roles, projects, and quotas
- `vpn-connectivity` - Site-to-site VPN gateway and connections
- `images-templates` - Template registration, versioning, and sharing
- `stacks` - App stack selection and cloud-init userdata rendering (in progress)

Examples:

- `examples/demo-stack` - Composable demo stack using all modules, with a full
  `terraform.tfvars.example`
- `examples/test-images-templates` - End-to-end test for the stacks module

Provider: `cloudstack/cloudstack ~> 0.6`. Requires Terraform >= 1.5.
