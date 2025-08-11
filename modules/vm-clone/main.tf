terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name     = var.node
  vm_id         = var.vm_id
  name          = var.vm_name
  description   = var.description
  tags          = var.tags
  bios          = var.bios
  machine       = var.machine
  tablet_device = var.tablet

  operating_system {
    type = var.os_type
  }

  agent {
    enabled = var.qemu_guest_agent
  }

  clone {
    node_name = var.template_node
    vm_id     = var.template_id
    full      = var.full_clone
  }

  cpu {
    cores = var.vcpu
    type  = var.vcpu_type
    numa  = var.numa
  }

  memory {
    dedicated = var.memory
    floating  = var.memory_floating
  }

  dynamic "numa" {
    for_each = (var.numa == true ? [1] : [])
    content {
      device    = var.numa_device
      cpus      = var.numa_cpus
      memory    = var.numa_memory
      hostnodes = var.numa_hostnodes
      policy    = var.numa_policy
    }
  }

  vga {
    type   = var.display_type
    memory = var.display_memory
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

  network_device {
    model   = var.vnic_model
    bridge  = var.vnic_bridge
    vlan_id = var.vlan_tag
  }

  scsi_hardware = var.scsihw

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.disk_storage
      interface    = disk.value.disk_interface
      size         = disk.value.disk_size
      file_format  = disk.value.disk_format
      cache        = disk.value.disk_cache
      iothread     = disk.value.disk_iothread
      ssd          = disk.value.disk_ssd
      discard      = disk.value.disk_discard
    }
  }

  # cloud-init config
  initialization {
    datastore_id = var.ci_datastore_id
    meta_data_file_id = try(coalesce(
      var.ci_meta_data,
      try(module.cloud_init_files[0].meta_data_file_id, null)
    ), null)

    network_data_file_id = try(coalesce(
      var.ci_network_data,
      try(module.cloud_init_files[0].network_data_file_id, null)
    ), null)
    user_data_file_id = try(coalesce(
      var.ci_user_data,
      try(module.cloud_init_files[0].user_data_file_id, null)
    ), null)
    vendor_data_file_id = try(coalesce(
      var.ci_vendor_data,
      try(module.cloud_init_files[0].vendor_data_file_id, null)
    ), null)

    user_account {
      username = var.ci_user
      keys     = flatten([var.ci_ssh_key != null ? [var.ci_ssh_key] : [], var.ci_ssh_keys != null ? var.ci_ssh_keys : []])
    }

    dns {
      domain  = var.ci_dns_domain
      servers = (var.ci_dns_server != null ? [var.ci_dns_server] : [])
    }

    ip_config {
      ipv4 {
        address = var.ci_ipv4_cidr
        gateway = var.ci_ipv4_gateway
      }
    }
  }

  # Cloud-init SSH keys will cause a forced replacement, this is expected
  # behavior see https://github.com/bpg/terraform-provider-proxmox/issues/373
  lifecycle {
    ignore_changes = [initialization["user_account"], ]
  }
}

module "cloud_init_files" {
  source = "../cloud-init-files"
  count = (
    length(trimspace(coalesce(var.ci_snippets_storage, ""))) > 0 ||
    length(trimspace(coalesce(var.ci_meta_data_contents, ""))) > 0 ||
    length(trimspace(coalesce(var.ci_network_data_contents, ""))) > 0 ||
    length(trimspace(coalesce(var.ci_user_data_contents, ""))) > 0 ||
    length(trimspace(coalesce(var.ci_vendor_data_contents, ""))) > 0
  ) ? 1 : 0
  node                     = var.node
  ci_snippets_storage      = var.ci_snippets_storage
  ci_meta_data_contents    = var.ci_meta_data_contents
  ci_network_data_contents = var.ci_network_data_contents
  ci_user_data_contents    = var.ci_user_data_contents
  ci_vendor_data_contents  = var.ci_vendor_data_contents
}
