variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for deployment"
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "GCP zone for the instance"
  type        = string
  default     = "europe-west9-a"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "todo_server" {
  name         = "todo-server"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230214"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Assign an ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "chinenyeonyema1:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOM
    #!/bin/bash
    echo $(hostname -I) > /tmp/inventory
  EOM
}

resource "google_compute_firewall" "todo_firewall" {
  name    = "todo-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]  # Open to all (consider restricting for security)
}

