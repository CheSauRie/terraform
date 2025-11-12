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

data "vsphere_datastore" "vm_override" {
  for_each = { for vm_key, vm in var.vms : vm_key => vm.datastore if try(vm.datastore, "") != "" }

  name          = each.value
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
  for_each = var.vms

  name             = each.value.name
  folder           = var.folder != "" ? var.folder : null
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = try(data.vsphere_datastore.vm_override[each.key].id, data.vsphere_datastore.ds.id)

  num_cpus = each.value.cpu
  memory   = each.value.memory_mb

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = try(data.vsphere_virtual_machine.template.network_interface_types[0], "vmxnet3")
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_gb
    thin_provisioned = true
  }

  wait_for_guest_ip_timeout  = 10
  wait_for_guest_net_timeout = 10

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = each.value.name
        domain    = try(each.value.domain, "local")
      }
      dns_server_list = try(each.value.dns, var.default_dns)
      # leave DHCP enabled inside the guest for the first boot
    }
  }

  annotation       = "Created by Terraform"
  enable_disk_uuid = true

  lifecycle {
    # prevent Terraform from reapplying guest customization, which would force recreation
    ignore_changes = [clone[0].customize]
  }
}

# --- Update guest IP from Terraform without recreating the VM ---
locals {
  vms_with_static_ip = {
    for vm_key, vm in var.vms :
    vm_key => vm
    if try(vm.new_ipv4_address, "") != "" && try(vm.new_ipv4_gateway, "") != ""
  }
}

resource "null_resource" "set_ip_netplan" {
  for_each = local.vms_with_static_ip

  triggers = {
    ip      = each.value.new_ipv4_address
    prefix  = tostring(try(each.value.new_ipv4_prefix, 24))
    gateway = each.value.new_ipv4_gateway
    iface   = try(each.value.netplan_interface, "ens160")
  }

  connection {
    type        = "ssh"
    user        = try(each.value.ssh_user, var.ssh_user)
    host        = vsphere_virtual_machine.vm[each.key].default_ip_address
    private_key = try(each.value.ssh_private_key, var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'cat >/etc/netplan/01-netcfg.yaml <<EOF\\nnetwork:\\n  version: 2\\n  ethernets:\\n    ${try(each.value.netplan_interface, "ens160")}:\\n      dhcp4: false\\n      addresses: [${each.value.new_ipv4_address}/${try(each.value.new_ipv4_prefix, 24)}]\\n      routes:\\n        - to: 0.0.0.0/0\\n          via: ${each.value.new_ipv4_gateway}\\nEOF'",
      "sudo netplan apply || (sleep 2 && sudo netplan apply)",
    ]
  }
}
