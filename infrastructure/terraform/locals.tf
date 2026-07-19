locals {
  name_prefix = "frigg-${var.environment}"
  common_tags = merge(var.tags, {
    environment = var.environment
    managed-by  = "terraform"
  })
}
