terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

module "cloud_image" {
  source = "../image"

  node                     = var.node
  image_content_type       = var.image_content_type
  image_datastore_id       = var.image_datastore_id
  image_filename           = var.image_filename
  image_url                = var.image_url
  image_checksum           = var.image_checksum
  image_checksum_algorithm = var.image_checksum_algorithm
  image_overwrite          = var.image_overwrite
  image_upload_timeout     = var.image_upload_timeout
}

module "cloud_init_files" {
  source                   = "../cloud-init-files"
  node                     = var.node
  ci_snippets_storage      = var.ci_snippets_storage
  ci_meta_data_contents    = var.ci_meta_data_contents
  ci_network_data_contents = var.ci_network_data_contents
  ci_user_data_contents    = var.ci_user_data_contents
  ci_vendor_data_contents  = var.ci_vendor_data_contents
}

resource "terraform_data" "combined_ci_hash" {
  input = {
    hash = try(module.cloud_init_files[0].combined_ci_hash, 0)
  }
}

resource "proxmox_virtual_environment_vm" "vm_template" {
  depends_on = [module.cloud_image]

  node_name   = var.node
  vm_id       = var.vm_id
  name        = var.vm_name
  description = var.description
  tags        = var.tags
  bios        = var.bios
  machine     = var.machine_type
  started     = false
  template    = true

  agent {
    enabled = var.qemu_guest_agent
  }

  # cloud-init config
  initialization {
    datastore_id         = var.ci_datastore_id
    meta_data_file_id    = local.meta_data_file_id
    network_data_file_id = local.network_data_file_id
    user_data_file_id    = local.user_data_file_id
    vendor_data_file_id  = local.vendor_data_file_id
    interface            = var.ci_interface
    type                 = var.ci_datasource_type
  }

  cpu {
    cores = var.vcpu
    type  = var.vcpu_type
  }

  memory {
    dedicated = var.memory
    floating  = var.memory_floating
  }

  dynamic "efi_disk" {
    for_each = (var.bios == "ovmf" ? [1] : [])
    content {
      datastore_id      = var.efi_disk_storage
      file_format       = var.efi_disk_format
      type              = var.efi_disk_type
      pre_enrolled_keys = var.efi_disk_pre_enrolled_keys
    }
  }

  dynamic "serial_device" {
    for_each = var.serial ? [1] : []
    content {}
  }

  disk {
    file_id      = module.cloud_image.id
    datastore_id = var.disk_storage
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = var.disk_format
    cache        = var.disk_cache
    iothread     = var.disk_iothread
    ssd          = var.disk_ssd
    discard      = var.disk_discard
  }
  lifecycle {
    replace_triggered_by = [resource.terraform_data.combined_ci_hash]
  }
}
