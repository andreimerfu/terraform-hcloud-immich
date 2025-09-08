## 1.0.0 (2025-09-08)

### ⚠ BREAKING CHANGES

* Module source path changed to andreimerfu/hcloud-immich/hcloud

### Features

* update repository name to terraform-hcloud-immich for proper HashiCorp Registry ([2f20236](https://github.com/andreimerfu/terraform-hcloud-immich/commit/2f20236f7828afebd3a9b069be5639ccae64ba40))

### Bug Fixes

* add proper GitHub Actions permissions for semantic-release ([e603eed](https://github.com/andreimerfu/terraform-hcloud-immich/commit/e603eedb8cd1cb721eb19a0c873abb6af1a45eb7))
* configure semantic-release for registry publication ([fe680a8](https://github.com/andreimerfu/terraform-hcloud-immich/commit/fe680a88f0ea1cd4adc911f197819ef5df486fb3))
* resolve CI failures by adding missing existing_subnet_id variable and fixing formatting ([881bc97](https://github.com/andreimerfu/terraform-hcloud-immich/commit/881bc9781a90ac2bf7add478558bfd97f386473f))

## [2.0.0](https://github.com/andreimerfu/terraform-hcloud-immich/compare/v1.0.0...v2.0.0) (2025-09-08)

### ⚠ BREAKING CHANGES

* Module source path changed to andreimerfu/hcloud-immich/hcloud

### Features

* update repository name to terraform-hcloud-immich for proper HashiCorp Registry ([2f20236](https://github.com/andreimerfu/terraform-hcloud-immich/commit/2f20236f7828afebd3a9b069be5639ccae64ba40))

## 1.0.0 (2025-09-08)

### Bug Fixes

* add proper GitHub Actions permissions for semantic-release ([e603eed](https://github.com/andreimerfu/terraform-immich-hetzner/commit/e603eedb8cd1cb721eb19a0c873abb6af1a45eb7))
* configure semantic-release for registry publication ([fe680a8](https://github.com/andreimerfu/terraform-immich-hetzner/commit/fe680a88f0ea1cd4adc911f197819ef5df486fb3))
* resolve CI failures by adding missing existing_subnet_id variable and fixing formatting ([881bc97](https://github.com/andreimerfu/terraform-immich-hetzner/commit/881bc9781a90ac2bf7add478558bfd97f386473f))

# Changelog

All notable changes to this Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial Terraform module for Immich deployment on Hetzner Cloud
- Unlimited photo storage via Backblaze B2 and JuiceFS integration
- Automatic SSL certificates with Let's Encrypt
- Complete CI/CD pipeline with GitHub Actions
- Security scanning with tfsec, Checkov, and Trivy
- Semantic versioning and automated releases
- Comprehensive documentation and examples

### Features
- Cost-optimized deployment (€8-12/month for families)
- AI-powered photo management with Immich
- Mobile app support with automatic backup
- Family sharing and album management
- Complete infrastructure as code
- Automated security updates and monitoring

### Infrastructure
- Hetzner Cloud CX22 server (2 vCPU, 8GB RAM)
- 20GB SSD volume for system and database
- Private networking with firewall protection
- JuiceFS filesystem for unlimited B2 storage
- Docker Compose service management
- Systemd integration for auto-start services

<!-- 
## [1.0.0] - YYYY-MM-DD

### Added
- Initial release

### Changed
- 

### Deprecated
- 

### Removed
- 

### Fixed
- 

### Security
- 
-->

## [0.1.0] - Initial Development

### Added
- Basic Terraform module structure
- Hetzner Cloud infrastructure resources
- Immich application deployment
- JuiceFS and Backblaze B2 integration
- Documentation and examples
