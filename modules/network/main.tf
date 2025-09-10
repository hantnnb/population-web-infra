locals {
  web_tag  = "web-${var.name_prefix}"
}

# VPC
resource "google_compute_network" "vpc_network" {
    name = "${name_prefix}-vpc"
    description = "VPC network for ${name_prefix}"

    auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
    name          = "${name_prefix}-subnet"
    description   = "Subnet for ${name_prefix}"

    ip_cidr_range = var.subnet_cidr
    region        = var.region
    network       = google_compute_network.vpc_network.id
    private_ip_google_access = true
}

# Firewall rule - allow HTTP
resource "google_compute_firewall" "allow_http" {
    count = var.enable_http ? 1 : 0
    name    = "${name_prefix}-allow-http"
    network = google_compute_network.vpc_network.id

    allow {
        protocol = "tcp"
        ports    = ["80"]
    }

    direction = "INGRESS"
    source_ranges = var.http_source_ranges
    target_tags   = local.web_tag
}

# Firewall rule - allow HTTPS
resource "google_compute_firewall" "allow_https" {
    count = var.enable_https ? 1 : 0
    name    = "${name_prefix}-allow-https"
    network = google_compute_network.vpc_network.id

    allow {
        protocol = "tcp"
        ports    = ["443"]
    }

    direction = "INGRESS"
    source_ranges = var.https_source_ranges
    target_tags   = local.web_tag
}

# Firewall rule - allow SSH
resource "google_compute_firewall" "allow_ssh" {
    count = var.enable_ssh ? 1 : 0
    name    = "${name_prefix}-allow-ssh"
    network = google_compute_network.vpc_network.id

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    direction = "INGRESS"
    source_ranges = var.ssh_source_ranges
    target_tags   = local.web_tag
}