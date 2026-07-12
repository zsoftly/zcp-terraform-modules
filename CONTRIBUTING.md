# Contributing

Thank you for your interest in zpcp.

## Reporting Issues

Please use [GitHub Issues](https://github.com/zsoftly/zpcp/issues) to report
bugs or request features.

When filing a bug report, include:

- The module version or Git ref you are using
- Your Terraform version
- The exact configuration that reproduces the issue
- The expected vs. actual output
- Any relevant `TF_LOG=DEBUG` output

## Pull Requests

Before opening a pull request:

1. Open an issue first to discuss the change.
2. Fork the repository and create a feature branch.
3. Follow the existing code style (`make fmt` before committing).
4. Run `make validate` to confirm all modules and examples pass validation.
5. Open a pull request with a clear description of the change.

## Development Setup

### Prerequisites

- Terraform >= 1.5
- Node.js (for `npx prettier` in `make fmt`)

### Formatting

Run `make fmt` before committing. This formats all Terraform files and Markdown:

```bash
make fmt
```

### Validation

Run `make validate` to initialize and validate all examples against the
CloudStack provider schema:

```bash
make validate
```

### Dry Run

Run `make plan` to execute a `terraform plan` against the demo stack using the
provided example variables:

```bash
make plan
```

The plan uses `terraform.tfvars.example` and does not require real credentials.
Review `examples/demo-stack/terraform.tfvars.example` for the full variable
reference.

## Module Guidelines

- Every module must have a `versions.tf`, `variables.tf`, `main.tf`,
  `outputs.tf`, and a `README.md`.
- All variables must have a `description`.
- All outputs must have a `description`.
- Use `sensitive = true` on any variable that may contain secrets.
- Add input validation blocks where the domain of valid values is constrained.
- Run `terraform fmt -recursive .` before opening a PR.
