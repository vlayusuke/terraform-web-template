# ===============================================================================
# AWS AWS Certificate Manager for Application Load Balancer
# ===============================================================================
resource "aws_acm_certificate" "main_alb" {
  domain_name       = local.base_domain
  validation_method = "DNS"

  validation_option {
    domain_name       = local.base_domain
    validation_domain = local.base_domain
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-alb"
  }
}

resource "aws_route53_record" "main_alb" {
  for_each = {
    for dvoalb in aws_acm_certificate.main_alb.domain_validation_options : dvoalb.domain_name => {
      name   = dvoalb.resource_record_name
      record = dvoalb.resource_record_value
      type   = dvoalb.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
  ttl             = 60

  records = [
    each.value.record,
  ]
}

resource "aws_acm_certificate_validation" "main_alb" {
  certificate_arn = aws_acm_certificate.main_alb.arn

  validation_record_fqdns = [
    for record in aws_route53_record.main_alb :
    record.fqdn
  ]
}


# ===============================================================================
# AWS Certificate Manager for Amazon CloudFront
# ===============================================================================
resource "aws_acm_certificate" "main_cloudfront" {
  provider          = aws.virginia
  domain_name       = local.base_domain
  validation_method = "DNS"

  validation_option {
    domain_name       = local.base_domain
    validation_domain = local.base_domain
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-cft"
  }
}

resource "aws_route53_record" "main_cloudfront" {
  for_each = {
    for dvocft in aws_acm_certificate.main_cloudfront.domain_validation_options : dvocft.domain_name => {
      name   = dvocft.resource_record_name
      record = dvocft.resource_record_value
      type   = dvocft.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
  ttl             = 60

  records = [
    each.value.record,
  ]
}

resource "aws_acm_certificate_validation" "main_cloudfront" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.main_cloudfront.arn

  validation_record_fqdns = [
    for record in aws_route53_record.main_cloudfront :
    record.fqdn
  ]
}
