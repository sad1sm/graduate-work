terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_container_registry" "default" {
  name      = var.cr_name
  folder_id = var.folder_id
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.default.id
  role        = "container-registry.images.puller"

  members = [
    "system:allUsers",
  ]
}