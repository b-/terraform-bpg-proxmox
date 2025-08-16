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
  cloud_init_enabled = var.cloudinit != null ? true : false
  snippets_storage   = try(var.cloudinit.snippets_storage, var.cloudinit.storage, null)
}
module "cloud_init_files" {
  count  = local.cloud_init_enabled ? 1 : 0
  source = "../cloud-init-files"
  #source                   = "/var/home/bri/dev/terraform-proxmox-modules/modules/cloud-init-files"
  node                     = var.node
  ci_snippets_storage      = local.snippets_storage
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
  lifecycle {
    ignore_changes = [input]
    replace_triggered_by = [
      resource.terraform_data.combined_ci_hash
    ]
  }
}
locals {
  creation_date = resource.terraform_data.creation_date.output.timestamp
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
  started     = var.started != null ? var.started : !var.template
  template    = var.template

  stop_on_destroy = var.stop_on_destroy
  agent {
    enabled = var.qemu_guest_agent
  }

  dynamic "clone" {
    for_each = (local.is_clone ? [var.clone] : [])
    content {
      node_name = clone.value.template_node
      vm_id     = clone.value.template_id
      full      = clone.value.full
    }
  }

  # cloud-init config
  dynamic "initialization" {
    for_each = (var.cloudinit != null ? [1] : [])
    content {
      datastore_id         = var.cloudinit.storage
      meta_data_file_id    = module.cloud_init_files[0].meta_data_file_id
      network_data_file_id = module.cloud_init_files[0].network_data_file_id
      user_data_file_id    = module.cloud_init_files[0].user_data_file_id
      vendor_data_file_id  = module.cloud_init_files[0].vendor_data_file_id
      interface            = var.cloudinit.interface
      type                 = var.cloudinit.type
      # IP configuration from nics variable
      dynamic "dns" {
        for_each = var.dns != null ? [var.dns] : []
        content {
          domain  = dns.value.domain
          servers = dns.value.nameservers
        }
      }
      dynamic "ip_config" {
        for_each = var.nics
        content {
          dynamic "ipv4" {
            for_each = ip_config.value.ip_config != null && ip_config.value.ip_config.ipv4 != null ? [ip_config.value.ip_config.ipv4] : []
            content {
              address = ipv4.value.address
              gateway = ipv4.value.gateway
            }
          }
          dynamic "ipv6" {
            for_each = ip_config.value.ip_config != null && ip_config.value.ip_config.ipv6 != null ? [ip_config.value.ip_config.ipv6] : []
            content {
              address = ipv6.value.address
              gateway = ipv6.value.gateway
            }
          }
        }
      }
    }
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
      model       = network_device.value.model
      bridge      = network_device.value.bridge
      vlan_id     = length(network_device.value.vlans) == 1 ? network_device.value.vlans[0] : null
      trunks      = length(network_device.value.vlans) > 1 ? join(";", [for vlan in network_device.value.vlans : tostring(vlan)]) : null
      mac_address = network_device.value.mac
      firewall    = network_device.value.firewall

    }
  }

  scsi_hardware = var.scsihw

  dynamic "disk" {
    # omit if local.is_clone && var.disks == null
    for_each = (local.is_clone && var.disks == null) ? [] : var.disks
    content {
      path_in_datastore = try(coalesce(disk.value.path_in_datastore, disk.value.id), null)
      datastore_id = coalesce(disk.value.datastore_id,disk.value.storage)
      file_id = try(
        # Priority 1: download resource ID
        module.cloud_image[disk.key].id,
        # Priority 2: import_from if set
        disk.value.import_from,
        # Priority 3: null/unset
      null)
      interface    = coalesce(disk.value.interface, "scsi${disk.key}")
      size         = disk.value.size
      file_format = coalesce(
        disk.value.file_format,
        disk.value.format,
        disk.value.storage == "local" ? "qcow2" : "raw"
      )
      cache    = disk.value.cache
      iothread = disk.value.iothread
      ssd      = disk.value.ssd
      discard  = disk.value.discard ? "on" : "ignore"
    }
  }

  lifecycle {
    replace_triggered_by = [resource.terraform_data.combined_ci_hash]
  }
}
