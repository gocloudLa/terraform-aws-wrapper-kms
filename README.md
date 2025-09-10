# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform KMS Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-kms/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-kms.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-kms/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS KMS simplifies the management and deployment of encryption keys in AWS Key Management Service. This wrapper functions as a standardized template that abstracts technical complexity and enables the creation of multiple reusable KMS keys.

### ✨ Features

- 🔐 **Standard Encryption Keys** - Creates symmetric encryption/decryption keys for data at rest protection
- 🔑 **Asymmetric Keys** - Supports digital signing and public key encryption with RSA and ECC keys  
- 🌍 **Multi-Region Keys** - Enables global key replication for high availability
- 📥 **External Keys** - Imports key material from external systems and HSMs
- 🌐 **Route53 DNSSEC** - Integrates with Route53 for DNS zone signing
- 🛡️ **Granular Access Policies** - Configures fine-grained permissions for users, administrators, and service roles

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

## 🔧 Usage Examples

### Standard Encryption Key
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
    
    grants = {
      app_access = {
        grantee_principal = aws_iam_role.app_role.arn
        operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
      }
    }
  }
}
```

### Digital Signing Key
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

### Multi-Region Key with Replica
```hcl
kms_parameters = {
  "global-primary" = {
    description  = "Primary multi-region key"
    multi_region = true
    key_usage    = "ENCRYPT_DECRYPT"
    aliases      = ["global/primary"]
  }
  
  "global-replica" = {
    region          = "us-west-2"
    description     = "Replica in secondary region"
    create_replica  = true
    primary_key_arn = module.wrapper_kms.wrapper_kms["global-primary"].key_arn
    aliases         = ["global/replica"]
  }
}
```

### Route53 DNSSEC Key
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

## 📋 Key Parameters

| Parameter | Description | Type | Required |
|-----------|-------------|------|----------|
| `metadata` | Project metadata (region, environment, etc.) | `any` | Yes |
| `project` | Project name | `string` | Yes |
| `kms_parameters` | Map of KMS key configurations | `map(any)` | No |
| `kms_defaults` | Default values applied to all keys | `map(any)` | No |

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `description` | Key description | `null` |
| `key_usage` | Key usage type | `"ENCRYPT_DECRYPT"` |
| `deletion_window_in_days` | Deletion window (7-30 days) | `null` |
| `enable_key_rotation` | Enable automatic rotation | `true` |
| `multi_region` | Create multi-region key | `false` |
| `aliases` | List of key aliases | `[each.key]` |
| `key_owners` | Key owner ARNs | `[]` |
| `key_administrators` | Key administrator ARNs | `[]` |
| `key_users` | Key user ARNs | `[]` |

## ⚠️ Important Notes
- **🔑 Key Rotation:** Only available for symmetric keys, not asymmetric or external keys
- **🗑️ Deletion:** Minimum 7-day deletion window required for scheduled deletion
- **🌍 Multi-Region:** Replicas cannot be created from primary keys in same region
- **🔐 External Keys:** Require manual key material management and expiration dates

## 📋 Outputs

Access KMS resources through the wrapper output:

```hcl
# Key ARN
local {
  key_arn = module.wrapper_kms.wrapper_kms["my-key"].key_arn
}

# Key ID  
local {
  key_id = module.wrapper_kms.wrapper_kms["my-key"].key_id
}

# Aliases
local {
  aliases = module.wrapper_kms.wrapper_kms["my-key"].aliases
}
```

---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.