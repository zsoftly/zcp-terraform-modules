default: fmt

.PHONY: fmt lint validate plan

# Format all Terraform files and Markdown.
# Prettier is fetched via npx on first use (requires Node.js).
fmt:
	terraform fmt -recursive .
	npx --yes prettier@3 --write --log-level warn "**/*.md"

# Check formatting without writing (CI mode).
lint:
	@terraform fmt -recursive -check . || (echo "Run: make fmt"; exit 1)
	npx --yes prettier@3 --check --log-level warn "**/*.md"

# Initialize (no backend) and validate every example.
validate:
	@for d in examples/*/; do \
		echo "==> Validating $$d"; \
		terraform -chdir=$$d init -backend=false -input=false -no-color; \
		terraform -chdir=$$d validate -no-color; \
	done

# Plan against a live CloudStack zone. Requires real credentials in
# terraform.tfvars (copy from terraform.tfvars.example and fill in values).
# Not run in CI — the CloudStack provider requires a live API for plan.
plan:
	terraform -chdir=examples/demo-stack init -input=false -no-color
	terraform -chdir=examples/demo-stack plan -no-color
