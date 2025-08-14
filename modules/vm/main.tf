terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}


module "cloud_init_files" {
  source                   = "../cloud-init-files"
  node                     = var.node
  ci_snippets_storage      = var.cloudinit.storage
  ci_meta_data_contents    = var.cloudinit.meta_data
  ci_network_data_contents = var.cloudinit.network_data
  ci_user_data_contents    = var.cloudinit.user_data
  ci_vendor_data_contents  = var.cloudinit.vendor_data
}

resource "terraform_data" "combined_ci_hash" {
  input = {
    hash = try(module.cloud_init_files[0].combined_ci_hash, 0)
  }
}

resource "terraform_data" "creation_date" {
  input = {
    timestamp = timestamp()
  }
}
locals {
  creation_date = resource.terraform_data.output.timestamp
  efi_enabled   = var.efi != null ? true : false
  numa_enabled  = var.numa != null ? true : false
  is_clone      = var.clone != null ? true : false
}
resource "proxmox_virtual_environment_vm" "vm" {
  depends_on = [module.cloud_image, module.cloud_init_files, resource.terraform_data.combined_ci_hash, resource.terraform_data.creation_date]

  node_name   = var.node
  vm_id       = var.vmid
  name        = var.name
  description = var.description != null ? var.description : "Terraform VM created on ${local.creation_date}"
  tags        = var.tags
  bios        = var.efi != null ? "ovmf" : "seabios"
  machine     = var.machine_type
  started     = var.started
  template    = var.template

  agent {
    enabled = var.qemu_guest_agent
  }

  dynamic "clone" {
    for_each = (local.is_clone ? [1] : [])
    content {
      node_name = each.value.template_node
      vm_id     = each.value.template_id
      full      = each.value.full
    }
  }

  # cloud-init config
  initialization {
    datastore_id         = var.cloudinit.datastore_id
    meta_data_file_id    = module.cloud_init_files.meta_data_file_id
    network_data_file_id = module.cloud_init_files.network_data_file_id
    user_data_file_id    = module.cloud_init_files.user_data_file_id
    vendor_data_file_id  = module.cloud_init_files.vendor_data_file_id
    interface            = var.cloudinit.interface
    type                 = var.cloudinit.type
  }

  cpu {
    cores = var.vcpu
    type  = var.vcpu_type
    numa  = local.numa_enabled
  }

  memory {
    dedicated = var.memory
    floating  = var.memory_floating
  }

  dynamic "numa" {
    for_each = (local.numa_enabled ? [1] : [])
    content {
      device    = var.numa.device
      cpus      = var.numa.cpus
      memory    = var.numa.memory
      hostnodes = var.numa.hostnodes
      policy    = var.numa.policy
    }
  }

  vga {
    type   = var.display_type
    memory = var.display_memory
  }

  dynamic "efi_disk" {
    for_each = (local.efi_enabled ? [1] : [])
    content {
      datastore_id      = var.efi.storage
      file_format       = var.efi.format
      type              = var.efi.type
      pre_enrolled_keys = var.efi.pre_enrolled_keys
    }
  }

  dynamic "serial_device" {
    for_each = var.serial ? [1] : []
    content {}
  }

  dynamic "network_device" {
    for_each = var.nics
    content {
      model   = each.value.model
      bridge  = each.value.bridge
      vlan_id = each.value.vlan
    }
  }

  scsi_hardware = var.scsihw

  dynamic "disk" {
    for_each = var.disks
    content {
      file_id = (
        # Priority 1: download resource ID
        lookup(some_download_resource.disk_downloads, each.key, null) != null
        ? some_download_resource.disk_downloads[each.key].id
        # Priority 2: import_from if set
        : lookup(each.value, "import_from", null) != null
        ? each.value.import_from
        # Priority 3: null/unset
        : null
      )
      datastore_id = each.value.storage
      interface    = coalesce(each.value.interface, "scsi${each.key}")
      size         = each.value.size
      file_format = coalesce(
        each.value.format,
        each.value.storage == "local" ? "qcow2" : "raw"
      )
      cache    = each.value.cache
      iothread = each.value.iothread
      ssd      = each.value.ssd
      discard  = each.value.discard
    }
  }

  lifecycle {
    replace_triggered_by = [resource.terraform_data.combined_ci_hash]
  }
}
