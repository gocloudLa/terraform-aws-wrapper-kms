# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform KMS Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-kms/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-kms/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS KMS simplifies the management and deployment of encryption keys in AWS Key Management Service. This wrapper functions as a standardized template that abstracts technical complexity and enables the creation of multiple reusable KMS keys.

### ✨ Features

- 🌍 [Multi Region Replication](#multi-region-replication) - Create a primary multi‑region key and replicate it to secondary regions.

- 🔐 [Standard Encryption Keys](#standard-encryption-keys) - Creates symmetric encryption/decryption keys for data at rest protection

- 🔑 [Asymmetric Keys](#asymmetric-keys) - Supports digital signing and public key encryption with RSA and ECC keys

- 📥 [External Keys](#external-keys) - Imports key material from external systems and HSMs

- 🌐 [Route53 DNSSEC](#route53-dnssec) - Integrates with Route53 for DNS zone signing



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-kms" target="_blank">terraform-aws-modules/kms/aws</a> | 4.2.0 |



## 🚀 Quick Start
```hcl
kms_parameters = {
  "main-key" = {
    description             = "Main encryption key for application data"
    deletion_window_in_days = 30
    enable_key_rotation     = true
    key_usage               = "ENCRYPT_DECRYPT"

    # Access policies
    enable_default_policy = true
    key_administrators   = [data.aws_caller_identity.current.arn] 

    # Aliases
    aliases = ["my-project/main"]

    tags = {
      Environment = "production"
      Purpose     = "data-encryption"
    }
  }
}

kms_defaults = var.kms_defaults
```


## 🔧 Additional Features Usage

### Multi Region Replication
Use `multi_region = true` on a primary key to create a multi‑region KMS key, and then
create lightweight replicas in other regions using `create_replica`, `primary_key_arn`,
and `region`. This lets you use the same logical key across regions (for example,
for cross‑region disaster recovery or active‑active architectures) while keeping
AWS‑managed replication of key material.


<details><summary>Primary multi‑region key</summary>

```hcl
kms_parameters = {
  "primary-us-east-1" = {
    description             = "Primary multi-region key"
    deletion_window_in_days = 7
    key_usage               = "ENCRYPT_DECRYPT"
    customer_master_key_spec = "SYMMETRIC_DEFAULT"

    # Enable multi-region on the primary key
    multi_region = true

    aliases = ["app/multi-region-primary"]
  }
}
```


</details>

<details><summary>Replica key in secondary region</summary>

```hcl
# Example: create a replica of the primary key in us-west-2
kms_parameters = {
  "replica-us-west-2" = {
    description = "Replica of primary multi-region key in us-west-2"

    # This key will be a replica
    create_replica = true

    # ARN of the primary multi-region key
    primary_key_arn = module.wrapper_kms.kms["primary-us-east-1"].key_arn

    # Target AWS region for the replica
    region = "us-west-2"

    aliases = ["app/multi-region-replica"]
  }
}
```


</details>


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




## 📑 Inputs
| Name                                   | Description                                                                                                                                                           | Type             | Default      | Required |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------ | -------- |
| kms_defaults                           | Default values applied to all keys                                                                                                                                    | `map(any)`       | `{}`         | No       |
| kms_parameters                         | Map of KMS key configurations                                                                                                                                         | `map(any)`       | `{}`         | No       |
| aliases                                | List of key aliases                                                                                                                                                   | `list(string)`   | `[each.key]` | No       |
| aliases_use_name_prefix                | Use name prefix for aliases                                                                                                                                           | `bool`           | `false`      | No       |
| bypass_policy_lockout_safety_check     | Bypass policy lockout safety check                                                                                                                                    | `bool`           | `null`       | No       |
| computed_aliases                       | Computed aliases map                                                                                                                                                  | `map(string)`    | `{}`         | No       |
| create                                 | Whether to create the KMS key                                                                                                                                         | `bool`           | `true`       | No       |
| create_external                        | Create external key                                                                                                                                                   | `bool`           | `false`      | No       |
| create_replica                         | Create replica key                                                                                                                                                    | `bool`           | `false`      | No       |
| create_replica_external                | Create external replica key                                                                                                                                           | `bool`           | `false`      | No       |
| custom_key_store_id                    | Custom key store ID                                                                                                                                                   | `string`         | `null`       | No       |
| customer_master_key_spec               | Key spec (RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, ECC_SECG_P256K1, SYMMETRIC_DEFAULT, HMAC_224, HMAC_256, HMAC_384, HMAC_512, SM2) | `string`         | `null`       | No       |
| deletion_window_in_days                | Deletion window (7-30 days)                                                                                                                                           | `number`         | `null`       | No       |
| description                            | Key description                                                                                                                                                       | `string`         | `null`       | No       |
| enable_default_policy                  | Enable default key policy                                                                                                                                             | `bool`           | `true`       | No       |
| enable_key_rotation                    | Enable automatic rotation                                                                                                                                             | `bool`           | `true`       | No       |
| enable_route53_dnssec                  | Enable Route53 DNSSEC                                                                                                                                                 | `bool`           | `false`      | No       |
| grants                                 | Key grants configuration                                                                                                                                              | `map(any)`       | `null`       | No       |
| is_enabled                             | Whether the key is enabled                                                                                                                                            | `bool`           | `null`       | No       |
| key_administrators                     | Key administrator ARNs                                                                                                                                                | `list(string)`   | `[]`         | No       |
| key_asymmetric_public_encryption_users | Asymmetric public encryption user ARNs                                                                                                                                | `list(string)`   | `[]`         | No       |
| key_asymmetric_sign_verify_users       | Asymmetric sign/verify user ARNs                                                                                                                                      | `list(string)`   | `[]`         | No       |
| key_hmac_users                         | HMAC user ARNs                                                                                                                                                        | `list(string)`   | `[]`         | No       |
| key_material_base64                    | Base64 encoded key material for external keys                                                                                                                         | `string`         | `null`       | No       |
| key_owners                             | Key owner ARNs                                                                                                                                                        | `list(string)`   | `[]`         | No       |
| key_service_roles_for_autoscaling      | Service roles for autoscaling                                                                                                                                         | `list(string)`   | `[]`         | No       |
| key_service_users                      | Service user ARNs                                                                                                                                                     | `list(string)`   | `[]`         | No       |
| key_spec                               | Key spec (RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, ECC_SECG_P256K1, SYMMETRIC_DEFAULT, HMAC_224, HMAC_256, HMAC_384, HMAC_512, SM2) | `string`         | `null`       | No       |
| key_statements                         | Custom key policy statements                                                                                                                                          | `list(any)`      | `null`       | No       |
| key_symmetric_encryption_users         | Symmetric encryption user ARNs                                                                                                                                        | `list(string)`   | `[]`         | No       |
| key_usage                              | Key usage type (ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC)                                                                                                    | `string`         | `null`       | No       |
| key_users                              | Key user ARNs                                                                                                                                                         | `list(string)`   | `[]`         | No       |
| multi_region                           | Create multi-region key                                                                                                                                               | `bool`           | `false`      | No       |
| override_policy_documents              | Override policy documents                                                                                                                                             | `list(string)`   | `[]`         | No       |
| policy                                 | Custom key policy JSON                                                                                                                                                | `string`         | `null`       | No       |
| primary_external_key_arn               | Primary external key ARN for replica                                                                                                                                  | `string`         | `null`       | No       |
| primary_key_arn                        | Primary key ARN for replica                                                                                                                                           | `string`         | `null`       | No       |
| region                                 | Region for replica key                                                                                                                                                | `string`         | `null`       | No       |
| rotation_period_in_days                | Key rotation period in days                                                                                                                                           | `number`         | `null`       | No       |
| route53_dnssec_sources                 | Route53 DNSSEC source configuration                                                                                                                                   | `list(map(any))` | `null`       | No       |
| source_policy_documents                | Source policy documents                                                                                                                                               | `list(string)`   | `[]`         | No       |
| tags                                   | Resource tags                                                                                                                                                         | `map(string)`    | `{}`         | No       |
| valid_to                               | Expiration date for external key material                                                                                                                             | `string`         | `null`       | No       |







## ⚠️ Important Notes
- **🔑 Key Rotation:** Only available for symmetric keys, not asymmetric or external keys
- **🗑️ Deletion:** Minimum 7-day deletion window required for scheduled deletion
- **🔐 External Keys:** Require manual key material management and expiration dates
- **🌍 Multi-region keys:** `multi_region` must be decided at creation time (changing it forces recreation). Replicas require `create_replica = true`, a valid `primary_key_arn`, and a target `region`.



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