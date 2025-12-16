# Yandex Cloud authentication
variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "yc_service_account_key_file" {
  description = "Path to service account key file"
  type        = string
}

# Network settings
variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "diploma-vpc"
}

variable "vpc_subnet_cidrs" {
  description = "List of subnet CIDRs"
  type        = list(string)
  default     = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
}

# VM configurations
variable "vm_web_count" {
  description = "Number of web servers"
  type        = number
  default     = 2
}

variable "vm_web_cores" {
  description = "Number of CPU cores for web servers"
  type        = number
  default     = 2
}

variable "vm_web_memory" {
  description = "Memory for web servers in GB"
  type        = number
  default     = 2
}

variable "vm_web_disk_size" {
  description = "Disk size for web servers in GB"
  type        = number
  default     = 10
}

variable "vm_zabbix_cores" {
  description = "Number of CPU cores for Zabbix server"
  type        = number
  default     = 2
}

variable "vm_zabbix_memory" {
  description = "Memory for Zabbix server in GB"
  type        = number
  default     = 4
}

variable "vm_zabbix_disk_size" {
  description = "Disk size for Zabbix server in GB"
  type        = number
  default     = 20
}

variable "vm_elk_cores" {
  description = "Number of CPU cores for ELK servers"
  type        = number
  default     = 2
}

variable "vm_elk_memory" {
  description = "Memory for ELK servers in GB"
  type        = number
  default     = 4
}

variable "vm_elk_disk_size" {
  description = "Disk size for ELK servers in GB"
  type        = number
  default     = 20
}

variable "vm_bastion_cores" {
  description = "Number of CPU cores for bastion host"
  type        = number
  default     = 2
}

variable "vm_bastion_memory" {
  description = "Memory for bastion host in GB"
  type        = number
  default     = 2
}

variable "vm_bastion_disk_size" {
  description = "Disk size for bastion host in GB"
  type        = number
  default     = 10
}

# SSH settings
variable "ssh_username" {
  description = "SSH username for VMs"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
