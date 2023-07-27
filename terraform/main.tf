terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
  token                    = "***REMOVED***"
  cloud_id                 = "***REMOVED***"
  folder_id                = "***REMOVED***"
}

resource "yandex_vpc_network" "network" {
  name = "netology-network"
}

module "network_zone_a" {
  source       = "./modules/vpc_network"
  zone         = "ru-central1-a"
  subnet_name  = "public-zone-a"
  subnet_cidr  = "192.168.10.0/24"
  network_id   = resource.yandex_vpc_network.network.id
}

module "network_zone_b" {
  source       = "./modules/vpc_network"
  zone         = "ru-central1-b"
  subnet_name  = "public-zone-b"
  subnet_cidr  = "192.168.20.0/24"
  network_id   = resource.yandex_vpc_network.network.id
}



