variable "GCP_SERVICE_ACCOUNT_FILE" {
  type     = string
  nullable = false
}

variable "GCP_PROJECT_ID" {
  type     = string
  nullable = false
}

variable "GCP_REGION" {
  type     = string
  nullable = false
}

variable "GCP_ZONE" {
  type     = string
  nullable = false
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  # load credentials from env GCP_TERRAFORM_CREDENTIALS
  credentials = file(var.GCP_SERVICE_ACCOUNT_FILE)

  project = var.GCP_PROJECT_ID
  zone    = var.GCP_ZONE
  region  = var.GCP_REGION
}


resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.GCP_REGION
}

# Allow SSH traffic from anywhere
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name = "allow-http"

  allow {
    ports    = ["80"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  depends_on = [google_compute_network.vpc_network]

  metadata_startup_script = file("vm-startup-script.sh")

  name         = "terraform-instance"
  machine_type = "n1-standard-1"
  zone         = var.GCP_ZONE

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.id
    network    = google_compute_network.vpc_network.id

    access_config {

    }
  }
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
