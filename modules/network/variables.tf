variable "name_prefix" {
  description = "Prefix for VPC/subnet/firewall names (e.g., pplt-dev)"
  type        = string
}

variable "region" {
  description = "Region for the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the subnet"
  type        = string
}

variable "enable_private_google_access" {
  description = "Whether to enable Private Google Access on the subnet"
  type        = bool
  default     = true
}

variable "network_labels" {
  description = "Optional labels to attach to resources that support labels"
  type        = map(string)
  default     = {}
}

# Firewall toggles
variable "enable_http"  { 
    type = bool
    default = true 
}
variable "enable_https" { 
    type = bool
    default = true 
}
variable "enable_ssh"   { 
    type = bool
    default = true 
}

# Firewall sources (you can narrow these later)
variable "http_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "https_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "ssh_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Extra target tags to attach to all rules (merged with the web tag)
variable "extra_target_tags" {
  description = "Additional target instance tags for firewall rules"
  type        = list(string)
  default     = []
}
