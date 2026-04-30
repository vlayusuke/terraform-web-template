# terraform-web-template

このテンプレートは、Amazon Web ServicesとTerraformによる、Web3レイヤ構成のWebアプリケーション向けのリソースを構築するために使用するものです。AWS Fargateを用いたコンテナを用いてWebアプリケーションを構築することを想定しています。

また、標準的な3ステージ構成としていますが、1つのAWSアカウントに対して、1つの環境を構築することを前提としています。

## ディレクトリ構成

このテンプレートは以下のディレクトリで構成されています。

### `audit`

Web3レイヤ構成のWebアプリケーションのAWSリソースのうち、セキュリティ & コンプライアンス系のリソースを集中管理して実装しています。

### `production`

Web3レイヤ構成のWebアプリケーション向けの**本番環境**を構築するためのAWSリソースを実装しています。

### `staging`

Web3レイヤ構成のWebアプリケーション向けの**ステージング環境**を構築するためのAWSリソースを実装しています。

### `develop`

Web3レイヤ構成のWebアプリケーション向けの**開発環境**を構築するためのAWSリソースを実装しています。

## 各種ProviderやruntimeのVersion

このテンプレートで使用している、Terraformの各種Providerや、PythonのruntimeのVersionは、以下の通りです。

### Terraformや各種ProviderのVersion

| Resources                  | Version  |
| -------------------------- | -------- |
| Terraform                  | 1.14.9   |
| AWS Provider               | 6.43.0   |
| AWS Cloud Control Provider | 1.82.0   |

### AWS Lambda関数に使用しているPythonのruntimeのVersion

| Resources                  | Version  |
| -------------------------- | -------- |
| Python                     | 3.14     |

## 環境構築をする際の注意事項

このテンプレートをベースラインとして環境構築をする際の注意事項は、以下の通りです。

### コードを修正する際の注意点

このリポジトリでは、GitHubユーザーに対してGPGキーによる認証を必須としています。この認証設定を有効にしていない場合はコミットやPull Requestの作成等が行えません。GPGキーによる認証を有効化する方法については、以下のGitHub公式ドキュメントを参考にしてください。

[新しいGPGキーを生成する - GitHubドキュメント](https://docs.github.com/ja/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

### 複数のプラットフォームでTerraformコマンドを実行する際の注意点

Terraformや各種Providerのアップデートを行なってから `terraform init -reconfigure` コマンドや `terraform init -upgrade` コマンドを実行した後に、macOSやWindowsなどの複数のプラットフォームで `.terraform.lock.hcl` に含まれるproviderのチェックサムがずれてしまうことを防止するため、 `terraform plan` コマンドを実行する前に、ターミナル上で以下のコマンドを実行してください。

```bash
terraform providers lock \
  -platform=windows_amd64 \
  -platform=darwin_amd64 \
  -platform=linux_amd64  \
  -platform=darwin_arm64 \
  -platform=linux_arm64
```

## インフラ構成図

このテンプレートで構築が可能なアーキテクチャのインフラ構成図は以下の通りです。

### 本番環境

![本番環境](./terraform-web-template-v2.4-en-prd.svg)

### ステージング環境

![ステージング環境](./terraform-web-template-v2.4-en-stg.svg)

### 開発環境

* ![開発環境](./terraform-web-template-v2.4-en-dev.svg)
