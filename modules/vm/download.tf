locals {
  disks_with_download = {
    for idx, disk in var.disks : idx => disk
    if lookup(disk, "download", null) != null && lookup(disk.download, "url", null) != null
  }
}

module "cloud_image" {
  source   = "../image"
  #source                   = "/var/home/bri/dev/terraform-proxmox-modules/modules/image"
  for_each = local.disks_with_download

  node                     = var.node
  image_content_type       = each.value.download.content_type
  image_datastore_id       = each.value.download.storage
  image_filename           = each.value.download.filename != null ? each.value.download.filename : basename(each.value.download.url)
  image_url                = each.value.download.url
  image_checksum           = each.value.download.checksum
  image_checksum_algorithm = each.value.download.algorithm
  image_overwrite          = each.value.download.overwrite
  image_upload_timeout     = each.value.download.upload_timeout
}
