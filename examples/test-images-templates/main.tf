module "networking" {
  source = "../../modules/networking"

  name         = "test-stacks-vpc"
  cidr         = "192.168.100.0/22"
  zone         = var.zone
  vpc_offering = var.vpc_offering

  network_acls = {
    stacks = {
      name = "test-stacks-acl"
      rules = [
        {
          rule_number  = 100
          protocol     = "tcp"
          port         = "22"
          cidr_list    = ["0.0.0.0/0"]
          traffic_type = "ingress"
        },
        {
          rule_number  = 200
          protocol     = "all"
          cidr_list    = ["0.0.0.0/0"]
          traffic_type = "egress"
        }
      ]
    }
  }

  networks = {
    stacks = {
      name             = "test-stacks-tier"
      cidr             = "192.168.100.0/24"
      network_offering = var.network_offering
      source_nat_ip    = true
      acl_key          = "stacks"
    }
  }
}

module "images_templates" {
  source = "../../modules/stacks"

  stack                   = var.stack
  hostname                = var.hostname
  zone                    = var.zone
  stack_vars              = var.stack_vars
  template_name_overrides = var.template_name_overrides
}

resource "cloudstack_instance" "test" {
  name             = "zcp-stack-test-${var.stack}"
  zone             = var.zone
  template         = module.images_templates.template_name
  service_offering = var.service_offering
  network_id       = module.networking.network_ids["stacks"]
  user_data        = module.images_templates.rendered_userdata
  keypair          = var.keypair
  expunge          = true
}

module "security" {
  source = "../../modules/load-balancing-security"

  name   = "test-stacks-security"
  zone   = var.zone
  vpc_id = module.networking.vpc.id

  public_ips = {
    ssh_access = {
      vpc_id = module.networking.vpc.id
    }
  }

  port_forwards = {
    ssh = {
      public_ip_key = "ssh_access"
      forwards = [
        {
          protocol           = "tcp"
          private_port       = 22
          public_port        = 2222
          virtual_machine_id = cloudstack_instance.test.id
        }
      ]
    }
  }
}
