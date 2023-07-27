output "ip_address" {
  value = yandex_compute_instance.instance.network_interface.0.ip_address
}