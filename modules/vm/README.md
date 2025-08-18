# BPG Proxmox VM Template Module

## Requirements

| Name        | Version  |
| ----------- | -------- |
| [terraform] | >= 1.5.0 |

### PVE Permissions

- Downloading image on a PVE node requires `Datastore.AllocateTemplate`, `Sys.Audit` and `Sys.Modify` permission to the
  root directory, `/`.

## Providers

| Name          | Version   |
| ------------- | --------- |
| [bpg proxmox] | >= 0.53.1 |

## Inputs

### Template Variables

| Variable         | Default   | Type         | Description                                                                               | Required |
| ---------------- | --------- | ------------ | ----------------------------------------------------------------------------------------- | -------- |
| node             |           | String       | Name of Proxmox node to download the image and provision VM on, e.g. `pve`                | **Yes**  |
| vm_id            |           | Number       | ID number for new VM                                                                      | **Yes**  |
| vm_name          | `null`    | String       | Name, must be alphanumeric (may contain dash: `-`). Defaults to PVE naming, `VM <VM_ID>`. | no       |
| description      | `null`    | String       | VM description                                                                            | no       |
| tags             | `null`    | List(String) | Proxmox tags for the VM                                                                   | no       |
| bios             | `seabios` | String       | VM bios, setting to `ovmf` will automatically create a EFI disk                           | no       |
| qemu_guest_agent | `true`    | Boolean      | Enable QEMU guest agent                                                                   | no       |
| machine_type     | `q35`     | String       | Hardware layout for the VM, `q35` or `x440i`.                                             | no       |
| vcpu             | `1`       | Number       | Number of CPU cores                                                                       | no       |
| vcpu_type        | `host`    | String       | CPU type                                                                                  | no       |
| memory           | `1024`    | Number       | Memory size in `MiB`                                                                      | no       |
| memory_floating  | `1024`    | Number       | Minimum memory size in `MiB`, setting this value enables memory ballooning                | no       |

### Disk Variables

| Variable                   | Default     | Type    | Description                                   | Required |
| -------------------------- | ----------- | ------- | --------------------------------------------- | -------- |
| efi_disk_storage           | `local-lvm` | String  | EFI disk storage location                     | no       |
| efi_disk_format            | `raw`       | String  | EFI disk storage format                       | no       |
| efi_disk_type              | `4m`        | String  | EFI disk OVMF firmware version                | no       |
| efi_disk_pre_enrolled_keys | `true`      | Boolean | EFI disk enable pre-enrolled secure boot keys | no       |
| disk_storage               | `local-lvm` | String  | Disk storage location                         | no       |
| disk_interface             | `scsi0`     | String  | Disk storage interface                        | no       |
| disk_size                  | `8`         | Number  | Disk size                                     | no       |
| disk_format                | `raw`       | String  | Disk format                                   | no       |
| disk_cache                 | `writeback` | String  | Disk cache                                    | no       |
| disk_iothread              | `false`     | Boolean | Enable IO threading                           | no       |
| disk_ssd                   | `true`      | Boolean | Enable SSD emulation                          | no       |
| disk_discard               | `on`        | String  | Enable TRIM                                   | no       |

### Image Variables

| Variable                 | Default  | Type    | Description                                         | Required |
| ------------------------ | -------- | ------- | --------------------------------------------------- | -------- |
| image_filename           | `null`   | String  | Filename, default `null` will extract name from URL | no       |
| image_url                |          | String  | Image URL                                           | **Yes**  |
| image_checksum           |          | String  | Image checksum value                                | **Yes**  |
| image_checksum_algorithm | `sha256` | String  | Image checksum algorithm                            | no       |
| image_datastore_id       | `local`  | String  | PVE disk location for images                        | no       |
| image_content_type       | `iso`    | String  | PVE folder name for images                          | no       |
| image_overwrite          | `false`  | Boolean | Overwrite pre-existing image on PVE host            | no       |
| image_upload_timeout     | `600`    | Number  | Image upload timeout in seconds                     | no       |

### Cloud-init Variables

| Variable           | Default   | Type   | Description                                                                                  | Required |
| ------------------ | --------- | ------ | -------------------------------------------------------------------------------------------- | -------- |
| ci_interface       | `ide2`    | String | Hardware interface for cloud-init configuration data                                         | no       |
| ci_datasource_type | `nocloud` | String | Type of cloud-init datasource                                                                | no       |
| ci_meta_data       | `null`    | String | Add a custom cloud-init `meta` configuration file, e.g `local:snippets/meta-data.yaml`       | no       |
| ci_network_data    | `null`    | String | Add a custom cloud-init `network` configuration file, e.g `local:snippets/network-data.yaml` | no       |
| ci_user_data       | `null`    | String | Add a custom cloud-init `user` configuration file, e.g `local:snippets/user-data.yaml`       | no       |
| ci_vendor_data     | `null`    | String | Add a custom cloud-init `vendor` configuration file, e.g `local:snippets/vendor-data.yaml`   | no       |

## Examples

- [See example Template configurations](../../examples/vm-template/main.tf)

## CLI Commands

Downloaded images are protected from deletion, so calling `terraform destroy` will fail. To delete a specific template
use the example below:

```sh
# remove vm template
terraform destroy -target='module.ubuntu22.proxmox_virtual_environment_vm.vm_template'
```

[terraform]: https://github.com/hashicorp/terraform
[bpg proxmox]: https://github.com/bpg/terraform-provider-proxmox

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>=1.5.0)

- <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) (>=0.53.1)

- <a name="requirement_time"></a> [time](#requirement\_time) (>= 0.13.1)

## Providers

The following providers are used by this module:

- <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) (0.82.0)

- <a name="provider_terraform"></a> [terraform](#provider\_terraform)

- <a name="provider_time"></a> [time](#provider\_time) (0.13.1)

## Modules

The following Modules are called:

### <a name="module_cloud_image"></a> [cloud\_image](#module\_cloud\_image)

Source: ../image

Version:

### <a name="module_cloud_init_files"></a> [cloud\_init\_files](#module\_cloud\_init\_files)

Source: ../cloud-init-files

Version:

## Resources

The following resources are used by this module:

- [proxmox_virtual_environment_vm.vm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) (resource)
- [terraform_data.combined_ci_hash](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.creation_date](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [time_static.creation_date](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_node"></a> [node](#input\_node)

Description: Name of Proxmox node to provision VM on, e.g. `pve`.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_boot_order"></a> [boot\_order](#input\_boot\_order)

Description: n/a

Type: `list(string)`

Default: `null`

### <a name="input_clone"></a> [clone](#input\_clone)

Description: n/a

Type:

```hcl
object({
    # "Name of Proxmox node where the template resides, e.g. `pve`."
    template_node = string
    # "Proxmox template ID to clone."
    template_id = number
    # "Create a full independent clone; setting to `false` will create a linked clone."
    full = optional(bool, true)
  })
```

Default: `null`

### <a name="input_cloudinit"></a> [cloudinit](#input\_cloudinit)

Description: # Cloud-init Variables

Type:

```hcl
object({
    # "Disk storage location for the cloud-init disk."
    storage = optional(string, "local")
    # Disk storage location to write custom cloud-init `_contents` snippets. Must have `snippets` enabled in Datacenter options.
    snippets_storage = optional(string)
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
```

Default: `null`

### <a name="input_description"></a> [description](#input\_description)

Description: VM description.

Type: `string`

Default: `null`

### <a name="input_disks"></a> [disks](#input\_disks)

Description: List of disks to attach.

Type:

```hcl
list(object({
    # id (path_in_datastore) to use, raw, without importing first
    id                = optional(string, null)
    path_in_datastore = optional(string, null) # overrides above for compatibility

    # id to import
    import_from = optional(string, null)

    # datastore_id to store disk on, defaults to local
    storage      = optional(string, "local")
    datastore_id = optional(string, null) # overrides above for compatibility

    # interface to attach disk to vm on, e.g., scsi0
    interface = optional(string, null)
    # disk size in GB, defaults to 8
    size        = optional(number, 8)
    format      = optional(string, null)
    file_format = optional(string, null) # overrides above for compatibility
    # cache setting
    cache = optional(string, "writeback")
    # iothread setting
    iothread = optional(bool, true)
    # report that the disk is an ssd
    ssd = optional(bool, false)
    # enable TRIM to reclaim unused bytes
    discard = optional(string, "on")
    download = optional(object({ # new optional download object
      filename       = optional(string)
      url            = string
      checksum       = string
      algorithm      = optional(string, "sha256")
      storage        = optional(string, "local")
      content_type   = optional(string, "import")
      overwrite      = optional(bool, false)
      upload_timeout = optional(number)
    }))
  }))
```

Default: `null`

### <a name="input_display_memory"></a> [display\_memory](#input\_display\_memory)

Description: n/a

Type: `number`

Default: `null`

### <a name="input_display_type"></a> [display\_type](#input\_display\_type)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_dns"></a> [dns](#input\_dns)

Description: n/a

Type:

```hcl
object({
    domain      = optional(string, null)
    nameservers = optional(list(string), null)
  })
```

Default: `null`

### <a name="input_efi"></a> [efi](#input\_efi)

Description: Enable EFI.

Type:

```hcl
object({
    # "EFI disk storage location."
    storage = optional(string, "local")
    # "EFI disk storage format."
    format = optional(string, "raw")
    # "EFI disk OVMF firmware version."
    type = optional(string, "4m")
    # "EFI disk enable pre-enrolled secure boot keys."
    pre_enrolled_keys = optional(bool, false)
  })
```

Default: `null`

### <a name="input_extra_disks"></a> [extra\_disks](#input\_extra\_disks)

Description: List of additional disks to attach.

Type:

```hcl
list(object({
    # id (path_in_datastore) to use, raw, without importing first
    id                = optional(string, null)
    path_in_datastore = optional(string, null) # overrides above for compatibility

    # id to import
    import_from = optional(string, null)

    # datastore_id to store disk on, defaults to local
    storage      = optional(string, "local")
    datastore_id = optional(string, null) # overrides above for compatibility

    # interface to attach disk to vm on, e.g., scsi0
    interface = optional(string, null)
    # disk size in GB, defaults to 8
    size        = optional(number, 8)
    format      = optional(string, null)
    file_format = optional(string, null) # overrides above for compatibility
    # cache setting
    cache = optional(string, "writeback")
    # iothread setting
    iothread = optional(bool, true)
    # report that the disk is an ssd
    ssd = optional(bool, false)
    # enable TRIM to reclaim unused bytes
    discard = optional(string, "on")
    download = optional(object({ # new optional download object
      filename       = optional(string)
      url            = string
      checksum       = string
      algorithm      = optional(string, "sha256")
      storage        = optional(string, "local")
      content_type   = optional(string, "import")
      overwrite      = optional(bool, false)
      upload_timeout = optional(number)
    }))
  }))
```

Default: `[]`

### <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type)

Description: Hardware layout for the VM, `q35` or `pc`.

Type: `string`

Default: `"q35"`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Memory size in `MiB`.

Type: `number`

Default: `1024`

### <a name="input_memory_floating"></a> [memory\_floating](#input\_memory\_floating)

Description: Minimum memory size in `MiB`, setting this value enables memory ballooning.

Type: `number`

Default: `null`

### <a name="input_name"></a> [name](#input\_name)

Description: Name, must be alphanumeric (may contain dash: `-`). Defaults to PVE naming, `VM <VM_ID>`.

Type: `string`

Default: `null`

### <a name="input_nics"></a> [nics](#input\_nics)

Description: nic objects

Type:

```hcl
list(object({
    model    = optional(string, "virtio")
    bridge   = optional(string, "vmbr0")
    vlans    = optional(list(number), [])
    mac      = optional(string, null)
    firewall = optional(bool, false)
    ip_config = optional(object({
      ipv4 = optional(object({
        address = string
        gateway = optional(string)
      }))
      ipv6 = optional(object({
        address = string
        gateway = optional(string)
      }))
    }))
  }))
```

Default:

```json
[
  {
    "bridge": "vmbr0",
    "firewall": false,
    "ip_config": null,
    "mac": null,
    "model": "virtio",
    "vlans": null
  }
]
```

### <a name="input_numa"></a> [numa](#input\_numa)

Description: Emulate NUMA architecture.

Type:

```hcl
object({
    device    = optional(string, null)
    cpus      = optional(string, null)
    memory    = optional(string, null)
    hostnodes = optional(string, null)
    policy    = optional(string, "preferred")
  })
```

Default: `null`

### <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot)

Description: Start VM on boot.

Type: `bool`

Default: `true`

### <a name="input_os_type"></a> [os\_type](#input\_os\_type)

Description: QEMU OS type, e.g. `l26` for Linux 6.x - 2.6 kernel.

Type: `string`

Default: `"l26"`

### <a name="input_qemu_guest_agent"></a> [qemu\_guest\_agent](#input\_qemu\_guest\_agent)

Description: Enable QEMU guest agent.

Type: `bool`

Default: `true`

### <a name="input_scsihw"></a> [scsihw](#input\_scsihw)

Description: SCSI controller type.

Type: `string`

Default: `"virtio-scsi-single"`

### <a name="input_serial"></a> [serial](#input\_serial)

Description: Enable serial port.

Type: `bool`

Default: `true`

### <a name="input_started"></a> [started](#input\_started)

Description: Start the VM after creation.

Type: `bool`

Default: `null`

### <a name="input_stop_on_destroy"></a> [stop\_on\_destroy](#input\_stop\_on\_destroy)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_tablet"></a> [tablet](#input\_tablet)

Description: Enable tablet for pointer.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Proxmox tags for the VM.

Type: `list(string)`

Default:

```json
[
  "terraform"
]
```

### <a name="input_template"></a> [template](#input\_template)

Description: Create a template VM.

Type: `bool`

Default: `false`

### <a name="input_vcpu"></a> [vcpu](#input\_vcpu)

Description: Number of CPU cores.

Type: `number`

Default: `1`

### <a name="input_vcpu_type"></a> [vcpu\_type](#input\_vcpu\_type)

Description: CPU type.

Type: `string`

Default: `"host"`

### <a name="input_vmid"></a> [vmid](#input\_vmid)

Description: ID number for new VM.

Type: `number`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_creation_date"></a> [creation\_date](#output\_creation\_date)

Description: n/a

### <a name="output_disks"></a> [disks](#output\_disks)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: Instance VM ID

### <a name="output_ipv4_addresses"></a> [ipv4\_addresses](#output\_ipv4\_addresses)

Description: n/a

### <a name="output_ipv6_addresses"></a> [ipv6\_addresses](#output\_ipv6\_addresses)

Description: n/a

### <a name="output_mac_addresses"></a> [mac\_addresses](#output\_mac\_addresses)

Description: n/a

### <a name="output_meta_data"></a> [meta\_data](#output\_meta\_data)

Description: n/a

### <a name="output_network_data"></a> [network\_data](#output\_network\_data)

Description: n/a

### <a name="output_user_data"></a> [user\_data](#output\_user\_data)

Description: n/a

### <a name="output_vendor_data"></a> [vendor\_data](#output\_vendor\_data)

Description: n/a
<!-- END_TF_DOCS -->
