# Pre-configured Application Stacks — Implementation Tickets

**Epic Goal:** Enable ZCP users to select from 12 application stacks at VM provision time. Existing OS templates (Ubuntu 24.04, AlmaLinux 9, etc.) are already available in the ZCP environment. Each stack is delivered via a cloud-init/userdata script that installs and fully configures the application on first boot.

---

## Stack Catalogue

| # | Stack | Category | Base Template | Licence |
|---|-------|----------|---------------|---------|
| 1 | cPanel | Control Panels | AlmaLinux 9 | Commercial |
| 2 | Docker | Runtimes | Ubuntu 24.04 | Apache 2.0 |
| 3 | LAMP | Runtimes | Ubuntu 24.04 | Open-source |
| 4 | Drupal | CMS | Ubuntu 24.04 | GPL |
| 5 | Joomla | CMS | Ubuntu 24.04 | GPL |
| 6 | WordPress | CMS | Ubuntu 24.04 | GPL |
| 7 | WP Squared | CMS | Ubuntu 24.04 | ZCP-curated |
| 8 | GitLab CE | DevOps | Ubuntu 24.04 | MIT/EE |
| 9 | Jitsi | Communication | Ubuntu 24.04 | Apache 2.0 |
| 10 | Magento | Ecommerce | Ubuntu 24.04 | OSL |
| 11 | Minecraft | Gaming | Ubuntu 24.04 | Mojang EULA |
| 12 | Pritunl | Security | Ubuntu 24.04 | AGPL |

---

## Phase 1 — Design & Framework (3 tickets)

### TICKET-01: Build cloud-init framework and secret injection pattern
**Type:** Task | **Priority:** Critical | **Blocks:** All 12 stack tickets (TICKET-04 to TICKET-15)
**Assigned to:** _(infra lead / platform engineer)_
**Estimated effort:** 2–3 days

---

#### Background

Every stack script needs the same foundation: a consistent way to set the hostname, inject secrets from Terraform, and guarantee the script never runs more than once (idempotency). Without this done first, each stack engineer will solve these problems differently, creating inconsistency and bugs.

CloudStack delivers userdata to the VM via its metadata server at `http://169.254.169.254/latest/user-data`. Cloud-init reads this on first boot and executes it. Terraform encodes the rendered YAML and passes it to `cloudstack_instance.user_data`.

---

#### Deliverables

**1. Directory structure to create:**

```
zpcp/
└── stacks/
    ├── cloud-init/
    │   ├── base.tftpl          ← shared skeleton (reference template, not used directly)
    │   ├── cpanel.tftpl
    │   ├── docker.tftpl
    │   ├── lamp.tftpl
    │   ├── drupal.tftpl
    │   ├── joomla.tftpl
    │   ├── wordpress.tftpl
    │   ├── wp-squared.tftpl
    │   ├── gitlab.tftpl
    │   ├── jitsi.tftpl
    │   ├── magento.tftpl
    │   ├── minecraft.tftpl
    │   └── pritunl.tftpl
    └── validate/               ← created in TICKET-16
```

> `.tftpl` is the Terraform convention for files consumed by `templatefile()`. Using this extension makes the intent clear and enables editor syntax highlighting.

---

**2. Base skeleton — `stacks/cloud-init/base.tftpl`**

This file is **not used directly by Terraform**. It is the reference pattern that every stack `.tftpl` must follow. Copy it when starting a new stack script.

```yaml
#cloud-config
# ZCP Stack: ${stack}
# Do not edit on the VM — rendered by Terraform at provision time.

hostname: ${hostname}
fqdn: ${hostname}
manage_etc_hosts: true

write_files:
  - path: /etc/zcp/stack
    content: |
      STACK=${stack}
      PROVISIONED=false
    permissions: '0644'
    owner: root:root

runcmd:
  # Idempotency guard — exit immediately if already provisioned
  - |
    if [ -f /var/lib/zcp-provisioned ]; then
      echo "[ZCP] Already provisioned, skipping." | tee -a /var/log/zcp-provision.log
      exit 0
    fi
  - echo "[ZCP] Starting ${stack} provision at $(date)" | tee -a /var/log/zcp-provision.log

  #
  # ---- STACK-SPECIFIC COMMANDS GO HERE ----
  #

  # Mark provisioning complete — always the last step
  - sed -i 's/PROVISIONED=false/PROVISIONED=true/' /etc/zcp/stack
  - touch /var/lib/zcp-provisioned
  - echo "[ZCP] Provisioning complete at $(date)" | tee -a /var/log/zcp-provision.log
```

Rules every stack script must follow:
- Copy the idempotency guard block verbatim — it must be the first `runcmd` entry
- Copy the `touch /var/lib/zcp-provisioned` block verbatim — it must be the last `runcmd` entry
- Never use `sudo` inside `runcmd` — cloud-init runs as root already
- Write progress to `/var/log/zcp-provision.log` so operators can tail it while debugging

---

**3. Secret injection pattern**

Secrets flow: **Terraform variable → `templatefile()` → rendered YAML → `base64encode()` → `cloudstack_instance.user_data`**

In a stack template file, reference a secret using standard Terraform template interpolation:

```yaml
# Inside wordpress.tftpl
runcmd:
  - mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';"
  - wp core install --allow-root --url="http://${hostname}" \
      --title="${wp_site_title}" \
      --admin_user="${wp_admin_user}" \
      --admin_password="${wp_admin_password}" \
      --admin_email="${wp_admin_email}"
```

In `modules/images-templates/locals.tf`, Terraform renders the template and passes all variables in:

```hcl
rendered_userdata = templatefile(
  "${path.module}/../../stacks/cloud-init/${var.stack}.tftpl",
  merge(
    var.stack_vars,           # secrets and stack-specific config
    {
      stack    = var.stack    # always injected
      hostname = var.hostname # always injected
    }
  )
)
```

Variable declaration for secrets — always mark sensitive:

```hcl
variable "stack_vars" {
  description = "Stack-specific variables and secrets. All values are treated as sensitive."
  type        = map(string)
  sensitive   = true
  default     = {}
}
```

> Using `map(string)` for `stack_vars` keeps the module interface stable. Adding a new secret to a stack does not require changing the module's variable signature.

---

**4. What each stack engineer receives once this ticket is merged**

- A `.tftpl` skeleton to copy as their starting point
- A clear rule: all secrets come in via `${variable_name}` interpolation — never hardcoded
- A log file (`/var/log/zcp-provision.log`) to tail when testing on a real VM
- An idempotency contract: re-running cloud-init on a live VM is safe and a no-op

---

#### Acceptance Criteria

- [ ] `/zpcp/stacks/cloud-init/base.tftpl` created and matches the structure above
- [ ] Idempotency tested on a real ZCP VM: `cloud-init clean && cloud-init init` on an already-provisioned VM exits without re-installing
- [ ] `/zpcp/docs/stacks-secrets.md` written and covers:
  - The `templatefile()` + `sensitive = true` pattern
  - That secrets must never appear in committed `.tfvars` files — use `TF_VAR_` env vars or a secrets manager in CI
  - That `rendered_userdata` is marked sensitive and will not appear in `terraform plan` output
- [ ] At least one stack script (Docker — simplest) implemented end-to-end as a proof of concept confirming the framework works on a real ZCP VM
- [ ] Reviewed and merged to `main` before any stack ticket (TICKET-04 to TICKET-15) is started

---

### TICKET-02: Implement `images-templates` Terraform module
**Type:** Task | **Priority:** Critical | **Blocks:** TICKET-03 and all stack Terraform wiring
**Assigned to:** _(Terraform / platform engineer)_
**Estimated effort:** 3–4 days
**Depends on:** TICKET-01 (needs `.tftpl` files to exist to validate template rendering)

---

#### Background

The `images-templates` module is listed as "Planned" in the ZPCP module roadmap. It is the Terraform entry point for the entire stacks feature. Its single responsibility: accept a stack slug (e.g. `"wordpress"`) and output the correct CloudStack template name and rendered cloud-init userdata. The compute resource (or demo-stack example) then uses these two outputs when creating the VM.

This module does **not** create VMs. It resolves what template and what userdata to use. This keeps it composable with the future `compute` module and any other caller.

---

#### Deliverables

**1. Module file structure:**

```
zpcp/modules/images-templates/
├── versions.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
└── README.md
```

---

**2. `versions.tf`**

Match the pattern used by all other modules in this repo:

```hcl
terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudstack = {
      source  = "cloudstack/cloudstack"
      version = "~> 0.6"
    }
  }
}
```

---

**3. `variables.tf`**

```hcl
variable "stack" {
  description = "Application stack slug. Must be one of the supported stack identifiers."
  type        = string

  validation {
    condition = contains([
      "cpanel", "docker", "lamp", "drupal", "joomla",
      "wordpress", "wp-squared", "gitlab", "jitsi",
      "magento", "minecraft", "pritunl"
    ], var.stack)
    error_message = "stack must be one of: cpanel, docker, lamp, drupal, joomla, wordpress, wp-squared, gitlab, jitsi, magento, minecraft, pritunl."
  }
}

variable "hostname" {
  description = "Fully qualified hostname for the VM. Used by cloud-init to set the system hostname."
  type        = string
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "stack_vars" {
  description = "Stack-specific runtime variables and secrets (passwords, keys, config values). All values are treated as sensitive."
  type        = map(string)
  sensitive   = true
  default     = {}
}
```

---

**4. `locals.tf`**

```hcl
locals {
  # Maps each stack slug to the CloudStack template name registered in ZCP.
  # Update template names to match what is registered in your ZCP zone exactly.
  template_map = {
    cpanel     = "AlmaLinux 9 64-bit"
    docker     = "Ubuntu 24.04 LTS 64-bit"
    lamp       = "Ubuntu 24.04 LTS 64-bit"
    drupal     = "Ubuntu 24.04 LTS 64-bit"
    joomla     = "Ubuntu 24.04 LTS 64-bit"
    wordpress  = "Ubuntu 24.04 LTS 64-bit"
    wp-squared = "Ubuntu 24.04 LTS 64-bit"
    gitlab     = "Ubuntu 24.04 LTS 64-bit"
    jitsi      = "Ubuntu 24.04 LTS 64-bit"
    magento    = "Ubuntu 24.04 LTS 64-bit"
    minecraft  = "Ubuntu 24.04 LTS 64-bit"
    pritunl    = "Ubuntu 24.04 LTS 64-bit"
  }

  # Minimum sizing requirements per stack.
  # Expose via output so the calling compute resource can enforce them.
  min_sizing = {
    cpanel     = { cpu = 2, ram_mb = 2048, disk_gb = 40 }
    docker     = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    lamp       = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    drupal     = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    joomla     = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    wordpress  = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    wp-squared = { cpu = 2, ram_mb = 2048, disk_gb = 30 }
    gitlab     = { cpu = 4, ram_mb = 8192, disk_gb = 50 }
    jitsi      = { cpu = 2, ram_mb = 4096, disk_gb = 20 }
    magento    = { cpu = 4, ram_mb = 4096, disk_gb = 50 }
    minecraft  = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    pritunl    = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
  }

  template_name = local.template_map[var.stack]
  stack_sizing  = local.min_sizing[var.stack]

  # Render the cloud-init userdata for the selected stack.
  # merge() combines common variables (stack, hostname) with all stack-specific secrets.
  rendered_userdata = templatefile(
    "${path.module}/../../stacks/cloud-init/${var.stack}.tftpl",
    merge(
      var.stack_vars,
      {
        stack    = var.stack
        hostname = var.hostname
      }
    )
  )
}
```

---

**5. `main.tf`**

```hcl
# Look up the existing OS template from CloudStack.
# Fails at plan time if the template name in locals.template_map does not exist
# in the target zone — providing an early, clear error instead of a silent apply failure.
data "cloudstack_template" "this" {
  filter {
    name  = "name"
    value = local.template_name
  }

  filter {
    name  = "zone"
    value = var.zone
  }

  project = var.project
}
```

---

**6. `outputs.tf`**

```hcl
output "template_name" {
  description = "CloudStack template name resolved for the selected stack."
  value       = data.cloudstack_template.this.name
}

output "template_id" {
  description = "CloudStack template ID resolved for the selected stack."
  value       = data.cloudstack_template.this.id
}

output "stack" {
  description = "The stack slug passed in, for reference by the calling module."
  value       = var.stack
}

output "rendered_userdata" {
  description = "Base64-encoded cloud-init userdata for the selected stack. Pass directly to cloudstack_instance.user_data."
  value       = base64encode(local.rendered_userdata)
  sensitive   = true
}

output "min_sizing" {
  description = "Minimum CPU, RAM (MB), and disk (GB) for the selected stack. The calling compute resource should enforce these."
  value       = local.stack_sizing
}
```

---

**7. How the calling module uses this — reference example:**

```hcl
module "images_templates" {
  source   = "../../modules/images-templates"

  stack    = "wordpress"
  hostname = "wp01.prod.example.com"
  zone     = var.zone
  project  = var.project

  stack_vars = {
    mysql_root_password = var.mysql_root_password
    wp_admin_password   = var.wp_admin_password
    wp_admin_user       = var.wp_admin_user
    wp_admin_email      = var.wp_admin_email
    wp_site_title       = var.wp_site_title
  }
}

resource "cloudstack_instance" "app" {
  name      = "wp01"
  zone      = var.zone
  template  = module.images_templates.template_id
  user_data = module.images_templates.rendered_userdata
  # service_offering should be validated against module.images_templates.min_sizing
}
```

---

**8. `README.md` — sections to cover:**

- What the module does (resolve template + render userdata — does not create VMs)
- Supported stack slugs with their base OS
- Minimum sizing table (copy from `locals.tf`)
- Working usage example (copy the block above)
- How to add a new stack in future: add entry to `template_map` and `min_sizing` in `locals.tf`, create the `.tftpl` file
- Note that `rendered_userdata` is sensitive and will not appear in plan/apply output

---

#### Acceptance Criteria

- [ ] All 6 files created under `/zpcp/modules/images-templates/`
- [ ] `terraform validate` passes cleanly
- [ ] `validation` block on `var.stack` rejects an unrecognised slug with a descriptive error
- [ ] `terraform plan` with `stack = "docker"` succeeds and resolves the correct template ID from a live ZCP zone
- [ ] `terraform plan` fails clearly if the template name in `locals.template_map` does not match a registered template in ZCP (plan-time safety net)
- [ ] `rendered_userdata` output is `sensitive = true` and does not appear in `terraform plan` or `terraform apply` console output
- [ ] `min_sizing` output visible via `terraform output` for the calling compute resource to consume
- [ ] Roadmap table in `/zpcp/README.md` updated: `images-templates` row changed from `Planned` → `Ready`
- [ ] Module `README.md` includes a working usage example
- [ ] Reviewed and merged to `main` before TICKET-03 (demo-stack update) is started

---

### TICKET-03: Update `demo-stack` example with stack selection
**Type:** Task | **Priority:** Medium | **Depends on:** TICKET-02

**Description:**
Update `/zpcp/examples/demo-stack/` to demonstrate provisioning a VM with a selected application stack.

**Acceptance Criteria:**
- `terraform.tfvars.example` includes `app_stack = "wordpress"` and sample stack variables (admin user, password placeholders)
- Example wires through the `images-templates` module
- `README.md` updated with stack selection instructions
- Passes `terraform validate` and `terraform plan -var-file=terraform.tfvars.example`

---

## Phase 2 — Individual Stack Cloud-init Scripts (12 tickets)

> All 12 tickets can be worked in parallel. Each ticket delivers: a cloud-init script at `/zpcp/stacks/cloud-init/<stack>.yaml` and any helper scripts it calls.

---

### TICKET-04: Stack — cPanel
**Base OS:** AlmaLinux 9 | **Licence:** Commercial (licence key required)

**Cloud-init script:** `/zpcp/stacks/cloud-init/cpanel.yaml`

**What the script must do:**
1. Set hostname from injected variable
2. Run the cPanel installer: `curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest`
3. Set WHM root password using injected variable
4. Activate cPanel licence using injected licence key
5. Enable AutoSSL

**Terraform variables required:**
- `cpanel_licence_key` (sensitive)
- `root_password` (sensitive)
- `hostname`

**Acceptance Criteria:**
- VM boots and cPanel/WHM is accessible on port 2087 without manual steps
- Licence activated automatically
- Script is idempotent (safe to run twice)
- Minimum sizing documented: 2 vCPU, 2 GB RAM, 40 GB disk

---

### TICKET-05: Stack — Docker
**Base OS:** Ubuntu 24.04 | **Licence:** Apache 2.0

**Cloud-init script:** `/zpcp/stacks/cloud-init/docker.yaml`

**What the script must do:**
1. Install Docker CE via official apt repo (not snap)
2. Install Compose plugin
3. Add default cloud user to `docker` group
4. Enable and start `docker` service

**Terraform variables required:** None (no secrets needed)

**Acceptance Criteria:**
- `docker run hello-world` succeeds as non-root user on first boot
- `docker compose version` returns 2.x
- Script is idempotent

---

### TICKET-06: Stack — LAMP
**Base OS:** Ubuntu 24.04 | **Licence:** Open-source

**Cloud-init script:** `/zpcp/stacks/cloud-init/lamp.yaml`

**What the script must do:**
1. Install Apache 2, MySQL 8, PHP 8.3 (and common extensions)
2. Secure MySQL: set root password, remove anonymous users, remove test database
3. Configure Apache default vhost
4. Open UFW ports: 80, 443, 22

**Terraform variables required:**
- `mysql_root_password` (sensitive)

**Acceptance Criteria:**
- Apache serves on port 80 on first boot
- MySQL running and accessible with injected root password
- PHP operational (test page or `php -v`)
- Script is idempotent

---

### TICKET-07: Stack — Drupal
**Base OS:** Ubuntu 24.04 | **Licence:** GPL

**Cloud-init script:** `/zpcp/stacks/cloud-init/drupal.yaml`

**What the script must do:**
1. Run LAMP setup steps (reuse LAMP script or inline)
2. Install Composer
3. Run `composer create-project drupal/recommended-project /var/www/html/drupal`
4. Create MySQL database and user with injected credentials
5. Configure Apache vhost for Drupal (`AllowOverride All`, mod_rewrite enabled)
6. Pre-populate Drupal `settings.php` with DB credentials

**Terraform variables required:**
- `mysql_root_password` (sensitive)
- `drupal_db_password` (sensitive)
- `drupal_db_name`
- `drupal_db_user`

**Acceptance Criteria:**
- Drupal site accessible on port 80 on first boot
- Database connected — no manual DB setup needed
- Script is idempotent

---

### TICKET-08: Stack — Joomla
**Base OS:** Ubuntu 24.04 | **Licence:** GPL

**Cloud-init script:** `/zpcp/stacks/cloud-init/joomla.yaml`

**What the script must do:**
1. Run LAMP setup steps
2. Download and extract latest Joomla stable to `/var/www/html/joomla`
3. Create MySQL database and user with injected credentials
4. Configure Apache vhost
5. Pre-populate `configuration.php` with DB credentials and site name

**Terraform variables required:**
- `mysql_root_password` (sensitive)
- `joomla_db_password` (sensitive)
- `joomla_db_name`
- `joomla_db_user`
- `site_name`

**Acceptance Criteria:**
- Joomla site accessible on port 80 on first boot
- No manual DB configuration needed
- Script is idempotent

---

### TICKET-09: Stack — WordPress
**Base OS:** Ubuntu 24.04 | **Licence:** GPL

**Cloud-init script:** `/zpcp/stacks/cloud-init/wordpress.yaml`

**What the script must do:**
1. Run LAMP setup steps
2. Install WP-CLI
3. Download WordPress core
4. Create MySQL database and user
5. Run `wp core install` with injected: site title, admin username, admin password, admin email
6. Set permalink structure to `/%postname%/`

**Terraform variables required:**
- `mysql_root_password` (sensitive)
- `wp_admin_password` (sensitive)
- `wp_admin_email`
- `wp_admin_user`
- `wp_site_title`

**Acceptance Criteria:**
- WordPress site fully installed and accessible on first boot (no web installer screen)
- WP admin login works with injected credentials
- Script is idempotent

---

### TICKET-10: Stack — WP Squared (ZCP-curated)
**Base OS:** Ubuntu 24.04 | **Licence:** ZCP-curated

**Cloud-init script:** `/zpcp/stacks/cloud-init/wp-squared.yaml`

**What the script must do:**
1. Install Nginx, PHP-FPM 8.3, MariaDB, Redis
2. Install WP-CLI
3. Create MariaDB database and user
4. Install and configure WordPress
5. Install and activate Redis object cache plugin
6. Configure Nginx with FastCGI cache
7. Enable WordPress Multisite in `wp-config.php`

**Terraform variables required:**
- `db_root_password` (sensitive)
- `wp_admin_password` (sensitive)
- `wp_admin_email`
- `wp_admin_user`
- `wp_site_title`

**Notes:** Document tuning decisions (FastCGI cache TTL, PHP-FPM pool settings, Redis maxmemory policy) in `/zpcp/docs/wp-squared-rationale.md`.

**Acceptance Criteria:**
- WordPress multi-site accessible on first boot
- Redis object cache active (`wp redis status` returns enabled)
- Nginx FastCGI cache headers (`X-Cache`) visible in HTTP response
- Script is idempotent

---

### TICKET-11: Stack — GitLab CE
**Base OS:** Ubuntu 24.04 | **Licence:** MIT/EE

**Cloud-init script:** `/zpcp/stacks/cloud-init/gitlab.yaml`

**What the script must do:**
1. Add official GitLab apt repository
2. Install `gitlab-ce` omnibus package
3. Set `external_url` from injected hostname
4. Run `gitlab-ctl reconfigure`
5. Set initial root password (disable first-run password file)
6. Optionally configure SMTP if variables provided

**Terraform variables required:**
- `gitlab_hostname`
- `gitlab_root_password` (sensitive)
- `smtp_host`, `smtp_user`, `smtp_password` (optional, sensitive)

**Notes:** Minimum spec must be enforced — 4 vCPU, 8 GB RAM, 50 GB disk. Terraform should emit an error or warning if the selected service offering is below this.

**Acceptance Criteria:**
- GitLab web UI accessible on port 80/443 on first boot
- Root login works with injected password (no file-based token needed)
- `gitlab-ctl status` shows all services running
- Script is idempotent

---

### TICKET-12: Stack — Jitsi Meet
**Base OS:** Ubuntu 24.04 | **Licence:** Apache 2.0

**Cloud-init script:** `/zpcp/stacks/cloud-init/jitsi.yaml`

**What the script must do:**
1. Set FQDN hostname (required by Jitsi for XMPP and TLS)
2. Add official Jitsi apt repository
3. Install `jitsi-meet` (pulls Jicofo + Prosody as dependencies)
4. Run unattended install with injected hostname (non-interactive)
5. If valid FQDN provided, trigger Let's Encrypt SSL setup
6. Open UFW: 80, 443, 4443/tcp, 10000/udp, 22

**Terraform variables required:**
- `jitsi_hostname` (must be a valid FQDN for SSL to work)
- `enable_letsencrypt` (bool, default false)
- `letsencrypt_email` (required if `enable_letsencrypt = true`)

**Acceptance Criteria:**
- Jitsi Meet web interface loads on first boot
- Video conference room creatable without authentication (default config)
- Script is idempotent

---

### TICKET-13: Stack — Magento Open Source
**Base OS:** Ubuntu 24.04 | **Licence:** OSL

**Cloud-init script:** `/zpcp/stacks/cloud-init/magento.yaml`

**What the script must do:**
1. Install Nginx, PHP 8.2 + required extensions, MySQL 8, Redis, OpenSearch (single-node)
2. Install Composer
3. Run `composer create-project magento/community-edition` using injected Magento Marketplace keys
4. Create MySQL database and user
5. Run `bin/magento setup:install` with injected admin credentials, DB credentials, base URL
6. Run `bin/magento deploy:mode:set production`

**Terraform variables required:**
- `magento_public_key` (sensitive)
- `magento_private_key` (sensitive)
- `db_root_password` (sensitive)
- `magento_db_password` (sensitive)
- `magento_admin_password` (sensitive)
- `magento_admin_email`
- `magento_admin_user`
- `base_url`

**Notes:** Minimum spec: 4 vCPU, 4 GB RAM, 50 GB disk. Terraform should enforce this.

**Acceptance Criteria:**
- Magento storefront and admin panel accessible on first boot
- Admin login works with injected credentials
- Script is idempotent

---

### TICKET-14: Stack — Minecraft (Java Edition)
**Base OS:** Ubuntu 24.04 | **Licence:** Mojang EULA

**Cloud-init script:** `/zpcp/stacks/cloud-init/minecraft.yaml`

**What the script must do:**
1. Install Java 21 LTS via apt
2. Create a dedicated `minecraft` system user
3. Download the latest Minecraft server JAR from the official Mojang endpoint
4. Accept EULA (`eula=true` in `eula.txt`)
5. Create `server.properties` with injected settings (max players, difficulty, level name)
6. Set JVM RAM flags from injected variable (`-Xmx<ram>G -Xms<ram>G`)
7. Create and enable a systemd service unit (auto-start, restart on crash)
8. Open UFW: 25565/tcp, 25565/udp, 22

**Terraform variables required:**
- `minecraft_ram_gb` (default: 2)
- `max_players` (default: 20)
- `difficulty` (default: `"normal"`)
- `level_name` (default: `"world"`)

**Notes:** EULA auto-acceptance must be clearly disclosed in user-facing documentation — the operator accepts the Mojang EULA by provisioning this stack.

**Acceptance Criteria:**
- Minecraft server running as a systemd service on first boot
- Port 25565 reachable from outside the VM
- RAM allocation matches injected variable
- Script is idempotent

---

### TICKET-15: Stack — Pritunl VPN
**Base OS:** Ubuntu 24.04 | **Licence:** AGPL

**Cloud-init script:** `/zpcp/stacks/cloud-init/pritunl.yaml`

**What the script must do:**
1. Add official Pritunl and MongoDB apt repositories
2. Install `pritunl` and `mongodb-org`
3. Enable and start both services
4. Enable kernel IP forwarding in `sysctl.conf`
5. Capture `pritunl setup-key` output and write to `/root/pritunl-setup-key.txt`
6. Open UFW: 80, 443, 22, 1194/udp, 51820/udp

**Terraform variables required:** None (setup key is retrieved post-provision from the instance)

**Acceptance Criteria:**
- Pritunl web interface accessible on port 443 on first boot
- Setup key available in `/root/pritunl-setup-key.txt`
- OpenVPN and WireGuard kernel modules loaded (`lsmod | grep -E 'wireguard|tun'`)
- Script is idempotent

---

## Phase 3 — QA & Documentation (2 tickets)

### TICKET-16: Validation test suite for all 12 stacks
**Type:** Task | **Priority:** High | **Depends on:** TICKET-04 through TICKET-15

**Description:**
Build and run an automated validation suite that provisions each stack on a ZCP test zone and confirms the key service is running and reachable.

**Acceptance Criteria:**
- Validation script per stack at `/zpcp/stacks/validate/<stack>.sh` that:
  - Provisions a test VM via Terraform
  - Waits for cloud-init to complete: `cloud-init status --wait`
  - Checks the expected service endpoint (HTTP 200 or TCP port open)
  - Prints PASS or FAIL with a reason
  - Tears down the test VM after the check
- All 12 stacks return PASS on a ZCP test zone before any stack is merged to main
- Under-sized VM cases tested for GitLab and Magento (should fail or warn at plan time)
- Idempotency verified: cloud-init script re-run manually should not break the running service

---

### TICKET-17: User-facing documentation for pre-configured stacks
**Type:** Task | **Priority:** Medium | **Depends on:** TICKET-16

**Description:**
Write end-user and operator documentation for the stacks feature.

**Acceptance Criteria:**
- `/zpcp/docs/stacks-overview.md` — what each stack includes, licence notes, minimum sizing table for all 12
- `/zpcp/docs/stacks-provisioning-guide.md` — how to select and provision a stack via Terraform (required variables, example `.tfvars`)
- `/zpcp/docs/stacks-secrets.md` — how secrets are injected safely (pattern, what never goes in state plaintext)
- First-login / first-access instructions for each stack (e.g. where to find the Pritunl setup key, how to reach the Minecraft console, GitLab root login)
- Minecraft EULA disclosure clearly stated
- Root `README.md` in `/zpcp/` updated to reference the stacks feature and the new `images-templates` module

---

## Ticket Summary

| Phase | Tickets | Count |
|-------|---------|-------|
| Design & Framework | TICKET-01 to TICKET-03 | 3 |
| Individual Stack Scripts | TICKET-04 to TICKET-15 | 12 |
| QA & Documentation | TICKET-16 to TICKET-17 | 2 |
| **Total** | | **17 tickets** |

## Critical Path

```
TICKET-01 (cloud-init framework)
TICKET-02 (images-templates module)
  │
  ├── TICKET-04 through TICKET-15 (12 stacks — all parallel)
  │
  └── TICKET-03 (demo-stack example)
        │
        └── TICKET-16 (validation suite)
              │
              └── TICKET-17 (documentation)
```

The 12 stack tickets are the main parallelisation opportunity — one engineer per stack once TICKET-01 and TICKET-02 are done.
