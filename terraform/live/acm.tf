module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  domain_name  = "hyprime.io"
  zone_id      = "Z04985752S18IFBLX5I7P"
  validation_method = "DNS"
  wait_for_validation = true
}