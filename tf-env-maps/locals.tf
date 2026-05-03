locals {
  name_prefix = "${var.project}-${var.environment}"

  config = var.env_config[var.environment]

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
  }
}
