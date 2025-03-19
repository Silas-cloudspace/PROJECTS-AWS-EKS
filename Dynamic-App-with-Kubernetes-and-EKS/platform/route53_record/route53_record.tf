# Backend Route traffic to the Kubernetes-managed ALB:
resource "aws_route53_record" "api_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "api"
  type    = "A"

  alias {
    name                   = data.aws_lb.k8s_alb.dns_name
    zone_id                = data.aws_lb.k8s_alb.zone_id
    evaluate_target_health = true
  }
}