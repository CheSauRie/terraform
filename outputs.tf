output "vm_ids" {
  value = { for k, vm in vsphere_virtual_machine.vm : vm.name => vm.id }
}

output "vm_ips" {
  value = { for k, vm in vsphere_virtual_machine.vm : vm.name => vm.default_ip_address }
}

output "vm_names" {
  value = [for vm in vsphere_virtual_machine.vm : vm.name]
}
