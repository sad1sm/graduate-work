terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "network" {
  name = "netology-network"
}

module "network_zone_a" {
  source      = "./modules/vpc_network"
  zone        = "ru-central1-a"
  subnet_name = "public-zone-a"
  subnet_cidr = "192.168.10.0/24"
  network_id  = resource.yandex_vpc_network.network.id
}

module "network_zone_b" {
  source      = "./modules/vpc_network"
  zone        = "ru-central1-b"
  subnet_name = "public-zone-b"
  subnet_cidr = "192.168.20.0/24"
  network_id  = resource.yandex_vpc_network.network.id
}

module "vm_instance" {
  source          = "./modules/vm_instance"
  zone            = "ru-central1-a"
  node_count      = "3"
  instance_name   = var.vm_instance_name
  platform_id     = var.vm_instance_platform_id
  resource_core   = var.vm_instance_core
  resource_memory = var.vm_instance_memory
  image_id        = var.vm_instance_image_id
  disk_size       = var.vm_instance_disk
  nat             = true
  subnet_id       = module.network_zone_a.subnet_id
}

