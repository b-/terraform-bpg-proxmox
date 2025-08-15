## VM Variables
variable "node" {
  description = "Name of Proxmox node to provision VM on, e.g. `pve`."
  type        = string
}

variable "started" {
  description = "Start the VM after creation."
  type        = bool
  default     = false
}

variable "template" {
  description = "Create a template VM."
  type        = bool
  default     = false
}

variable "vmid" {
  description = "ID number for new VM."
  type        = number
  default     = null
}

variable "name" {
  description = "Name, must be alphanumeric (may contain dash: `-`). Defaults to PVE naming, `VM <VM_ID>`."
  type        = string
  default     = null
}

variable "description" {
  description = "VM description."
  type        = string
  default     = null
}

variable "tags" {
  description = "Proxmox tags for the VM."
  type        = list(string)
  default     = ["terraform"]
}

variable "clone" {
  default = null
  type = object({
    # "Name of Proxmox node where the template resides, e.g. `pve`."
    template_node = string
    # "Proxmox template ID to clone."
    template_id = number
    # "Create a full independent clone; setting to `false` will create a linked clone."
    full = bool
  })
}

variable "os_type" {
  description = "QEMU OS type, e.g. `l26` for Linux 6.x - 2.6 kernel."
  type        = string
  default     = "l26"
}

variable "qemu_guest_agent" {
  description = "Enable QEMU guest agent."
  type        = bool
  default     = true
}


variable "machine_type" {
  description = "Hardware layout for the VM, `q35` or `x440i`."
  type        = string
  default     = "q35"
  validation {
    condition     = contains(["q35", "x440i"], var.machine_type)
    error_message = "Unknown machine setting."
  }
}

variable "serial" {
  description = "Enable serial port."
  type        = bool
  default     = true
}

variable "tablet" {
  description = "Enable tablet for pointer."
  type        = bool
  default     = false
}

variable "display_type" {
  type    = string
  default = null
}

variable "display_memory" {
  type    = number
  default = null
}

variable "vcpu" {
  description = "Number of CPU cores."
  type        = number
  default     = 1
}

variable "vcpu_type" {
  description = "CPU type."
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Memory size in `MiB`."
  type        = number
  default     = 1024
}

variable "memory_floating" {
  description = "Minimum memory size in `MiB`, setting this value enables memory ballooning."
  type        = number
  default     = null
}

variable "numa" {
  description = "Emulate NUMA architecture."
  type = object({
    device    = optional(string, null)
    cpus      = optional(string, null)
    memory    = optional(string, null)
    hostnodes = optional(string, null)
    policy    = optional(string, "preferred")
  })
  default = null
}

## Disk Variables

variable "scsihw" {
  description = "SCSI controller type."
  type        = string
  default     = "virtio-scsi-single" # more advanced and faster than virtio-scsi-pci
  validation {
    condition = contains([
      "lsi",                # LSI Logic SAS1068E.
      "lsi53c810",          # LSI Logic 53C810.
      "virtio-scsi-pci",    # VirtIO SCSI.
      "virtio-scsi-single", # VirtIO SCSI (single queue).
      "megasas",            # LSI Logic MegaRAID SAS.
      "pvscsi",             # VMware Paravirtual SCSI.
    ], var.scsihw)
    error_message = "Unknown SCSI controller."
  }
}

variable "disks" {
  description = "List of disks to attach."
  type = list(object({
    # id to import
    import_from = optional(string, null)
    # datastore_id to store disk on, defaults to local
    storage = optional(string, "local")
    # interface to attach disk to vm on, e.g., scsi0
    interface = optional(string, null)
    # disk size in GB, defaults to 8
    size   = optional(number, 8)
    format = optional(string, "raw")
    # cache setting
    cache = optional(string, "writeback")
    # iothread setting
    iothread = optional(bool, true)
    # report that the disk is an ssd
    ssd = optional(bool, false)
    # enable TRIM to reclaim unused bytes
    discard = optional(bool, false)
    download = optional(object({ # new optional download object
      filename       = optional(string)
      url            = string
      checksum       = string
      algorithm      = optional(string, "sha256")
      storage        = optional(string, "local")
      content_type   = optional(string, "iso")
      overwrite      = optional(bool, false)
      upload_timeout = optional(number)
    }))
  }))
  default = [{}]
#    # id to import
#    import_from =  null
#    # datastore_id to store disk on, defaults to local
#    storage =  "local"
#    # interface to attach disk to vm on, e.g., scsi0
#    interface =  null
#    # disk size in GB, defaults to 8
#    size   =  8
#    format =  "raw"
#    # cache setting
#    cache =  "writeback"
#    # iothread setting
#    iothread =  true
#    # report that the disk is an ssd
#    ssd =  false
#    # enable TRIM to reclaim unused bytes
#    discard =  false
#    download = null
#  }]
}

variable "efi" {
  description = "Enable EFI."
  type = object({
    # "EFI disk storage location."
    storage = optional(string, "local")
    # "EFI disk storage format."
    format = optional(string, "raw")
    # "EFI disk OVMF firmware version."
    type = optional(string, "4m")
    # "EFI disk enable pre-enrolled secure boot keys."
    pre_enrolled_keys = optional(bool, false)
  })
  default = null
}

## Cloud-init Variables
variable "cloudinit" {
  type = object({
    # "Disk storage location for the cloud-init disk."
    storage = optional(string, "local-lvm")
    # Disk storage location to write custom cloud-init `_contents` snippets. Must have `snippets` enabled in Datacenter options.
    snippets_storage = optional(string, "local")
    # "Hardware interface for cloud-init configuration data."
    interface = optional(string, "ide2")
    # "Type of cloud-init datasource."
    type = optional(string, "nocloud")
    # meta_data file contents
    meta_data = optional(string, null)
    # user_data file contents
    user_data = optional(string, null)
    # network_data file contents
    network_data = optional(string, null)
    # vendor_data file contents
    vendor_data = optional(string, null)
  })
  default = null
}

variable "nics" {
  description = "nic objects"
  type = list(object({
    model  = optional(string, "virtio")
    bridge = optional(string, "vmbr0")
    vlan   = optional(number, null)
  }))
  default = [{
    model  = "virtio"
    bridge = "vmbr0"
    vlan   = null
  }]
}
