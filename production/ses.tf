# ===============================================================================
# Amazon SES Domain Identity and Configuration
# ===============================================================================
resource "aws_ses_domain_identity" "main" {
  domain = local.domain
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_domain_mail_from" "main" {
  domain                 = aws_ses_domain_identity.main.domain
  mail_from_domain       = "bounce.${aws_ses_domain_identity.main.domain}"
  behavior_on_mx_failure = "UseDefaultValue"
}

resource "aws_ses_configuration_set" "main_event" {
  name                       = "${local.project}-${local.env}-ses-event"
  reputation_metrics_enabled = true
}

resource "aws_ses_identity_policy" "main" {
  identity = aws_ses_domain_identity.main.arn
  name     = "${local.project}-${local.env}-ses-identity-policy"
  policy   = data.aws_iam_policy_document.ses_identity_policy.json
}

data "aws_iam_policy_document" "ses_identity_policy" {
  statement {
    sid    = "AllowSESSendEmail"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      aws_ses_domain_identity.main.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}


# ===============================================================================
# Amazon SES Domain Verification and DNS Records
# ===============================================================================
resource "aws_route53_record" "ses_main_verification" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${local.domain}"
  type    = "TXT"
  ttl     = 300

  records = [
    aws_ses_domain_identity.main.verification_token,
  ]
}

resource "aws_route53_record" "ses_main_dkim" {
  count   = 3
  zone_id = aws_route53_zone.main.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${local.domain}"
  type    = "CNAME"
  ttl     = 300

  records = [
    "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com",
  ]
}

resource "aws_route53_record" "ses_main_spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:amazonses.com ~all",
  ]
}

resource "aws_route53_record" "ses_main_dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc.${local.domain}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1;p=none;pct=100;rua=mailto:postmaster@${local.domain}",
  ]
}

resource "aws_route53_record" "mail_from_mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = 300

  records = [
    "10 feedback-smtp.${local.region}.amazonses.com",
  ]
}


# ===============================================================================
# Amazon SES Send Events to Amazon Data Firehose
# ===============================================================================
resource "aws_ses_event_destination" "firehose" {
  name                   = "${local.project}-${local.env}-ses-to-adf"
  configuration_set_name = aws_ses_configuration_set.main_event.name
  enabled                = true

  matching_types = [
    "send",
    "reject",
    "delivery",
    "bounce",
    "complaint",
  ]

  kinesis_destination {
    stream_arn = aws_kinesis_firehose_delivery_stream.ses_event_logs.arn
    role_arn   = aws_iam_role.ses.arn
  }

  depends_on = [
    aws_kinesis_firehose_delivery_stream.ses_event_logs,
    aws_iam_role.ses,
    aws_iam_policy.ses,
    aws_iam_role_policy_attachment.ses,
    aws_iam_role_policy_attachment.amazon_data_firehose,
  ]
}


# ===============================================================================
# Amazon SES Send Events to Amazon CloudWatch Custom Metrics
# ===============================================================================
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "${local.project}-${local.env}-ses-to-cwt"
  configuration_set_name = aws_ses_configuration_set.main_event.name
  enabled                = true

  matching_types = [
    "reject",
    "bounce",
    "complaint",
  ]

  cloudwatch_destination {
    dimension_name = "AmazonSES-SendEvent"
    default_value  = "default"
    value_source   = "emailHeader"
  }
}
