resource "aws_iam_role" "lambda" {
  name_prefix = "kms-example"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

module "wrapper_kms" {
  source = "../../"

  metadata = local.metadata
  project  = local.project

  kms_parameters = {
    "00-complete" = {
      deletion_window_in_days = 7
      description             = "Complete key example showing various configurations available"
      enable_key_rotation     = false
      is_enabled              = true
      key_usage               = "ENCRYPT_DECRYPT"
      multi_region            = false

      # Policy
      enable_default_policy                  = true
      key_owners                             = [data.aws_caller_identity.current.arn]
      key_administrators                     = [data.aws_caller_identity.current.arn]
      key_users                              = [data.aws_caller_identity.current.arn]
      key_service_users                      = [data.aws_caller_identity.current.arn]
      key_service_roles_for_autoscaling      = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
      key_symmetric_encryption_users         = [data.aws_caller_identity.current.arn]
      key_hmac_users                         = [data.aws_caller_identity.current.arn]
      key_asymmetric_public_encryption_users = [data.aws_caller_identity.current.arn]
      key_asymmetric_sign_verify_users       = [data.aws_caller_identity.current.arn]
      key_statements = [
        {
          sid = "CloudWatchLogs"
          actions = [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
          ]
          resources = ["*"]

          principals = [
            {
              type        = "Service"
              identifiers = ["logs.${local.metadata.aws_region}.amazonaws.com"]
            }
          ]

          condition = [
            {
              test     = "ArnLike"
              variable = "kms:EncryptionContext:aws:logs:arn"
              values = [
                "arn:aws:logs:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*",
              ]
            }
          ]
        }
      ]

      # Aliases
      aliases = ["example", "00"]
      computed_aliases = {
        ex = {
          # Sometimes you want to pass in an upstream attribute as the name and
          # that conflicts with using `for_each over a `toset()` since the value is not
          # known until after applying. Instead, we can use `computed_aliases` to work
          # around this limitation
          # Reference: https://github.com/hashicorp/terraform/issues/30937
          name = aws_iam_role.lambda.name
        }
      }
      aliases_use_name_prefix = true

      # Grants
      grants = {
        lambda = {
          grantee_principal = aws_iam_role.lambda.arn
          operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
          constraints = [{
            encryption_context_equals = {
              Example = "Demo"
            }
          }]
        }
      }

      tags = local.common_tags
    }
    "01-external" = {

      deletion_window_in_days = 7
      description             = "External key example"
      create_external         = true
      is_enabled              = true
      key_material_base64     = "Wblj06fduthWggmsT0cLVoIMOkeLbc2kVfMud77i/JY="
      multi_region            = false
      valid_to                = replace(timeadd(plantimestamp(), "4380h"), "/T.*/", "T00:00:00Z") # 6 months

      tags = local.common_tags
    }
    "02-dnssec-signing" = {

      description = "CMK for Route53 DNSSEC signing"

      key_usage                = "SIGN_VERIFY"
      customer_master_key_spec = "ECC_NIST_P256"

      enable_route53_dnssec = true
      enable_key_rotation   = false
      route53_dnssec_sources = [
        {
          accounts_ids    = [data.aws_caller_identity.current.account_id] # can ommit if using current account ID which is default
          hosted_zone_arn = "arn:aws:route53:::hostedzone/*"              # can ommit, this is default value
        }
      ]

      aliases = ["route53/dnssec-ex"]

      tags = local.common_tags
    }
    "03-primary" = {

      deletion_window_in_days = 7
      description             = "Primary key of replica key example"
      enable_key_rotation     = false
      is_enabled              = true
      key_usage               = "ENCRYPT_DECRYPT"
      multi_region            = true

      aliases = ["primary-standard"]

      tags = local.common_tags
    }
    "04-primary_external" = {
      deletion_window_in_days = 7
      description             = "Primary external key of replica external key example"
      is_enabled              = true
      create_external         = true
      key_material_base64     = "Wblj06fduthWggmsT0cLVoIMOkeLbc2kVfMud77i/JY="
      multi_region            = true
      valid_to                = replace(timeadd(plantimestamp(), "4380h"), "/T.*/", "T00:00:00Z") # 6 months

      aliases = ["primary-external"]

      tags = local.common_tags
    }
  }

  kms_defaults = var.kms_defaults
}