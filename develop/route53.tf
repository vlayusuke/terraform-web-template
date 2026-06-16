# ================================================================================
# Amazon Route 53 Host Zone
# ================================================================================
resource "aws_route53_zone" "main" {
  name          = "${local.env}.${local.domain}"
  comment       = "Amazon Route 53 Host Zone for ${local.project}-${local.env}"
  force_destroy = false

  tags = {
    Name = "${local.project}-${local.env}-r53-host-zone"
  }
}


# ================================================================================
# Amazon Route 53 Record
# ================================================================================
resource "aws_route53_record" "main_A" {
  zone_id        = aws_route53_zone.main.id
  name           = "${local.env}.${local.domain}"
  type           = "A"
  set_identifier = "${local.project}-${local.env}-r53-record-a"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }

  geolocation_routing_policy {
    country = "JP"
  }
}

resource "aws_route53_record" "main_AAAA" {
  zone_id        = aws_route53_zone.main.id
  name           = "${local.env}.${local.domain}"
  type           = "AAAA"
  set_identifier = "${local.project}-${local.env}-r53-record-aaaa"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }

  geolocation_routing_policy {
    country = "JP"
  }
}


# ================================================================================
# Amazon Route 53 Health Check
# ================================================================================
resource "aws_route53_health_check" "main" {
  fqdn              = "${local.env}.${local.domain}"
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${local.project}-${local.env}-r53-health-check"
  }
}
