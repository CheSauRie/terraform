# ===============================
#  Terraform create multiple VMs
#  vCenter / vSphere 8.0.3
# ===============================

# --- Look up existing objects ---
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --- Create multiple VMs ---
resource "vsphere_virtual_machine" "vm" {
  for_each         = var.vms

  name             = each.value.name
  folder           = var.folder != "" ? var.folder : null
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = each.value.cpu
  memory   = each.value.memory_mb
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  # --- Network interface ---
  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # --- Disk configuration ---
  disk {
    label            = "disk0"
    size             = each.value.disk_gb
    thin_provisioned = true
  }

  # --- Clone configuration ---
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = each.value.name
        domain    = "local"
      }

      network_interface {
        ipv4_address = try(each.value.ipv4, "") != "" ? each.value.ipv4 : null
        ipv4_netmask = try(each.value.ipv4_mask, null)
      }

      ipv4_gateway    = try(each.value.ipv4_gw, null)
      dns_server_list = try(each.value.dns, var.default_dns)
    }
  }

  annotation       = "Created by Terraform"
  enable_disk_uuid = true
}
