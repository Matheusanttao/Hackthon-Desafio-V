output "vm_instance_01_ip" {
  value = google_compute_instance.vm_instance_01.network_interface[0].access_config[0].nat_ip
}

output "vm_instance_02_ip" {
  value = google_compute_instance.vm_instance_02.network_interface[0].access_config[0].nat_ip
}

output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}
