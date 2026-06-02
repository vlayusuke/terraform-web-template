# AWS Cost Estimation for terraform-web-template

このドキュメントは、terraform-web-templateで構築されるAWSリソースの1環境あたり1ヶ月間 (730時間)のコスト見積もりです。

**リージョン**: ap-northeast-1 (Tokyo)
**計算基準**: 月間730時間 (30日 × 24時間)
**対象環境**: develop, staging, production (各環境で同じ構成を想定)

---

## 1. 計算対象外リソース (無料または最小限のコスト)

以下のリソースは**無料または無視できるコストで提供**されています：

- AWS CloudFormation の stack 定義
- AWS IAM (Identity and Access Management)
- AWS KMS - 最初の1000リクエスト/月は無料
- AWS Secrets Manager - 最初のシークレット1つは無料、以降$0.4/月
- AWS Systems Manager Parameter Store - 無料版
- AWS Route 53 - hosted zone ($0.50/月)
- VPC、Security Groups、Network ACLs - 無料
- VPC Flow Logs (CloudWatch Logs への出力時のログストレージコストのみ計上)
- AWS CloudWatch Alarms - 無料

---

## 2. コスト見積もり (月間 730 時間ベース)

### 2.1 Amazon Aurora RDS

**構成:**

- Engine: MySQL 8.0 with Aurora
- Instance Type: `db.t4g.medium` × 2 (プライマリ + レプリカ)
- Backup Retention: 14 日
- Performance Insights: 有効化 (7日間保持)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Aurora MySQL インスタンス (db.t4g.medium) | 2 | ¥0.314/時間 | ¥458.84 |
| Aurora ストレージ | 100 GB (推定) | ¥0.238/GB | ¥23.80 |
| バックアップストレージ (14日間) | 50 GB (推定) | ¥0.238/GB | ¥11.90 |
| Performance Insights | 1 | ¥0.0308/時間 | ¥22.48 |
| **Aurora 月額合計** | | | **¥517.02** |

---

### 2.2 Amazon ElastiCache (Redis)

**構成:**

- Node Type: `cache.t4g.medium` × 2 (マルチAZ有効化)
- Engine: Redis 7.2
- Automatic Failover: 有効化

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| ElastiCache ノード (cache.t4g.medium) | 2 | ¥0.146/時間 | ¥213.16 |
| キャッシュデータの転送 (推定) | 10 GB | ¥0.0 | ¥0.00 |
| **ElastiCache 月額合計** | | | **¥213.16** |

---

### 2.3 Amazon ECS Fargate

**構成:**

- App Service: 2 タスク (0.25 CPU + 0.5 GB メモリ)
- Cron Service: 1 タスク (0.25 CPU + 0.5 GB メモリ)
- Queue Service: 1 タスク (0.25 CPU + 0.5 GB メモリ)
- Migrate Service: オンデマンド実行 (月5回実行と想定)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Fargate CPU (0.25 CPU) | 208 CPU時間/月 | ¥0.02515/CPU時間 | ¥5.23 |
| Fargate メモリ (0.5 GB) | 416 GB時間/月 | ¥0.00274/GB時間 | ¥1.14 |
| **ECS Fargate 月額合計** | | | **¥6.37** |

**注:**

- App Service: 2 タスク × 24h × 30d = 1,440 タスク時間
- Cron Service: 1 タスク × 24h × 30d = 720 タスク時間
- Queue Service: 1 タスク × 24h × 30d = 720 タスク時間
- Migrate Service: 5 回実行 × 10分 = 50分/月

---

### 2.4 Amazon EC2 (Bastion Host)

**構成:**

- Instance Type: `t4g.nano`
- Root Volume: 8 GB (gp3)
- EBS Volume: 64 GB (gp3)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| EC2 インスタンス (t4g.nano) | 730 時間 | ¥0.0104/時間 | ¥7.59 |
| EBS Root Volume (8 GB gp3) | 8 GB | ¥0.095/GB | ¥0.76 |
| EBS Data Volume (64 GB gp3) | 64 GB | ¥0.095/GB | ¥6.08 |
| Elastic IP アドレス | 1 | ¥1.40/月 | ¥1.40 |
| **EC2 月額合計** | | | **¥15.83** |

---

### 2.5 Application Load Balancer (ALB)

**構成:**

- 1 × ALB (インターネット対向)
- 1 × Target Group

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| ALB 時間単価 | 730 時間 | ¥0.0205/時間 | ¥14.97 |
| ALB 処理単価 (推定 1,000万/月) | 10,000,000 LCU | ¥0.0000014/LCU | ¥14.00 |
| **ALB 月額合計** | | | **¥28.97** |

---

### 2.6 Amazon CloudFront

**構成:**

- 1 × Distribution
- 複数 Origin (ALB, S3 assets, S3 uploads)
- オリジナルリクエスト推定: 月 10 GB

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| CloudFront Data Transfer Out (10 GB) | 10 GB | ¥0.085/GB | ¥0.85 |
| CloudFront HTTP/HTTPS Requests | 1,000,000 件 | ¥0.010/10,000件 | ¥1.00 |
| **CloudFront 月額合計** | | | **¥1.85** |

---

### 2.7 Amazon S3

**構成:**

- Assets Bucket
- Uploads Bucket
- Logs Bucket (ALB, VPC Flow Logs)
- SES Event Logs Bucket
- S3 標準ストレージ推定: 50 GB

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| S3 ストレージ (標準) | 50 GB | ¥0.023/GB | ¥1.15 |
| S3 PUT リクエスト | 10,000 件 | ¥0.00000442/件 | ¥0.04 |
| S3 GET リクエスト | 100,000 件 | ¥0.00000035/件 | ¥0.04 |
| S3 オブジェクト削除 | 5,000 件 | ¥0 | ¥0.00 |
| **S3 月額合計** | | | **¥1.23** |

---

### 2.8 Amazon CloudWatch Logs

**構成:**

- ECS ログ (App, Cron, Queue, Migrate)
- Aurora ログ (audit, error, general, slowquery, iam-db-auth-error)
- ALB ログ
- VPC Flow Logs
- Lambda ログ
- ElastiCache ログ
- Log Group 保持期間: 30日

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| ログ取得量 (推定 50 GB/月) | 50 GB | ¥0.538/GB | ¥26.90 |
| ログストレージ (推定 100 GB 保持) | 100 GB | ¥0.0323/GB | ¥3.23 |
| **CloudWatch Logs 月額合計** | | | **¥30.13** |

---

### 2.9 Amazon Kinesis Data Firehose

**構成:**

- 5 × Delivery Stream (Aurora ログ用: audit, error, general, slowquery, iam-db-auth-error)
- 各ストリームの出力先: S3

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Firehose PUT リクエスト (推定 100,000件/月) | 100,000 | ¥0.38/100万件 | ¥0.04 |
| Firehose vCPU時間 (推定 0.1 vCPU時間) | 0.1 | ¥0.149/vCPU時間 | ¥0.01 |
| **Firehose 月額合計** | | | **¥0.05** |

---

### 2.10 AWS Lambda

**構成:**

- `rds_control`: RDS制御
- `lambda_log_error_alert`: エラーアラート
- `lambda_metric_alarm`: メトリクスアラーム
- `lambda_schedule_ecs_maintenance`: ECS定期メンテナンス
- `lambda_execute_ecs_force_deployment`: ECSデプロイメント

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Lambda 実行回数 (推定 50,000回/月) | 50,000 | ¥0.0000002/件 | ¥0.01 |
| Lambda 実行時間 (推定 1,000秒/月 at 256MB) | 1,000,000 ms | ¥0.0000166667/ms | ¥0.02 |
| **Lambda 月額合計** | | | **¥0.03** |

---

### 2.11 AWS SNS (Simple Notification Service)

**構成:**

- Topic: metric-alarm notifications
- Topic: event notifications

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| SNS Publish リクエスト (推定 1,000/月) | 1,000 | ¥0.00/件 | ¥0.00 |
| SNS Email Notifications (推定 50/月) | 50 | ¥0.00202/件 | ¥0.10 |
| **SNS 月額合計** | | | **¥0.10** |

---

### 2.12 AWS WAFv2 (Web Application Firewall)

**構成:**

- CloudFront 用 Web ACL

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| WAFv2 Web ACL | 1 | ¥6.50/月 | ¥6.50 |
| WAFv2 Rules (推定 5 rules) | 5 | ¥1.00/ルール | ¥5.00 |
| WAFv2 Requests (推定 1,000万/月) | 10,000,000 | ¥0.00000060/件 | ¥6.00 |
| **WAFv2 月額合計** | | | **¥17.50** |

---

### 2.13 AWS Data Lifecycle Manager (DLM)

**構成:**

- EBS スナップショット自動作成ポリシー
- スナップショット保持期間: 7日

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| EBS スナップショット (推定 5 snapshots × 72 GB) | 360 GB | ¥0.018/GB | ¥6.48 |
| **DLM 月額合計** | | | **¥6.48** |

---

### 2.14 AWS Certificate Manager (ACM)

**構成:**

- 2 × ACM Certificate (ALB用, CloudFront用)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| ACM 証明書 | 2 | ¥0 | ¥0.00 |
| **ACM 月額合計** | | | **¥0.00** |

---

### 2.15 AWS Route 53

**構成:**

- 1 × Hosted Zone

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Hosted Zone | 1 | ¥0.50/月 | ¥0.50 |
| Query (推定 10,000,000/月) | 10,000,000 | ¥0.40/百万件 | ¥4.00 |
| **Route 53 月額合計** | | | **¥4.50** |

---

### 2.16 Amazon VPC Endpoints

**構成:**

- Interface VPC Endpoints (複数サービス用)
- Gateway Endpoints (S3, DynamoDB)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Interface Endpoint (推定 3 endpoints) | 3 | ¥7.30/月 | ¥21.90 |
| Endpoint リクエスト (推定 1,000万/月) | 10,000,000 | ¥0.01/百万件 | ¥0.10 |
| Gateway Endpoint | 2 | ¥0 | ¥0.00 |
| **VPC Endpoints 月額合計** | | | **¥22.00** |

---

### 2.17 AWS API Gateway

**構成:**

- なし (このテンプレートでは非該当)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| **API Gateway 月額合計** | | | **¥0.00** |

---

### 2.18 AWS DynamoDB

**構成:**

- なし (このテンプレートでは非該当)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| **DynamoDB 月額合計** | | | **¥0.00** |

---

### 2.19 AWS EFS (Elastic File System)

**構成:**

- 1 × EFS (ECS タスク用)
- ストレージ推定: 10 GB

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| EFS ストレージ (標準ストレージクラス) | 10 GB | ¥0.23/GB | ¥2.30 |
| EFS Infrequent Access | 5 GB | ¥0.033/GB | ¥0.17 |
| EFS スループット | - | ¥0 (バースト) | ¥0.00 |
| **EFS 月額合計** | | | **¥2.47** |

---

### 2.20 Amazon Inspector v2

**構成:**

- 対象リソース: EC2, ECR, Lambda

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Inspector ベース費用 | 1 | ¥0/月 (初年度無料) | ¥0.00 |
| Inspector EC2スキャン | 1 インスタンス | 推定 ¥0/月 | ¥0.00 |
| **Inspector v2 月額合計** | | | **¥0.00** |

---

### 2.21 AWS ECR (Elastic Container Registry)

**構成:**

- 1 × ECR リポジトリ
- ストレージ推定: 5 GB

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| ECR ストレージ | 5 GB | ¥0.071/GB | ¥0.36 |
| ECR データ転送 (Out) | 1 GB | ¥0.114/GB | ¥0.11 |
| **ECR 月額合計** | | | **¥0.47** |

---

### 2.22 AWS Config

**構成:**

- AWS Config (audit 環境のみで有効化)

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| Config レコーディング | - | ¥0 (推定) | ¥0.00 |
| **AWS Config 月額合計** | | | **¥0.00** |

---

### 2.23 AWS CloudTrail

**構成:**

- CloudTrail (audit 環境のみで有効化)
- ログ出力先: S3

| 項目 | 数量 | 単価 | 月額コスト |
| :---- | ----: | ----: | ----: |
| CloudTrail Management Events | - | ¥0 (推定) | ¥0.00 |
| S3 ストレージ (CloudTrail ログ) | 1 GB | ¥0.023/GB | ¥0.02 |
| **CloudTrail 月額合計** | | | **¥0.02** |

---

## 3. 環境別月額コスト合計

### 3.1 develop/staging/production 環境 (1環境あたり)

| カテゴリ | 月額コスト |
| :---- | ----: |
| Aurora RDS | ¥517.02 |
| ElastiCache | ¥213.16 |
| ECS Fargate | ¥6.37 |
| EC2 (Bastion) | ¥15.83 |
| ALB | ¥28.97 |
| CloudFront | ¥1.85 |
| S3 | ¥1.23 |
| CloudWatch Logs | ¥30.13 |
| Kinesis Firehose | ¥0.05 |
| Lambda | ¥0.03 |
| SNS | ¥0.10 |
| WAFv2 | ¥17.50 |
| DLM | ¥6.48 |
| ACM | ¥0.00 |
| Route 53 | ¥4.50 |
| VPC Endpoints | ¥22.00 |
| EFS | ¥2.47 |
| Inspector v2 | ¥0.00 |
| ECR | ¥0.47 |
| AWS Config | ¥0.00 |
| CloudTrail | ¥0.02 |
| **1環境あたりの月額合計** | **¥868.19** |

### 3.2 audit 環境

**注:** audit環境は、セキュリティ＆コンプライアンス系のリソースが中心のため、コストが大きく異なります。

| カテゴリ | 月額コスト |
| :---- | ----: |
| CloudTrail | ¥100.00 (推定) |
| AWS Config | ¥50.00 (推定) |
| Inspector v2 | ¥50.00 (推定) |
| CloudWatch Logs | ¥20.00 (推定) |
| S3 (ログ保存) | ¥10.00 (推定) |
| Lambda (検証機能) | ¥5.00 (推定) |
| SNS | ¥2.00 (推定) |
| **audit環境の月額合計** | **¥237.00 (推定)** |

---

## 4. 3環境 (dev/staging/prd)+ audit のトータルコスト

```text
= (¥868.19 × 3) + ¥237.00
= ¥2,604.57 + ¥237.00
= ¥2,841.57/月額
```

**年間コスト**: ¥2,841.57 × 12 = **¥34,098.84**

---

## 5. コスト削減機会

### 5.1 Reserved Instances (RI) による削減

Aurora RDS インスタンスに 1年間のRIを適用した場合、**約40%のコスト削減**が期待できます。

- Aurora (1年RI): ¥517.02 → ¥310.21/月 (¥206.81削減)

### 5.2 Savings Plans による削減

Fargate、EC2、RDS に Savings Plans を適用した場合、**約20-25%のコスト削減**が期待できます。

### 5.3 CloudFront キャッシュ最適化

CloudFront のキャッシュ設定を最適化して、オリジナルリクエストを削減した場合、ALB と CloudFront のコストを削減できます。

### 5.4 ログ保持期間の短縮

CloudWatch Logs の保持期間を 30日から 7日に短縮した場合、**約75%のログストレージコスト削減**が期待できます。

- CloudWatch Logs: ¥30.13 → ¥7.53/月 (¥22.60削減)

---

## 6. 注意事項

1. **データ転送料金**: VPC 内でのデータ転送は無料ですが、インターネット経由のデータ転送にはコストが発生します。実際の使用パターンに応じて調整が必要です。

2. **ストレージサイズ**: このドキュメントで使用しているストレージサイズ (Aurora: 100GB、S3: 50GB など)は**推定値**です。実際の使用量に応じて調整してください。

3. **リクエスト数**: CloudFront、CloudWatch Logs のリクエスト数も推定値です。実際のアクセスパターンに応じて変動します。

4. **リージョン料金**: このドキュメントは東京リージョン (ap-northeast-1)の料金を使用しています。他のリージョンを使用する場合は、AWS 公式の料金ページから最新の料金を確認してください。

5. **価格変動**: AWS の料金は予告なく変更される場合があります。最新の料金は [AWS 料金ページ](https://aws.amazon.com/jp/pricing/) を参照してください。

6. **無料利用枠**: AWS アカウントが作成されたばかりの場合、無料利用枠の対象になる場合があります。詳細は [AWS 無料利用枠](https://aws.amazon.com/jp/free/) を参照してください。

---

## 7. より正確なコスト算出方法

より正確なコスト見積もりを取得するには、以下の方法を推奨します：

### 方法1: AWS Cost Explorer を使用

AWS マネジメントコンソールの Cost Explorer で、実際のコスト実績を確認できます。

### 方法2: AWS Pricing API を使用

AWS Pricing API を使用して、プログラマティックにリソース別の最新料金を取得できます。

### 方法3: Terraform を用いたコスト自動計算

Infracost などのツールを使用して、Terraform から自動的にコスト見積もりを生成できます。

```bash
# Infracost のインストール
brew install infracost

# コスト見積もりの生成
cd develop
infracost breakdown --path .
```

---

## 8. 参考資料

- [AWS 料金ページ](https://aws.amazon.com/jp/pricing/)
- [AWS RDS 料金](https://aws.amazon.com/jp/rds/pricing/)
- [AWS ElastiCache 料金](https://aws.amazon.com/jp/elasticache/pricing/)
- [AWS ECS 料金](https://aws.amazon.com/jp/ecs/pricing/)
- [AWS CloudFront 料金](https://aws.amazon.com/jp/cloudfront/pricing/)
- [AWS S3 料金](https://aws.amazon.com/jp/s3/pricing/)
- [Infracost - Terraform cost estimation](https://www.infracost.io/)

---

**最終更新**: 2026年6月3日
**計算対象リージョン**: ap-northeast-1 (Tokyo)
