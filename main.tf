provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "hackathon-vpc"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "192.168.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.152.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_instance" "vm_instance_01" {
  name         = "vm-instance-01"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet1.self_link
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOT
}

resource "google_compute_instance" "vm_instance_02" {
  name         = "vm-instance-02"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet2.self_link
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOT
}

resource "google_compute_firewall" "default-allow-http" {
  name    = "default-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_global_address" "default" {
  name = "lb-ipv4"
}

resource "google_compute_target_http_proxy" "default" {
  name        = "http-lb-proxy"
  url_map     = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  health_checks         = [google_compute_health_check.default.self_link]
  backend {
    group = google_compute_instance_group.default.self_link
  }
}

resource "google_compute_health_check" "default" {
  name = "http-basic-check"
  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_instance_group" "default" {
  name        = "instance-group"
  instances   = [
    google_compute_instance.vm_instance_01.self_link,
    google_compute_instance.vm_instance_02.self_link
  ]
}

resource "google_compute_forwarding_rule" "default" {
  name        = "http-content-rule"
  target      = google_compute_target_http_proxy.default.self_link
  port_range  = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_address  = google_compute_global_address.default.address
}
