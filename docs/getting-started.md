# Getting Started with VitePress on AWS

This guide will help you deploy a **VitePress documentation site** to **AWS S3** with **CloudFront** using Terraform. The setup ensures your site is private, fast, and served over HTTPS.

## Prerequisites

Make sure you have:

- [Git](https://git-scm.com/) installed
- [Terraform](https://www.terraform.io/downloads.html) installed
- [Node.js and npm](https://nodejs.org/) installed
- An AWS account with permissions to create S3 buckets, CloudFront distributions, and IAM policies

## 1. Clone the Repository

```bash
git clone https://github.com/NickMrshll/vitepress-on-aws.git
cd vitepress-on-aws
```

## 2. Configure terraform.tfvars

Create a `terraform.tfvars` file to define the bucket prefix and region:

```hcl
region = "eu-west-2"
bucket_prefix = "vitepress"
```

## 3. Initialize OpenTofu

```bash
tofu init
```

This will download the required AWS provider.

## 4. Login to your AWS account

Login to your AWS account, ensuring you can use the CLI to interact with your account and that suitable environment variable/configuration files have been set so OpenTofu will be able to install the application.

For more information, please see [AWS OpenTofu Provider](https://search.opentofu.org/provider/opentofu/aws/latest)

## 5. Review the OpenTofu plan

```bash
tofu plan
```

Review the resources that will be created:

- S3 bucket for the site
- CloudFront distribution with OAC
- Bucket policy to allow CloudFront access
- Local build step for VitePress

## 6. Apply the OpenTofu configuration

```bash
tofu apply
```

This will create all your infrastructure, the Cloudfront CDN can take up to 10 minutes to create.

## 7. Access your documentation

Access your documentation at the URL the script output, if you missed it, run the following command.

```bash
terraform output cloudfront_url
```
