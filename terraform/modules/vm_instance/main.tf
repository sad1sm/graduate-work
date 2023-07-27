terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_instance" "instance" {
  count       = var.node_count
  name        = "${var.instance_name}-${count.index + 1}"
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores  = var.resource_core
    memory = var.resource_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id  = var.subnet_id
    ip_address = var.ip_address
    nat        = var.nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./.ssh/id_ed25519.pub")}"
  }
}