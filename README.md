# terraform-web-template

このテンプレートは、Amazon Web ServicesとTerraformによるWeb3レイヤ構成のWebアプリケーション向けのリソースを構築するために使用するものです。AWS Fargateを用いたコンテナで、Webアプリケーションを構築することを想定しています。

また、3ステージ構成を組みますが、1つのAWSアカウントに対して、1つの環境を構築することを前提としています。

## ディレクトリ構成

このテンプレートは以下のようなディレクトリで構成されています。

### `production`

Web3レイヤ構成のWebアプリケーション向けの**本番環境**のAWSリソースを実装しています。

### `staging`

Web3レイヤ構成のWebアプリケーション向けの**ステージング環境**のAWSリソースを実装しています。

### `develop`

Web3レイヤ構成のWebアプリケーション向けの**開発環境**のAWSリソースを実装しています。

## Terraformや各種ProviderのVersion

| Resources                  | Version  |
| -------------------------- | -------- |
| Terraform                  | 1.14.8   |
| AWS Provider               | 6.41.0   |
| AWS Cloud Control Provider | 1.80.0   |

## AWS Lambda関数に使用しているPythonのruntime

| Resources                  | Version  |
| -------------------------- | -------- |
| Python                     | 3.14     |
