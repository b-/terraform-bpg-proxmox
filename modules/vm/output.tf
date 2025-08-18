output "id" {
  description = "Instance VM ID"
  value       = proxmox_virtual_environment_vm.vm.id
}
output "disks" {
  value = proxmox_virtual_environment_vm.vm.disk
}

output "ipv4_addresses" {
  value = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
output "ipv6_addresses" {
  value = proxmox_virtual_environment_vm.vm.ipv6_addresses
}
output "mac_addresses" {
  value = proxmox_virtual_environment_vm.vm.mac_addresses
}
output "creation_date" {
  value = time_static.creation_date.rfc3339
}

output "user_data" {
  value = try(module.cloud_init_files[0].user_data[0].source_raw, null)
}
output "vendor_data" {
  value = try(module.cloud_init_files[0].vendor_data[0].source_raw, null)
}
output "network_data" {
  value = try(module.cloud_init_files[0].network_data[0].source_raw, null)
}
output "meta_data" {
  value = try(module.cloud_init_files[0].meta_data[0].source_raw, null)
}
