# ===============================================================================
# AWS AWS Certificate Manager for Application Load Balancer
# ===============================================================================
resource "aws_acm_certificate" "main" {
  domain_name       = "${local.env}.${local.domain}"
  validation_method = "DNS"

  validation_option {
    domain_name       = "${local.env}.${local.domain}"
    validation_domain = "${local.env}.${local.domain}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate"
  }
}

resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
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

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.main :
    record.fqdn
  ]
}


# ===============================================================================
# AWS Certificate Manager for Amazon CloudFront
# ===============================================================================
resource "aws_acm_certificate" "main_cloudfront" {
  domain_name       = "${local.env}.${local.domain}"
  validation_method = "DNS"
  provider          = aws.virginia

  validation_option {
    domain_name       = "${local.env}.${local.domain}"
    validation_domain = "${local.env}.${local.domain}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-cf"
  }
}

resource "aws_route53_record" "main_cloudfront" {
  for_each = {
    for dvocf in aws_acm_certificate.main_cloudfront.domain_validation_options : dvocf.domain_name => {
      name   = dvocf.resource_record_name
      record = dvocf.resource_record_value
      type   = dvocf.resource_record_type
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
