/*
 * The API requires credentials. Use an API key (c.f. username/password), by going to the
 * web UI 'Datacenter' -> 'Permissions' -> 'API Tokens' and create a new set of credentials.
 *
*/
variable "pm_api_url" {
  description = "The proxmox api endpoint"
  default = "https://proxmox:8006/api2/json"
}


variable "pm_user" {
  description = "A username for password based authentication of the Proxmox API"
  type        = string
  default     = "root@pam"
}

variable "pm_password" {
  description = "A password for password based authentication of the Proxmox API"
  type        = string
  sensitive   = true
  default     = ""
}

variable "pm_api_token_id" {
  default = "root@pam!terraform"
}

variable "pm_api_token_secret" {
  description = "Provide an API secret in a *.auto.tfvars file (or via some other mechanism)"
  default     = ""
  sensitive   = true
}
