# ---------------------------------------------------------------------------
# Build identity
# ---------------------------------------------------------------------------
variable "source_ami" {
  description = "Name filter for the source AMI to use for this build."
  type        = string
  default     = "Windows_Server-2022-English-Full-Base*"
}

variable "ami_name" {
  description = "Name for the AMI created by this build."
  type        = string
}

variable "playbook" {
  description = "Filename (relative to shared/ansible/) of the ansible playbook to run."
  type        = string
}

# ---------------------------------------------------------------------------
# Windows credentials
# ---------------------------------------------------------------------------

variable "windows_username" {
  description = "Windows administrator username used by WinRM and EC2Launch."
  type        = string
  default     = "Administrator"
}

variable "windows_password" {
  description = "Windows administrator password used by WinRM and EC2Launch."
  type        = string
  default     = "Admin@1231"
}
