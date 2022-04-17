# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "group21"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Prefix to identify resources
variable "prefix" {
  default     = "group21"
  type        = string
  description = "Name prefix"
}


# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

variable "num_linux_vms" {
  default     = 3
  description = "Number of Linux VMs to provision"
  type        = number
}

variable "my_public_ip" {
  type        = string
  default     = "3.239.158.177"
  description = "admin public ip"
}

variable "my_private_ip" {
  type        = string
  default     = "172.31.6.252"
  description = "admin private ip"
}

