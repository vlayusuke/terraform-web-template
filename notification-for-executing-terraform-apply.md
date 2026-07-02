# `terraform apply`を実行する際の注意事項 (Terraform / AWS)

このドキュメントは、`terraform apply`を実行する際に発生しやすい以下の問題を減らし、発生時に迅速に復旧するための運用手順をまとめたものです。

1. IAM 伝播遅延
2. KMS キー状態の異常
3. Secrets Manager の `import` / `state` 不整合

## 1. IAM 伝播遅延

### 1.1. 典型的な症状

- 作成時に IAM 権限チェックが入るリソースで、`terraform apply`が失敗する。
- 代表的なエラー例:
  - `aws_cloudwatch_log_subscription_filter`作成時の`firehose:PutRecord`に対する`AccessDenied`
  - ロールやポリシーアタッチ直後の権限不足エラー

### 1.2. 発生理由

- Terraformの依存関係が正しくても、AWS IAMの反映は結果整合性のため即時ではない。
- API上は作成済みでも、連携先サービスからすぐに利用できないことがある。

### 1.3. 予防策

- 作成時に権限が必要なリソースには、明示的に`depends_on`を設定する。
- 特に`aws_iam_role_policy_attachment`への依存関係を明確にする。

### 1.4. 運用時の対処

1. 権限系エラーで初回`terraform apply`が失敗し、設定自体が正しい場合は`30-120`秒待つ。
2. `terraform apply`を再実行する。
3. まだ失敗する場合は、ロールの信頼ポリシーとポリシーアタッチ状態を確認する。

## 2. KMS キー状態の確認

### 2.1. 典型的な症状

- AWS Secrets Manager、AWS SSM SecureString、各種サービス連携で暗号化/復号が失敗する。
- キー無効または不正なキー状態を示すエラーが出る。

### 2.2. 問題になりやすい状態

- `PendingDeletion`
- `Disabled`

### 2.3. キー状態の確認コマンド

```bash
AWS_PAGER='' aws kms describe-key \
  --profile terraform-template \
  --region ap-northeast-1 \
  --key-id <key-id-or-arn> \
  --query 'KeyMetadata.KeyState' \
  --output text
```

### 2.4. 復旧手順

- 状態が`PendingDeletion`の場合は、削除予約を取り消す。

```bash
AWS_PAGER='' aws kms cancel-key-deletion \
  --profile terraform-template \
  --region ap-northeast-1 \
  --key-id <key-id-or-arn>
```

- 状態が`Disabled`の場合は、キーを有効化する。

```bash
AWS_PAGER='' aws kms enable-key \
  --profile terraform-template \
  --region ap-northeast-1 \
  --key-id <key-id-or-arn>
```

- 再度キー状態を確認し、`Enabled`になっていることを確認する。

### 2.4. ポリシー設計の注意点

- AWS KMS ポリシーの`principal`にIAMグループの`arn`は使わない。
- 各`statement`に有効な`Resource`と有効な`principal`を必ず設定する。

## 3. Secrets Manager の import 手順

### 3.1. 典型的な症状

- AWS側に既存シークレットがあるのに、Terraformが新規作成しようとして失敗する。
- `already exists`系のエラーが出る。

### 3.2. 主な原因

- リージョンサービスの問題ではなく、Terraform state と実リソースの不整合。

### 3.3. import 手順

- 既存シークレットの`arn`を取得する。

```bash
AWS_PAGER='' aws secretsmanager describe-secret \
  --profile terraform-template \
  --region ap-northeast-1 \
  --secret-id <secret-name-or-arn> \
  --query 'ARN' \
  --output text
```

- `arn`を使って`import`する (推奨)。

```bash
terraform import <terraform_resource_address> <secret-arn>
```

例:

```bash
terraform import aws_secretsmanager_secret.dockerhub arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:tf-web-dev-smg-dockerhub-credentials-xxxxx
```

- `terraform plan`を実行し、同一シークレットの再作成差分が出ないことを確認する。

### 3.4. シークレットが削除予約中の場合

- 先に`restore`してから`import`する。

```bash
AWS_PAGER='' aws secretsmanager restore-secret \
  --profile terraform-template \
  --region ap-northeast-1 \
  --secret-id <secret-name-or-arn>
```

## 4. 事後確認チェックリスト

対応後は次を実施する。

1. 対象環境ディレクトリで`terraform validate`を実行する。
2. `terraform plan`を実行し、意図した差分のみであることを確認する。
3. `terraform apply`を再実行する。
4. エラー内容と修正内容をこのメモへ追記する。

## 5. このプロジェクトの前提

- AWSプロファイル: `terraform-template`
- メインリージョン: `ap-northeast-1`
- 対象ディレクトリ: `develop`, `staging`, `production`, `audit`
