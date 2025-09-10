output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}

output "vpc_name" {
  value = google_compute_network.vpc_network.name
}

output "subnet_name" {
    value = google_compute_subnetwork.subnet.name
}


