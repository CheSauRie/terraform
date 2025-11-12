Terrform

## Notes

* Terraform can update a VM's static IPv4 settings in-place. Edit the `ipv4`,
  `ipv4_mask`, `ipv4_gw`, or `dns` values in `var.vms` and re-apply to push the
  change without destroying the virtual machine.
* Each VM can override the default datastore by setting `datastore` inside its
  object in `var.vms`. When omitted, the global `var.datastore` value is used.
