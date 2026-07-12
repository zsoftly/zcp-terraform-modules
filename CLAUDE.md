# CLAUDE.md — zpcp

AI assistant instructions for this repository (Apache CloudStack Terraform
modules and examples by ZSoftly).

---

## Project Documentation

- **[README.md](./README.md)** — overview, module roadmap, structure, dry-run
  instructions
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** — workflow, formatting, validation,
  module guidelines
- **[modules/](./modules/)** — reusable Terraform modules (each has its own
  README)
- **[examples/](./examples/)** — runnable root module examples
- **[stacks/cloud-init/](./stacks/cloud-init/)** — cloud-init templates for the
  stacks module
- **[docs/](./docs/)** — implementation notes and tickets

---

## Critical AI Policies

### Always Run the Content Review Agent

After every documentation update, before handing back, you MUST run the
**[`content-review-agent`](~/.claude/agents/content-review-agent.md)** on the
changed files. Every engineer in the organization has this agent installed and
configured, so it is a required step of the development flow, not optional.

- Run it on each file you added or modified (diff against `HEAD` for edits, full
  content for new files).
- It detects AI writing patterns (em dashes, banned/hyperbolic words, weak "not
  just X but Y" constructions, filler adjectives, flowery marketing language)
  and fixes bad sentences.
- Apply its fixes so zero violations remain.
- Its writing style guide, banned-word list, and critical reminders are binding
  for all documentation in this repo.

This applies to all prose and content, including:

- Markdown under `modules/*/README.md`, `examples/*/README.md`, `README.md`,
  `CONTRIBUTING.md`, and `CHANGELOG.md`
- Variable and output `description` strings in Terraform
- Pull request and issue text
- Code comments that read as prose

Invoke it via the Agent tool with `subagent_type: content-review-agent`.

---

## Terraform Conventions

- Every module must have `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`,
  and `README.md`.
- All variables and outputs must have a `description`.
- Use `sensitive = true` on variables that may contain secrets (passwords,
  pre-shared keys, API credentials).
- Add `validation` blocks where the valid input domain is constrained.
- Never hardcode zone names, offering names, or environment-specific identifiers
  as defaults. Use generic placeholders (e.g., `"your-zone-name"`) or `null`.
- Use `optional()` with a sensible default rather than requiring every field in
  complex object variables.

---

## Validating Changes

After running the
[`content-review-agent`](~/.claude/agents/content-review-agent.md) on every
changed doc and applying its fixes, run these to validate changes:

| Command         | Purpose                                                  |
| --------------- | -------------------------------------------------------- |
| `make fmt`      | `terraform fmt -recursive` + prettier on `*.md`          |
| `make lint`     | fmt check + prettier check (no writes)                   |
| `make validate` | `terraform init -backend=false` + validate, all examples |
| `make plan`     | dry-run plan of `examples/demo-stack`                    |

Commit or push only when the user asks.
