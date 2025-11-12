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

# --- Default DNS servers ---
variable "default_dns" {
  type    = list(string)
  default = ["8.8.8.8", "1.1.1.1"]
}

# --- VM list definition ---
variable "vms" {
  description = "Danh sách VM cần tạo (theo dạng map)"
  type = map(object({
    name       : string
    cpu        : number
    memory_mb  : number
    disk_gb    : number
    ipv4       : optional(string)
    ipv4_mask  : optional(number)
    ipv4_gw    : optional(string)
    dns        : optional(list(string))
  }))
}
