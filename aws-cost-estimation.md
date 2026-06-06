# AWS Cost Estimation for terraform-web-template

このドキュメントは、`terraform-web-template`で構築されるAWSリソースの1環境あたり1ヶ月間(730時間)のコスト見積もり示したものです。為替変動を考慮して、コストはUSDで算出しています。

なお、アウトバウンド通信のデータ転送にかかるコストは推定値を含むため、全体的なコストは変動する可能性があります。

- **Region**: `ap-northeast-1` (Tokyo)
- **Calculation basis**: 730 hours/month (30d × 24h)
- **Target environments**: `develop`, `staging`, `production` (同一構成を想定)

## 1. 計算対象外リソース (無料または最小限のコスト)

以下は概ね無料、または無視できるコストとして扱っています (詳細はAWSの料金表を参照):

- AWS IAM, AWS CloudFormation
- AWS KMS (最初のリクエスト等は無料枠あり)
- AWS Secrets Manager (最初のシークレット等は無料枠あり)
- AWS Systems Manager Parameter Store (無料版)
- Amazon Route 53 Hosted Zone (小額)
- AMazon VPC / Security Groups / NACL (管理面でのコストは無料)

## 2. コスト見積もり (730 時間/月 ベース)

### 2.1 Amazon Aurora (Aurora MySQL)

**構成**:

- Engine: aurora-mysql
- Instance: `db.t4g.medium` × 2
- ストレージ想定: 100 GB
- バックアップストレージ想定: 50 GB

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Aurora instance (`db.t4g.medium`) | 2 | $0.03 / hr | $43.80 |
| Storage (estimate) | 100 GB | $0.10 / GB-month | $10.00 |
| Backup storage (estimate) | 50 GB | $0.10 / GB-month | $5.00 |
| Performance Insights etc (estimate) | 1 | — | $5.00 |
| **Aurora subtotal** | | | **$63.80** |

### 2.2 Amazon ElastiCache (Redis OSS)

**構成**:

- Node Type: `cache.t4g.medium` × 2

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| ElastiCache node (`cache.t4g.medium`) | 2 | $0.024 / hr | $35.04 |
| **ElastiCache subtotal** | | | **$35.04** |

### 2.3 Amazon ECS (AWS Fargate)

**構成 (Terraform 参照)**:

- app service: desired_count = 2 (cpu=256, memory=512)
- cron: 1 (cpu=256, memory=512)
- queue: 1 (cpu=256, memory=512)

合算想定:

- 合計 vCPU: 1.00 vCPU  (= 4 × 0.25)
- 合計 memory: 2.0 GB
- vCPU時間: 1.00 × 730 = 730 vCPU-hr
- Memory時間: 2.0 × 730 = 1,460 GB-hr

料金想定:

- vCPU: $0.04048 / vCPU-hr
- Memory: $0.004445 / GB-hr

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Fargate vCPU | 730 vCPU-hr | $0.04048 / vCPU-hr | $29.55 |
| Fargate Memory | 1,460 GB-hr | $0.004445 / GB-hr | $6.49 |
| **Fargate subtotal** | | | **$36.04** |

### 2.4 Amazon EC2 (Bastion)

**構成**:

- Instance: `t4g.nano` (730h)
- EBS total: 72 GB (root 8 GB + data 64 GB, gp3 想定)

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| EC2 `t4g.nano` | 730 hr | $0.0052 / hr | $3.80 |
| EBS gp3 (72 GB) | 72 GB | $0.08 / GB-month | $5.76 |
| Elastic IP (typical) | 1 | monthly | $0.00–small (included) |
| **EC2 subtotal** | | | **$9.56** |

### 2.5 Application Load Balancer (ALB)

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| ALB (time + LCU estimate) | — | — | **$22.27** |

### 2.6 Amazon CloudFront

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Data Out 10 GB + requests (estimate) | 10 GB + requests | — | **$1.85** |

### 2.7 Amazon S3

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| S3 storage 50 GB (standard) | 50 GB | $0.023 / GB | $1.15 |
| S3 requests (small) | — | — | included |
| **S3 subtotal** | | | **$1.15** |

### 2.8 Amazon CloudWatch Logs

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Log ingestion 50 GB (estimate) + storage | — | — | **$28.00** |

### 2.9 Amazon Data Firehose

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Firehose (small usage estimate) | — | — | **$0.05** |

### 2.10 AWS Lambda

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Lambda (small usage estimate) | — | — | **$0.03** |

### 2.11 Amazon SNS

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| SNS (small usage) | — | — | **$0.10** |

### 2.12 AWS WAFv2

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| WAFv2 Web ACL + rules + requests (estimate) | — | — | **$12.00** |

### 2.13 Data Lifecycle Manager (EBS snapshots)

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Snapshot storage 360 GB (estimate) | 360 GB | $0.05 / GB | $18.00 |

### 2.14 AWS Certificate Manager

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| ACM public certificates | — | free | $0.00 |

### 2.15 Amazon Route 53

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Hosted Zone + queries (estimate) | — | — | $4.50 |

### 2.16 VPC Endpoints

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| Interface Endpoints (3 × $7.30/month) | 3 | $7.30 / endpoint-mo | $21.90 |

### 2.17 Amazon API Gateway

テンプレート内に該当なし（見積対象外）

### 2.18 Amazon DynamoDB

テンプレート内に該当なし（見積対象外）

### 2.19 Amazon EFS

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| EFS small usage estimate | — | — | **$3.13** |

### 2.20 Amazon Inspector v2

初年度無料枠等を考慮し小額/無料扱い（推定）

### 2.21 Amazon ECR

| Item | Qty | Unit price | Monthly cost |
| :---- | ----: | ----: | ----: |
| ECR storage 5 GB | 5 GB | $0.10 / GB-month (approx) | $0.50 |

### 2.22 AWS Config

`audit` 環境のみ有効化想定。小額/概算扱い。

### 2.23 AWS CloudTrail

S3保存分等の小額: **$0.02**

### 2.24 Amazon GuardDuty

S3やCloudTrail、VPC Flow Logs等を解析して脅威検出を行うAmazon GuardDutyと関連リソースが`audit`配下で実装されています。主なリソースは`aws_guardduty_detector`、複数の`aws_guardduty_detector_feature`（S3 Data Events, RDS login events, EBS malware protection, runtime monitoring）、`aws_guardduty_publishing_destination`（S3出力）、および専用のKMSキーです。

| 項目 | 数量/想定 | 単価(目安) | 月額コスト (USD) |
| :---- | ----: | ----: | ----: |
| GuardDuty データ解析 (推定) | ~50 GB 分析 | $0.20 / GB (概算) | $10.00 |
| S3 Data Events 機能 (追加解析) | 中程度の活動量 | 概算 | $10.00 |
| GuardDuty ログ用 S3 ストレージ | 10 GB | $0.023 / GB | $0.23 |
| KMS CMK (customer-managed key) | 1 key | $1.00 / month (概算) | $1.00 |
| **GuardDuty 小計 (概算)** | | | **$21.23** |

**注:** GuardDuty の実コストは検出対象・ログ量・分析対象の種類によって大きく変動します。上記は中小規模の設定を想定した概算です。

## 3. 環境別月額コスト合計 (1 環境あたり)

| Category | Monthly cost (USD) |
| :---- | ----: |
| Amazon Aurora | $63.80 |
| Amazon ElastiCache | $35.04 |
| Amazon ECS | $36.04 |
| Amazon EC2 (Bastion + EBS) | $9.56 |
| Application Load Balancer | $22.27 |
| Amazon CloudFront | $1.85 |
| Amazon S3 | $1.15 |
| Amazon CloudWatch Logs | $28.00 |
| Amazon Data Firehose | $0.05 |
| AWS Lambda | $0.03 |
| Amazon SNS | $0.10 |
| AWS WAFv2 | $12.00 |
| AWS Data Lifecycle Manager (snapshots) | $18.00 |
| AWS Certificate Manager | $0.00 |
| Amazon Route 53 | $4.50 |
| VPC Endpoints | $21.90 |
| Amazon EFS | $3.13 |
| Amazon Inspector v2 | $0.00 |
| Amazon ECR | $0.50 |
| AWS Config | $0.00 |
| AWS CloudTrail | $0.02 |
| **Monthly total (per environment)** | **$257.94** |

## 4. `audit` 環境 (概算)

`audit` 環境はセキュリティ/監査向けのリソースに偏るため別途概算しています。

| Category | Monthly cost (USD) |
| :---- | ----: |
| AWS CloudTrail | $10–100 (estimate) |
| AWS Config | $10–50 (estimate) |
| Amazon Inspector v2 | $0–50 (estimate) |
| Amazon CloudWatch Logs | $5–20 (estimate) |
| Amazon S3 (logs) | $1–10 (estimate) |
| AWS Lambda | $0–5 (estimate) |
| Amazon SNS | $0–2 (estimate) |
| Amazon GuardDuty | $21.23 (estimate) |
| **audit monthly total (estimate)** | **$258.23 (estimate)** |

## 5. 合計 （3 環境 + `audit`）

概算:

```text
= ($257.94 × 3) + $258.23 (audit estimate) = $773.82 + $258.23 = $1,032.05 / month
```

## 6. コスト削減案

- Reserved Instances / Savings Plans の適用 (Aurora, Fargate, EC2 など)
- CloudWatch Logs の保持期間短縮
- CloudFront キャッシュ最適化
- スナップショット・バックアップの削減/ライフサイクルポリシー

## 7. 精度向上の手段

- `infracost` を用いて Terraform から自動で見積を生成することを推奨します。

```bash
brew install infracost
cd develop
infracost breakdown --path .
```

---

最終更新: 2026-06-07
