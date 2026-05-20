# terraform-web-template

このテンプレートは、Amazon Web ServicesとTerraformによる、Web3レイヤ構成のWebアプリケーション向けのリソースを構築するために使用するものです。AWS Fargateを用いたコンテナを用いてWebアプリケーションを構築することを想定しています。

また、標準的な3ステージ構成としていますが、1つのAWSアカウントに対して、1つの環境を構築することを前提としています。

## ディレクトリ構成

このテンプレートは以下のディレクトリで構成されています。

### `/audit`

Web3レイヤ構成のWebアプリケーションのAWSリソースのうち、セキュリティ & コンプライアンス系のリソースと、それらに関連するリソースを集中管理して実装しています。

なお、1つのAWSアカウントに対して、1つの`/audit`ディレクトリ内で実装しているをセキュリティ & コンプライアンス系のAWSリソース構築することを想定して実装しています。

### `/production`

Web3レイヤ構成のWebアプリケーション向けの本番環境を構築するためのAWSリソースを実装しています。

### `/staging`

Web3レイヤ構成のWebアプリケーション向けのステージング環境を構築するためのAWSリソースを実装しています。

### `/develop`

Web3レイヤ構成のWebアプリケーション向けの開発環境を構築するためのAWSリソースを実装しています。

## Terraform & 各種Provider & 各種runtimeのVersion

このテンプレートで使用している、Terraform、各種Provider及びPythonのruntimeのVersionは、以下の通りです。

- [hashicorp/aws Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [hachicorp/awscc Terraform Registry](https://registry.terraform.io/providers/hashicorp/awscc/latest)

### Terraformや各種ProviderのVersion

| Resources                  | Version  |
| :------------------------- | -------: |
| Terraform                  | 1.15.3   |
| AWS Provider               | 6.45.0   |
| AWS Cloud Control Provider | 1.84.0   |

### AWS Lambda関数に使用しているPythonのruntimeのVersion

| Resources                  | Version  |
| :------------------------- | -------: |
| Python                     | 3.14     |

## 構築されるAWSリソースの数

このテンプレートを実行することにより構築されるAWSリソースの数は、以下の表の通りです。

| Environmtnt | Resource | Notice           |
| :---------- | -------: | :--------------- |
| develop     |      531 | N/A              |
| staging     |      531 | N/A              |
| production  |      531 | N/A              |
| audit       |      150 | Each AWS account |

## 環境構築をする際の注意事項

このテンプレートをベースラインとして環境構築をする際の注意事項は、以下の通りです。

### コードを修正する際の注意点

このリポジトリでは、GitHubユーザーに対してGPGキーによる認証を必須としています。この認証設定を有効にしていない場合はコミットやPull Requestの作成等が行えません。GPGキーによる認証を有効化する方法については、以下のGitHub公式ドキュメントを参考にしてください。

[新しいGPGキーを生成する - GitHubドキュメント](https://docs.github.com/ja/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

### 環境構築準備手順

環境構築準備手順は以下の通りです。(macOS上での実行を前提としています)

#### プロファイルの設定

構築に利用するAWSアカウントのプロファイルの設定を、`~/.aws/config`と`~/.aws/credentials`に設定します。

なお、IAMユーザーには多要素認証(MFA)の設定を必須化しているので、Terraform実行時にもMFAが適用されるように`mfa_serial`の値を設定しないと、Terraformの実行ができなくなるので、注意が必要です。

##### `~/.aws/config`

```bash:~/.aws/config
[profile terraform-web-template]
region = ap-northeast-1
output = json
mfa_serial=arn:aws:iam::{aws-account}:mfa/{mfa-device-name}
```

- {mfa-device-name}には、IAMコンソールのご自身のIAMユーザーの「多要素認証(MFA)」セクションに表示されている識別子の仮装MFAデバイス名を設定してください。

##### `~/.aws/credentials`

```bash:~/.aws/credentials
[terraform-web-template]
aws_access_key_id = ********************
aws_secret_access_key = ********************
```

なお、環境構築にあたっては、`aws-vault`の利用もご検討ください。

- [aws-vaultの使い方と仕組み](https://qiita.com/takuzo8679/items/6727f46b0aaf6df0a864)

#### Terraformコマンドを実行する際に必要な事前準備

Terraformコマンドを実行する前に、AWS CLIやTerraform CLIなどの必要なツールをインストールしてください。また、`terraform.tf`で実装している`terraform.tfstate`ファイルはS3バックエンドで保管するという設定にしているため、事前に各環境のAWSアカウントに紐づくAWSマネージメントコンソールの、Amazon S3コンソール内で、

```hcl:terraform.tf
backend "s3" {
  bucket  = "example-profile-name"
  key     = "key/example-environment.terraform.tfstate
  region  = "ap-northeast-1"
  profile = "example-profile-name"
...

}
```

に指定されている`bucket`ディレクティブと同じ名称のS3バケットを作成します。さらに、作成したS3バケットには、`key`プレフィックスを作成してください。Terraformの実行時には、作成した`key`プレフィックス内に`example-environment.terraform.tfstate`ファイルが作成されます。

#### Terraformコマンドを実行する際の注意点

- Terraformコマンドを実行する前に、各ディレクトリの`terraform.tfvars.sample`に記載されている内容に従って、`terraform.tfvars`を実装してください。このテンプレートでは、サンプルとして、GitHubリモートリポジトリ上での管理対象としない代表的な値のみを実装しています。利用方法に応じて適宜修正をしてください。
- `base_locals.tf`の`# project info`に設定している、`project`、`author`、`email`の値を修正してください。

#### 複数のプラットフォームでTerraformコマンドを実行する際の注意点

Terraformや各種Providerのバージョンのアップデートを行なってから`terraform init -reconfigure`コマンドや`terraform init -upgrade`コマンドを実行する際に、macOSやWindowsなどの複数のプラットフォーム間で`.terraform.lock.hcl`に含まれるproviderのチェックサムの値がずれてしまうことを防止するため、`terraform plan`コマンドを実行する前に、ターミナル上で以下のコマンドを実行してください。

```bash
terraform providers lock \
  -platform=windows_amd64 \
  -platform=darwin_amd64 \
  -platform=linux_amd64  \
  -platform=darwin_arm64 \
  -platform=linux_arm64
```

- 出典: [複数のプラットフォームで terraform initする際の注意点](https://dev.classmethod.jp/articles/multiplatform-terraform-init-lock/)

## インフラ構成図

このテンプレートで構築が可能なアーキテクチャのインフラ構成図は以下の通りです。

### 本番環境

![本番環境](./terraform-web-template-v1.0-en-prd.svg)

### ステージング環境

![ステージング環境](./terraform-web-template-v1.0-en-stg.svg)

### 開発環境

![開発環境](./terraform-web-template-v1.0-en-dev.svg)

## リリース履歴

このテンプレートのリリース履歴は、[Releases](https://github.com/vlayusuke/terraform-web-template/releases)を参照してください。

## ライセンス

このテンプレートは、GPL3のもとでライセンスされています。詳細は、[LICENSE](./LICENSE)を参照してください。

## 参考: このテンプレートの実装環境

- MacBook Air M2 (2022) 16GB Memory/512GB SSD
- macOS Tahoe 26.5
- Homebrew 5.1.11
- Terraform CLI 1.15.3
- AWS CLI 2.34.47
- Python 3.14.5
- Visual Studio Code
