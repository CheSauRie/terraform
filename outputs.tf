output "vm_ids" {
  value = { for k, vm in vsphere_virtual_machine.vm : k => vm.id }
}

output "vm_ips" {
  value = { for k, vm in vsphere_virtual_machine.vm : k => vm.default_ip_address }
}

output "vm_names" {
  value = { for k, vm in vsphere_virtual_machine.vm : k => vm.name }
}
