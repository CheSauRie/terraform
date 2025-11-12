# --- vCenter connection ---
variable "vsphere_server"   { type = string }
variable "vsphere_user"     { type = string }
variable "vsphere_password" { type = string, sensitive = true }

# --- Environment information ---
variable "datacenter" { type = string }
variable "cluster"    { type = string }
variable "datastore"  { type = string }
variable "network"    { type = string }
variable "folder"     { type = string, default = "" }

# --- Template ---
variable "template_name" { type = string }

# --- VM settings ---
variable "vms" {
  description = "Danh sách VM cần tạo và cấu hình"
  type = map(object({
    name              = string
    cpu               = number
    memory_mb         = number
    disk_gb           = number
    domain            = optional(string, "local")
    datastore         = optional(string)
    dns               = optional(list(string))
    netplan_interface = optional(string, "ens160")
    new_ipv4_address  = optional(string, "")
    new_ipv4_prefix   = optional(number, 24)
    new_ipv4_gateway  = optional(string, "")
    ssh_user          = optional(string)
    ssh_private_key   = optional(string)
  }))
}

# --- SSH connection defaults ---
variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "User SSH mặc định dùng để cấu hình netplan"
}

variable "ssh_private_key" {
  type        = string
  description = "Private key nội dung hoặc dùng file() để load"
}

# --- DNS mặc định ---
variable "default_dns" {
  type        = list(string)
  default     = []
  description = "DNS server mặc định, sẽ dùng nếu VM không khai báo riêng"
}
