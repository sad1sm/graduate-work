terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name
  v4_cidr_blocks = ["${var.subnet_cidr}"]
  zone           = var.zone
  network_id     = var.network_id
  route_table_id = var.route_table_id
}