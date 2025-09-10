# Without this block, Terraform may not recognize the Cloudflare provider
# and use hashicorp/cloudflare instead of cloudflare/cloudflare
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0, < 6.0"
    }
  }
}

# Create DNS record in Cloudflare
resource "cloudflare_dns_record" "dns_record" {
  zone_id = var.zone_id
  name    = var.name
  content = var.ip_address
  type    = var.dns_type
  proxied = var.isProxied
  ttl     = var.ttl
}