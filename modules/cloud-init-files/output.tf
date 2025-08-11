output "meta_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_meta_data[0].id,null)
}

output "network_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_network_data[0].id,null)
}

output "user_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_user_data[0].id,null)
}

output "vendor_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_vendor_data[0].id,null)
}

output "combined_ci_hash" {
  value = local.combined_ci_hash
}
