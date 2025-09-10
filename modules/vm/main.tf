# Create a custom service account for the VM
# Used by VM for authentication with GCP services
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "Custom SA for VM Instance"
  # member = "serviceAccount:${google_service_account.vm_sa.email}"
}

# IAM binding to allow others to attach this SA to instance
# Required for Terraform runner SA or other users to attach/impersonate this SA when creating VM
resource "google_service_account_iam_member" "sa_users" {
  for_each           = toset(var.sa_user_members)
  service_account_id = google_service_account.vm_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}

# Lookup latest Ubuntu image from family
# Avoids hardcoding specific image version
# Always use the latest image in the family at time of terraform apply
data "google_compute_image" "ubuntu" {
  family  = var.image_family
  project = var.image_project
}

# Reserved static eip
resource "google_compute_address" "static_eip" {
  name   = "${var.name_prefix}-ip"
  region = var.region

  lifecycle {
    prevent_destroy = true
  }
}

# Provision VM instance
resource "google_compute_instance" "vm_instance" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web-${var.name_prefix}"]

  # Create a boot disk using the Ubuntu image fetched earlier
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }
  
  # Attach VM to specified network and subnetwork
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    # Assign the reserved static IP to the VM
    # Without this, VM would get ephemeral IP and private-only
    access_config {
      nat_ip = google_compute_address.static_eip.address
    }
  }

  # Key-value pairs available to the instance via metadata server at boot
  # Future improvement: use secret manager instead
  metadata = {
    env_file               = var.env_file
    env_backend            = var.env_backend
    ssh-keys               = "ubuntu:${var.ssh_pubkey}"

    # Optional: Block project-wide SSH keys
    # Safer: only SSH keys defined here are accepted for this instance
    # Prevent unintended access by key added at project level
    block-project-ssh-keys = "TRUE"
  }

  # Shell script runs on first boot of the instance
  metadata_startup_script = var.startup_script_content
  
  # Attach the custom service account to the VM
  service_account {
    email  = google_service_account.vm_sa.email

    # Let IAM roles fully control access; scope is unrestricted
    scopes = ["cloud-platform"]
  }

  # Explicit dependency to service account
  depends_on = [google_service_account.vm_sa]
}