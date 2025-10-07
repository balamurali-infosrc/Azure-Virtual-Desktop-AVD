variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "avd-rg"
}

variable "host_pool_name" {
  type    = string
  default = "avd-hostpool"
}

# Host pool type: "Pooled" or "Personal"
variable "host_pool_type" {
  type    = string
  default = "Pooled"
}

# Only relevant for Personal host pools: "Automatic" or "Direct"
variable "personal_assignment_type" {
  type    = string
  default = "Automatic"
}

# We're doing session hosts the 'manual' way (Uses Session Host Configuration = No)
variable "use_session_host_configuration" {
  type    = bool
  default = false
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_admin_password" {
  type    = string
  default = "P@ssword1234!" # replace with a secure method or pass via pipeline secret
  sensitive = true
}

# VM sizing & count for session hosts
variable "session_host_count" {
  type    = number
  default = 2
}

variable "session_host_vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

# OS disk type (enum): Standard_LRS | StandardSSD_LRS | Premium_LRS
variable "os_disk_type" {
  type    = string
  default = "Premium_LRS"
   validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "os_disk_type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS."
  }
}


# Marketplace image defaults (change to the specific image you use)
variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsDesktop"
}

variable "image_offer" {
  type    = string
  default = "windows-11"
}

variable "image_sku" {
  type    = string
  default = "win11-22h2-pro"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "os_disk_size_gb" {
  type    = number
  default = 128
}
# variable "image_publisher" {
#   default = "MicrosoftWindowsDesktop"
# }

# variable "image_offer" {
#   default = "windows-11"
# }

# variable "image_sku" {
#   default = "win11-22h2-avd" # Enterprise multi-session for AVD
# }

# variable "image_version" {
#   default = "latest"
# }
