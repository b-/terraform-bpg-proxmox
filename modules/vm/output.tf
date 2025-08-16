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