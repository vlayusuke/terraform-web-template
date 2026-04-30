# ===============================================================================
# AWS Config (ap-northeast-1)
# Reference: https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/resource-config-reference.html
# ===============================================================================
resource "aws_config_configuration_recorder" "default" {
  name     = "${local.project}-${local.env}-aws-cfg-default"
  role_arn = aws_iam_role.config_recorder.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false

    resource_types = [
      "AWS::ACM::Certificate",
      "AWS::CloudFront::Distribution",
      "AWS::CloudFront::PublicKey",
      "AWS::CloudFront::StreamingDistribution",
      "AWS::CloudFront::RealtimeLogConfig",
      "AWS::CloudWatch::Alarm",
      "AWS::CloudWatch::MetricStream",
      "AWS::Logs::Destination",
      "AWS::EC2::EIP",
      "AWS::EC2::Instance",
      "AWS::EC2::NetworkInterface",
      "AWS::EC2::SecurityGroup",
      "AWS::EC2::NatGateway",
      "AWS::EC2::FlowLog",
      "AWS::EC2::VPCEndpoint",
      "AWS::EC2::VPCEndpointService",
      "AWS::EC2::SubnetRouteTableAssociation",
      "AWS::EC2::InternetGateway",
      "AWS::EC2::RouteTable",
      "AWS::EC2::Subnet",
      "AWS::EC2::VPC",
      "AWS::EC2::Volume",
      "AWS::ECR::Repository",
      "AWS::ECS::Cluster",
      "AWS::ECS::TaskDefinition",
      "AWS::ECS::Service",
      "AWS::ECS::CapacityProvider",
      "AWS::EFS::FileSystem",
      "AWS::KinesisFirehose::DeliveryStream",
      "AWS::RDS::DBCluster",
      "AWS::RDS::DBInstance",
      "AWS::RDS::DBSnapshot",
      "AWS::RDS::DBSubnetGroup",
      "AWS::Route53::HostedZone",
      "AWS::Route53::HealthCheck",
      "AWS::SES::ConfigurationSet",
      "AWS::SNS::Topic",
      "AWS::S3::Bucket",
      "AWS::S3::AccountPublicAccessBlock",
      "AWS::IAM::User",
      "AWS::IAM::Group",
      "AWS::IAM::Role",
      "AWS::IAM::Policy",
      "AWS::IAM::InstanceProfile",
      "AWS::IAM::OIDCProvider",
      "AWS::KMS::Key",
      "AWS::Lambda::Function",
      "AWS::SecretsManager::Secret",
      "AWS::WAFv2::WebACL",
      "AWS::WAFv2::ManagedRuleSet",
      "AWS::WAFv2::IPSet",
      "AWS::ElasticLoadBalancingV2::LoadBalancer",
      "AWS::ElasticLoadBalancingV2::Listener",
      "AWS::CloudTrail::Trail",
      "AWS::GuardDuty::Detector",
      "AWS::InspectorV2::Filter",
    ]
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
  sns_topic_arn  = aws_sns_topic.to_slack_audit.arn

  depends_on = [
    aws_config_configuration_recorder.default,
  ]

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.default,
  ]
}

resource "aws_cloudformation_stack" "operational_best_practices_for_cis" {
  name = "${local.project}-${local.env}-aws-cfg-operational-best-practices-for-cis"
  # commit: 9018e3a3003bde8d8898a2912de64cce39a20b80
  # https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS.yaml
  template_body = file("./files/config-cloudformation/Operational-Best-Practices-for-CIS.yaml")

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "${local.project}-${local.env}-aws-cfg-s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "${local.project}-${local.env}-aws-cfg-s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "rds_instance_public_access_check" {
  name = "${local.project}-${local.env}-aws-cfg-rds-instance-public-access-check"

  source {
    owner             = "AWS"
    source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}


# ===============================================================================
# AWS Config (Global / us-east-1)
# Reference: https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/resource-config-reference.html
# ===============================================================================
resource "aws_config_configuration_recorder" "default_global" {
  provider = aws.virginia
  name     = "${local.project}-${local.env}-aws-cfg-default-global"
  role_arn = aws_iam_role.config_recorder.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = true

    resource_types = [
      "AWS::ACM::Certificate",
      "AWS::CloudFront::Distribution",
      "AWS::CloudFront::PublicKey",
      "AWS::CloudFront::StreamingDistribution",
      "AWS::CloudFront::RealtimeLogConfig",
      "AWS::CloudWatch::Alarm",
      "AWS::CloudWatch::MetricStream",
      "AWS::Logs::Destination",
      "AWS::KinesisFirehose::DeliveryStream",
      "AWS::Route53::HostedZone",
      "AWS::Route53::HealthCheck",
      "AWS::SNS::Topic",
      "AWS::S3::Bucket",
      "AWS::S3::AccountPublicAccessBlock",
      "AWS::IAM::User",
      "AWS::IAM::Group",
      "AWS::IAM::Role",
      "AWS::IAM::Policy",
      "AWS::IAM::InstanceProfile",
      "AWS::IAM::OIDCProvider",
      "AWS::KMS::Key",
      "AWS::Lambda::Function",
      "AWS::SecretsManager::Secret",
      "AWS::WAFv2::WebACL",
      "AWS::WAFv2::ManagedRuleSet",
      "AWS::WAFv2::IPSet",
      "AWS::CloudTrail::Trail",
      "AWS::GuardDuty::Detector",
      "AWS::InspectorV2::Filter",
    ]
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_delivery_channel" "default_global" {
  provider       = aws.virginia
  name           = "${local.project}-${local.env}-aws-cfg-delivery-channel-global"
  s3_bucket_name = aws_s3_bucket.config_logs_global.bucket
  sns_topic_arn  = aws_sns_topic.to_slack_audit.arn

  depends_on = [
    aws_config_configuration_recorder.default_global,
  ]

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "default_global" {
  provider   = aws.virginia
  name       = aws_config_configuration_recorder.default_global.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.default_global,
  ]
}

resource "aws_cloudformation_stack" "operational_best_practices_for_cis_global" {
  provider = aws.virginia
  name     = "${local.project}-${local.env}-aws-cfg-operational-best-practices-for-cis-global"
  # commit: 9018e3a3003bde8d8898a2912de64cce39a20b80
  # https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS.yaml
  template_body = file("./files/config-cloudformation/Operational-Best-Practices-for-CIS.yaml")

  depends_on = [
    aws_config_configuration_recorder.default_global,
  ]
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled_global" {
  provider = aws.virginia
  name     = "${local.project}-${local.env}-aws-cfg-s3-sse-enabled-global"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default_global,
  ]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled_global" {
  provider = aws.virginia
  name     = "${local.project}-${local.env}-aws-cfg-s3-versioning-enabled-global"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default_global,
  ]
}
