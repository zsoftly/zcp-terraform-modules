# test-images-templates

End-to-end test for the `stacks` module. It provisions a real CloudStack
instance with the cloud-init userdata rendered by the selected app stack.

Use this example to validate a new or updated stack template against a live
CloudStack zone before promoting it.

## What It Creates

| Resource                 | Description                                        |
| ------------------------ | -------------------------------------------------- |
| VPC + network tier       | Isolated VPC with one network tier for the test VM |
| ACL                      | Allows SSH ingress (port 22) and all egress        |
| CloudStack instance      | VM booted with the rendered cloud-init userdata    |
| Public IP + port forward | SSH access on port 2222 via a public IP            |

## Usage

```bash
cd examples/test-images-templates
terraform init
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with real credentials and zone
terraform plan
terraform apply
```

After the VM boots, SSH in to verify the stack installed correctly:

```bash
ssh -p 2222 <user>@<public-ip>
```

Tear down when done:

```bash
terraform destroy
```

## Variables

| Variable                  | Required | Description                                                                     |
| ------------------------- | -------- | ------------------------------------------------------------------------------- |
| `cloudstack_api_url`      | yes      | CloudStack API endpoint URL                                                     |
| `cloudstack_api_key`      | yes      | CloudStack API key                                                              |
| `cloudstack_secret_key`   | yes      | CloudStack secret key                                                           |
| `zone`                    | yes      | CloudStack zone name or ID                                                      |
| `stack`                   | no       | App stack to test (default: `docker`)                                           |
| `hostname`                | no       | Hostname passed to cloud-init (default: `test-vm.example.com`)                  |
| `service_offering`        | no       | CloudStack service offering for the test VM (default: `CI1-1`)                  |
| `vpc_offering`            | no       | VPC offering name (default: `Default VPC offering`)                             |
| `network_offering`        | no       | Network offering name (default: `DefaultIsolatedNetworkOfferingForVpcNetworks`) |
| `keypair`                 | no       | SSH keypair registered in CloudStack                                            |
| `stack_vars`              | no       | Extra variables passed to the cloud-init template                               |
| `template_name_overrides` | no       | Override the default template for a given stack slug                            |

See `terraform.tfvars.example` for a full example.

## Supported Stacks

The `stacks` module ships default template mappings and minimum sizing for:

`cpanel`, `docker`, `drupal`, `gitlab`, `jitsi`, `joomla`, `lamp`, `magento`,
`minecraft`, `pritunl`, `wordpress`, `wp-squared`

Override the template name with `template_name_overrides` if your zone uses a
different template name.
