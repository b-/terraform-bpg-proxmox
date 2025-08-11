variable "node" {
  description = "Name of Proxmox node to download image on, e.g. `pve`."
  type        = string
}

variable "ci_meta_data_contents" {
  description = "Add the contents of a custom cloud-init `meta` configuration file, e.g `local:snippets/meta-data.yaml`."
  type        = string
  default     = null
  sensitive   = true
}

variable "ci_network_data_contents" {
  description = "Add the contents of a custom cloud-init `network` configuration file, e.g `local:snippets/network-data.yaml`."
  type        = string
  default     = null
  sensitive   = true
}

variable "ci_user_data_contents" {
  description = "Add the contents of a custom cloud-init `user` configuration file, e.g `local:snippets/user-data.yaml`."
  type        = string
  default     = null
  sensitive   = true
}

variable "ci_vendor_data_contents" {
  description = "Add the contents of a custom cloud-init `vendor` configuration file, e.g `local:snippets/vendor-data.yaml`."
  type        = string
  default     = null
  sensitive   = true
}

variable "ci_snippets_storage" {
  description = "Disk storage location to write custom cloud-init `_contents` snippets. Must have `snippets` enabled in Datacenter options."
  type        = string
}
