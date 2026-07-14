locals {
  name_prefix = "icberg-${var.environment}"
  common_tags = merge(var.tags, {
    environment = var.environment
    managed-by  = "terraform"
  })
}
