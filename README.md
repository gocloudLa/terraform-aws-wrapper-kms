# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform KMS Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-kms/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-kms/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS KMS simplifies the management and deployment of encryption keys in AWS Key Management Service. This wrapper functions as a standardized template that abstracts technical complexity and enables the creation of multiple reusable KMS keys.

### ✨ Features

- 🔐 [Standard Encryption Keys](#standard-encryption-keys) - Creates symmetric encryption/decryption keys for data at rest protection

- 🔑 [Asymmetric Keys](#asymmetric-keys) - Supports digital signing and public key encryption with RSA and ECC keys

- 📥 [External Keys](#external-keys) - Imports key material from external systems and HSMs

- 🌐 [Route53 DNSSEC](#route53-dnssec) - Integrates with Route53 for DNS zone signing



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-kms" target="_blank">terraform-aws-modules/kms/aws</a> | 4.0.0 |



## 🚀 Quick Start
```hcl
module "wrapper_kms" {
  source = "path/to/wrapper_kms"

  metadata = local.metadata
  project  = "my-project"

  kms_parameters = {
    "main-key" = {
      description             = "Main encryption key for application data"
      deletion_window_in_days = 30
      enable_key_rotation     = true
      key_usage               = "ENCRYPT_DECRYPT"
      
      # Access policies
      enable_default_policy = true
      key_owners           = [data.aws_caller_identity.current.arn]
      key_administrators   = [data.aws_caller_identity.current.arn]
      key_users           = [data.aws_caller_identity.current.arn]
      
      # Aliases
      aliases = ["my-project/main"]
      
      tags = {
        Environment = "production"
        Purpose     = "data-encryption"
      }
    }
  }

  kms_defaults = {
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }
}
```


## 🔧 Additional Features Usage

### Standard Encryption Keys
Standard symmetric keys for encrypting and decrypting data at rest. Supports automatic key rotation and integrates with AWS services for seamless encryption.


<details><summary>Basic Encryption Key</summary>

```hcl
kms_parameters = {
  "app-data" = {
    description             = "Key for application data encryption"
    deletion_window_in_days = 30
    enable_key_rotation     = true
    key_usage               = "ENCRYPT_DECRYPT"
    
    enable_default_policy = true
    key_owners           = [data.aws_caller_identity.current.arn]
    key_users           = [aws_iam_role.app_role.arn]
    
    aliases = ["app/data-encryption"]
  }
}
```


</details>


### Asymmetric Keys
Asymmetric keys for digital signing and public key encryption operations. Supports RSA and ECC key specifications for various cryptographic use cases.


<details><summary>Digital Signing Key</summary>

```hcl
kms_parameters = {
  "document-signing" = {
    description              = "Key for digital document signing"
    key_usage                = "SIGN_VERIFY"
    customer_master_key_spec = "RSA_2048"
    enable_key_rotation      = false
    
    key_asymmetric_sign_verify_users = [
      aws_iam_role.document_signer.arn
    ]
    
    aliases = ["documents/signing-key"]
  }
}
```


</details>


### External Keys
Import your own key material from external key management systems or hardware security modules (HSMs) for compliance requirements.


<details><summary>External Key Import</summary>

```hcl
kms_parameters = {
  "external-key" = {
    description         = "Key imported from external HSM"
    create_external     = true
    key_material_base64 = "<base64-encoded-key-material>"
    valid_to           = "2025-12-31T23:59:59Z"
    
    aliases = ["external/hsm-key"]
  }
}
```


</details>


### Route53 DNSSEC
Specialized keys for Route53 DNSSEC signing operations to secure DNS zones and prevent DNS spoofing attacks.


<details><summary>DNSSEC Signing Key</summary>

```hcl
kms_parameters = {
  "dnssec-signing" = {
    description              = "Key for Route53 DNSSEC signing"
    key_usage                = "SIGN_VERIFY"
    customer_master_key_spec = "ECC_NIST_P256"
    enable_route53_dnssec    = true
    enable_key_rotation      = false
    
    route53_dnssec_sources = [{
      accounts_ids    = [data.aws_caller_identity.current.account_id]
      hosted_zone_arn = "arn:aws:route53:::hostedzone/*"
    }]
    
    aliases = ["route53/dnssec"]
  }
}
```


</details>










## ⚠️ Important Notes
- **🔑 Key Rotation:** Only available for symmetric keys, not asymmetric or external keys
- **🗑️ Deletion:** Minimum 7-day deletion window required for scheduled deletion
- **🔐 External Keys:** Require manual key material management and expiration dates



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 