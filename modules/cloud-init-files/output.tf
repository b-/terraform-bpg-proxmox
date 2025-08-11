output "meta_data_file_id" {
  value = resource.proxmox_virtual_environment_file.ci_meta_data[0].id
}

# 'proxmox_virtual_environment_file.ci_user_data[0]'
## proxmox_virtual_environment_file.ci_user_data[0]:
#resource "proxmox_virtual_environment_file" "ci_user_data" {
#    content_type   = "snippets"
#    datastore_id   = "snippets"
#    file_name      = "690c3019f18bdd9c.user-data.yaml"
#    id             = "snippets:snippets/690c3019f18bdd9c.user-data.yaml"

output "network_data_file_id" {
  value = resource.proxmox_virtual_environment_file.ci_network_data[0].id
}

output "user_data_file_id" {
  value = resource.proxmox_virtual_environment_file.ci_user_data[0].id
}

output "vendor_data_file_id" {
  value = resource.proxmox_virtual_environment_file.ci_vendor_data[0].id
}

output "combined_ci_hash" {
  value = local.combined_ci_hash
}
