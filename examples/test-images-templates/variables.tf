variable "cloudstack_api_url" {
  type = string
}

variable "cloudstack_api_key" {
  type      = string
  sensitive = true
}

variable "cloudstack_secret_key" {
  type      = string
  sensitive = true
}

variable "zone" {
  type = string
}

variable "stack" {
  type    = string
  default = "docker"
}

variable "hostname" {
  type    = string
  default = "test-vm.example.com"
}

variable "stack_vars" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "template_name_overrides" {
  type    = map(string)
  default = {}
}
