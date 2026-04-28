# ===============================================================================
# Amazon CloudFront Distribution
# ===============================================================================
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = false
  http_version    = "http2and3"
  comment         = "${local.project}-${local.env} CloudFront Distribution"
  #  web_acl_id      = aws_wafv2_web_acl.main.arn

  aliases = [
    local.domain,
  ]

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.main_cloudfront.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  origin {
    domain_name = aws_lb.main_external.dns_name
    origin_id   = aws_lb.main_external.name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name              = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.assets.id
    origin_id                = aws_s3_bucket.assets.id
  }

  origin {
    domain_name              = aws_s3_bucket.uploads.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.uploads.id
    origin_id                = aws_s3_bucket.uploads.id
  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress                   = true
    path_pattern               = "/public/*"
    smooth_streaming           = false
    target_origin_id           = aws_s3_bucket.assets.bucket
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress                   = true
    path_pattern               = "/uploads/*"
    smooth_streaming           = false
    target_origin_id           = aws_s3_bucket.uploads.bucket
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "DELETE",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    smooth_streaming           = false
    target_origin_id           = aws_lb.main_external.name
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id

    forwarded_values {
      headers                 = ["*"]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "all"
      }
    }

    #    function_association {
    #      event_type   = "viewer-request"
    #      function_arn = aws_cloudfront_function.basic_auth.arn
    #    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  depends_on = [
    aws_acm_certificate_validation.main_cloudfront,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cloudfront-distribution"
  }
}


# ===============================================================================
# Amazon CloudFront Response Headers Policy
# ===============================================================================
resource "aws_cloudfront_response_headers_policy" "main" {
  name = "${local.project}-${local.env}-cloudfront-response-header-policy"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
  }
}


# ===============================================================================
# Amazon CloudFront Cache Policy
# ===============================================================================
resource "aws_cloudfront_cache_policy" "main" {
  name        = "${local.project}-${local.env}-cloudfront-cache-policy"
  comment     = "Amazon CloudFront Cache Policy for ${local.project}-${local.env}"
  default_ttl = 86400
  max_ttl     = 259200
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}


# ===============================================================================
# Origin Access Control
# ===============================================================================
resource "aws_cloudfront_origin_access_control" "assets" {
  name                              = "${local.project}-${local.env}-oac-assets"
  description                       = "Origin Access Control for ${local.project}-${local.env} assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "uploads" {
  name                              = "${local.project}-${local.env}-oac-uploads"
  description                       = "Origin Access Control for ${local.project}-${local.env} uploads"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# If you want to use CloudFront Functions, you can add the resource definition here. However, please note that CloudFront Functions are only supported in certain regions and may not be available in all AWS accounts. Make sure to check the AWS documentation for the latest information on CloudFront Functions availability and usage.
# ===============================================================================
# CloudFront Functions
# ===============================================================================
# resource "aws_cloudfront_function" "basic_auth" {
#   name    = "${local.project}-${local.env}-cf-fnc-basic-auth"
#   runtime = "cloudfront-js-2.0"
#   comment = "${local.project}-${local.env} CloudFront Functions for basic authentication"
#   publish = true
#   code    = file("${path.module}/files/cloudfront_functions/basic_auth.js")
# }
