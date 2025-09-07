# Contributing to terraform-immich-hetzner

Thank you for your interest in contributing! This document provides guidelines for contributing to the Terraform module.

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://terraform.io) >= 1.0
- [Go](https://golang.org/dl/) 1.19+ (for testing)
- [terraform-docs](https://terraform-docs.io/) (for documentation)
- [tflint](https://github.com/terraform-linters/tflint) (for linting)
- [shellcheck](https://www.shellcheck.net/) (for shell script validation)

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/terraform-immich-hetzner.git
   cd terraform-immich-hetzner
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install development tools**
   ```bash
   # Install terraform-docs
   go install github.com/terraform-docs/terraform-docs@latest
   
   # Install tflint
   curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
   
   # Install shellcheck (Ubuntu/Debian)
   sudo apt-get install shellcheck
   ```

## 📝 Development Guidelines

### Code Standards

- **Terraform Style**: Follow [Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
- **Format Code**: Always run `terraform fmt -recursive` before committing
- **Validate Code**: Ensure `terraform validate` passes for all modules and examples
- **Variable Naming**: Use clear, descriptive names following snake_case convention
- **Comments**: Document complex logic and non-obvious decisions

### Module Structure

```
terraform-immich-hetzner/
├── main.tf              # Main infrastructure resources
├── variables.tf         # Input variables with validation
├── outputs.tf          # Module outputs
├── versions.tf         # Provider version constraints
├── README.md           # Module documentation
├── CHANGELOG.md        # Version history
├── examples/           # Usage examples
│   └── complete/       # Complete deployment example
└── .github/           # GitHub workflows and templates
```

### Variable Guidelines

- **Required vs Optional**: Minimize required variables, provide sensible defaults
- **Validation**: Add validation blocks for input parameters
- **Descriptions**: Provide clear, helpful descriptions
- **Types**: Use specific types (string, number, list, map) rather than any
- **Sensitive**: Mark sensitive variables appropriately

Example:
```hcl
variable "server_location" {
  description = "Hetzner Cloud server location"
  type        = string
  default     = "nbg1"
  
  validation {
    condition     = contains(["nbg1", "fsn1", "hel1", "ash", "hil"], var.server_location)
    error_message = "Server location must be one of: nbg1, fsn1, hel1, ash, hil."
  }
}
```

### Output Guidelines

- **Descriptive Names**: Use clear output names
- **Descriptions**: Always include meaningful descriptions
- **Sensitive Data**: Mark outputs containing secrets as sensitive
- **Useful Information**: Focus on information consumers actually need

## 🧪 Testing

### Local Testing

1. **Validate Syntax**
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Lint Code**
   ```bash
   tflint --recursive
   ```

3. **Validate Examples**
   ```bash
   cd examples/complete
   terraform init
   terraform validate
   ```

4. **Test Integration Script**
   ```bash
   ./validate-juicefs.sh
   ```

5. **Shell Script Validation**
   ```bash
   shellcheck *.sh
   ```

### CI/CD Testing

All pull requests automatically run:
- Terraform validation across multiple versions
- Security scanning (tfsec, Checkov, Trivy)
- Documentation checks
- Example validation
- Shell script linting

## 📚 Documentation

### README Updates

- Keep the README current with any new variables, outputs, or features
- Update usage examples when making changes
- Ensure the requirements table is accurate

### Auto-generated Documentation

We use `terraform-docs` to auto-generate parts of the README:

```bash
terraform-docs markdown table --output-file README.md .
```

### Examples

- Provide complete, working examples in the `examples/` directory
- Include `terraform.tfvars.example` files with example values
- Ensure examples demonstrate real-world usage

## 🔐 Security

### Security Best Practices

- Never commit secrets or sensitive data
- Use variable validation to prevent obvious misconfigurations
- Follow principle of least privilege for IAM/permissions
- Regularly update dependencies and providers

### Security Scanning

The CI pipeline includes multiple security tools:
- **tfsec**: Terraform security scanning
- **Checkov**: Infrastructure security analysis
- **Trivy**: Vulnerability scanning
- **GitLeaks**: Secret detection

## 🐛 Bug Reports

When reporting bugs, please include:
- Terraform version
- Module version
- Provider versions
- Complete error messages
- Minimal reproduction case
- Expected vs actual behavior

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml).

## 🚀 Feature Requests

For feature requests, please provide:
- Clear problem statement
- Proposed solution
- Use case description
- Implementation complexity estimate

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml).

## 📋 Pull Request Process

1. **Create Issue**: For significant changes, create an issue first to discuss
2. **Branch**: Create a feature branch from `main`
3. **Develop**: Make your changes following the guidelines above
4. **Test**: Ensure all tests pass locally
5. **Commit**: Use [conventional commits](https://www.conventionalcommits.org/) format
6. **Pull Request**: Create PR with detailed description
7. **Review**: Address feedback and ensure CI passes
8. **Merge**: Maintainers will merge after approval

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

Examples:
```
feat: add custom domain support
fix: correct volume attachment order
docs: update README examples
ci: improve security scanning coverage
```

### Breaking Changes

For breaking changes:
- Use `BREAKING CHANGE:` in commit footer
- Update major version number
- Document migration path in CHANGELOG.md
- Update examples to reflect changes

## 🏷️ Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes (backward compatible)

Releases are automated using semantic-release based on conventional commits.

## 📞 Support

- **General Questions**: Use [GitHub Discussions](https://github.com/your-org/terraform-immich-hetzner/discussions)
- **Bug Reports**: Create an [issue](https://github.com/your-org/terraform-immich-hetzner/issues)
- **Security Issues**: Email maintainers privately
- **Community**: Join [Immich Discord](https://discord.gg/immich)

## 🙏 Recognition

Contributors will be recognized in:
- GitHub contributor list
- Release notes for their contributions
- Special mentions for significant contributions

Thank you for contributing to terraform-immich-hetzner! 🎉