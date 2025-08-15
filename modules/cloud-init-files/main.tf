terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

locals {
  short_ci_meta_data_contents_hash    = try(substr(base64sha256(var.ci_meta_data_contents), 0, 6), "0")
  short_ci_network_data_contents_hash = try(substr(base64sha256(var.ci_network_data_contents), 0, 6), "0")
  short_ci_user_data_contents_hash    = try(substr(base64sha256(var.ci_user_data_contents), 0, 6), "0")
  short_ci_vendor_data_contents_hash  = try(substr(base64sha256(var.ci_vendor_data_contents), 0, 6), "0")
  combined_ci_hash = substr(sha256(join("", [
    local.short_ci_meta_data_contents_hash,
    local.short_ci_network_data_contents_hash,
    local.short_ci_user_data_contents_hash,
    local.short_ci_vendor_data_contents_hash
  ])), 0, 6)
}

resource "proxmox_virtual_environment_file" "ci_meta_data" {
  count        = var.ci_meta_data_contents == null ? 0 : 1
  content_type = "snippets"
  datastore_id = var.ci_snippets_storage
  node_name    = var.node

  source_raw {
    file_name = "${lower(random_id.random_id.hex)}.meta-data.yaml"
    data      = sensitive(var.ci_meta_data_contents)
  }
}

output "meta_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_meta_data[0].id, null)
}


resource "proxmox_virtual_environment_file" "ci_network_data" {
  count        = var.ci_network_data_contents == null ? 0 : 1
  content_type = "snippets"
  datastore_id = var.ci_snippets_storage
  node_name    = var.node

  source_raw {
    file_name = "${lower(random_id.random_id.hex)}.network-config.yaml"
    data      = sensitive(var.ci_network_data_contents)
  }
}

output "network_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_network_data[0].id, null)
}

resource "proxmox_virtual_environment_file" "ci_user_data" {
  count        = var.ci_user_data_contents == null ? 0 : 1
  content_type = "snippets"
  datastore_id = var.ci_snippets_storage
  node_name    = var.node

  source_raw {
    file_name = "${lower(random_id.random_id.hex)}.user-data.yaml"
    data      = sensitive(var.ci_user_data_contents)
  }
}

output "user_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_user_data[0].id, null)
}

resource "proxmox_virtual_environment_file" "ci_vendor_data" {
  count        = var.ci_vendor_data_contents == null ? 0 : 1
  content_type = "snippets"
  datastore_id = var.ci_snippets_storage
  node_name    = var.node

  source_raw {
    file_name = "${lower(random_id.random_id.hex)}.vendor-data.yaml"
    data      = sensitive(var.ci_vendor_data_contents)
  }
}

output "vendor_data_file_id" {
  value = try(resource.proxmox_virtual_environment_file.ci_vendor_data[0].id,null)
}

resource "random_id" "random_id" {
  byte_length = 8
  keepers = {
    short_ci_meta_data_contents_hash    = nonsensitive(local.short_ci_meta_data_contents_hash)
    short_ci_network_data_contents_hash = nonsensitive(local.short_ci_network_data_contents_hash)
    short_ci_user_data_contents_hash    = nonsensitive(local.short_ci_user_data_contents_hash)
    short_ci_vendor_data_contents_hash  = nonsensitive(local.short_ci_vendor_data_contents_hash)
    combined_ci_hash                    = nonsensitive(local.combined_ci_hash)
  }
}

output "combined_ci_hash" {
  value = local.combined_ci_hash
}
