output "meta_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_meta_data.id,null)
}

output "network_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_network_data.id,null)
}

output "user_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_user_data.id,null)
}

output "vendor_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_vendor_data.id,null)
}

output "combined_ci_hash" {
  value = local.combined_ci_hash
}
