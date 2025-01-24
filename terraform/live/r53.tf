data "aws_route53_zone" "aws_route53_zone" {
  name         = "hyprime.io"
  private_zone = false
}

resource "aws_route53_record" "reversed_ip" {
  name     = "reversed-ip.hyprime.io"
  type     = "CNAME"
  ttl      = 60
  zone_id  = data.aws_route53_zone.aws_route53_zone.zone_id

  records = [
    try(kubernetes_ingress_v1.reversed_ip.status[0].load_balancer[0].ingress[0].hostname, "hyprime.io")
  ]
}