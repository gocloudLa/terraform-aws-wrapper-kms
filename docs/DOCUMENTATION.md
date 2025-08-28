# DOCUMENTATION

## Introducción

El Wrapper de Terraform para AWS KMS simplifica la gestión y despliegue de claves de cifrado en AWS Key Management Service.
Este wrapper funciona como una plantilla estandarizada que abstrae la complejidad técnica y permite crear múltiples claves KMS reutilizables que integran:

- **Claves estándar de cifrado/descifrado** para proteger datos en reposo
- **Claves asimétricas** para firma digital y cifrado de clave pública
- **Claves externas** importadas desde sistemas externos
- **Claves multi-región** para replicación global
- **Claves réplica** para alta disponibilidad
- **Integración con Route53 DNSSEC** para firma de zonas DNS
- **Políticas de acceso granulares** con usuarios, administradores y roles de servicio
- **Aliases y grants** para facilitar el acceso y gestión

## Modo de Uso

```hcl
module "wrapper_kms" {
  source = "path/to/wrapper_kms"

  metadata = local.metadata
  project  = "mi-proyecto"

  kms_parameters = {
    "clave-principal" = {
      description             = "Clave principal para cifrado de datos"
      deletion_window_in_days = 30
      enable_key_rotation     = true
      key_usage               = "ENCRYPT_DECRYPT"
      
      # Políticas de acceso
      enable_default_policy = true
      key_owners           = [data.aws_caller_identity.current.arn]
      key_administrators   = [data.aws_caller_identity.current.arn]
      key_users           = [data.aws_caller_identity.current.arn]
      
      # Aliases
      aliases = ["mi-proyecto/principal"]
      
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

## Parámetros de Configuración

| Parámetro | Tipo | Descripción | Categoría | Requerido | Valores/Ejemplo |
|-----------|------|-------------|-----------|-----------|------------------|
| `aliases` | list(string) | Lista de aliases para la clave | Alias | No | `["app/key", "service/key"]` |
| `aliases_use_name_prefix` | bool | Usar prefijo en nombres de aliases | Alias | No | `true/false` |
| `bypass_policy_lockout_safety_check` | bool | Omitir verificación de seguridad | Política | No | `true/false` |
| `computed_aliases` | map(object) | Aliases calculados dinámicamente | Alias | No | `{ex = {name = "computed"}}` |
| `create` | bool | Crear el recurso | Control | No | `true/false` |
| `create_external` | bool | Crear clave externa importada | Especial | No | `true/false` |
| `create_replica` | bool | Crear réplica de clave multi-región | Especial | No | `true/false` |
| `create_replica_external` | bool | Crear réplica de clave externa | Especial | No | `true/false` |
| `custom_key_store_id` | string | ID del almacén de claves personalizado | Avanzada | No | `"cks-..."` |
| `customer_master_key_spec` | string | Especificación de la clave | Básica | No | `SYMMETRIC_DEFAULT`, `RSA_2048`, `ECC_NIST_P256` |
| `deletion_window_in_days` | number | Días antes de eliminar la clave | Básica | No | `7-30` |
| `description` | string | Descripción de la clave | Básica | No | `"Clave para cifrado"` |
| `enable_default_policy` | bool | Usar política por defecto | Política | No | `true/false` |
| `enable_key_rotation` | bool | Habilitar rotación automática | Básica | No | `true/false` |
| `enable_route53_dnssec` | bool | Habilitar para DNSSEC | DNSSEC | No | `true/false` |
| `grants` | map(object) | Grants de acceso a la clave | Grant | No | Ver ejemplos |
| `is_enabled` | bool | Estado de la clave | Básica | No | `true/false` |
| `key_administrators` | list(string) | Lista de administradores | Política | No | `["arn:aws:iam::..."]` |
| `key_asymmetric_public_encryption_users` | list(string) | Usuarios para cifrado asimétrico | Política | No | `["arn:aws:iam::..."]` |
| `key_asymmetric_sign_verify_users` | list(string) | Usuarios para firma digital | Política | No | `["arn:aws:iam::..."]` |
| `key_hmac_users` | list(string) | Usuarios para HMAC | Política | No | `["arn:aws:iam::..."]` |
| `key_material_base64` | string | Material de clave para claves externas | Especial | No | `"base64string"` |
| `key_owners` | list(string) | Lista de propietarios de la clave | Política | No | `["arn:aws:iam::..."]` |
| `key_service_roles_for_autoscaling` | list(string) | Roles para Auto Scaling | Política | No | `["arn:aws:iam::..."]` |
| `key_service_users` | list(string) | Lista de usuarios de servicio | Política | No | `["arn:aws:iam::..."]` |
| `key_statements` | list(object) | Declaraciones de política personalizadas | Política | No | Ver ejemplos |
| `key_symmetric_encryption_users` | list(string) | Usuarios para cifrado simétrico | Política | No | `["arn:aws:iam::..."]` |
| `key_usage` | string | Tipo de uso de la clave | Básica | No | `ENCRYPT_DECRYPT`, `SIGN_VERIFY`, `GENERATE_VERIFY_MAC` |
| `key_users` | list(string) | Lista de usuarios con permisos de uso | Política | No | `["arn:aws:iam::..."]` |
| `kms_defaults` | map(any) | Valores por defecto aplicados a todas las claves | Principal | No | `{}` |
| `kms_parameters` | map(any) | Configuración específica de cada clave KMS | Principal | No | `{}` |
| `metadata` | any | Metadatos del proyecto (región, ambiente, etc.) | Principal | Sí | `local.metadata` |
| `multi_region` | bool | Crear como clave multi-región | Básica | No | `true/false` |
| `override_policy_documents` | list(string) | Documentos que sobrescriben política | Política | No | `["override.json"]` |
| `policy` | string | Política JSON personalizada | Política | No | `jsonencode({...})` |
| `primary_external_key_arn` | string | ARN de la clave externa primaria | Especial | No | `"arn:aws:kms:..."` |
| `primary_key_arn` | string | ARN de la clave primaria (para réplicas) | Especial | No | `"arn:aws:kms:..."` |
| `project` | string | Nombre del proyecto | Principal | Sí | `"mi-proyecto"` |
| `region` | string | Región para réplicas | Especial | No | `"us-west-2"` |
| `rotation_period_in_days` | number | Período de rotación en días | Avanzada | No | `90-2560` |
| `route53_dnssec_sources` | list(object) | Fuentes autorizadas para DNSSEC | DNSSEC | No | Ver ejemplos |
| `source_policy_documents` | list(string) | Documentos de política fuente | Política | No | `["policy.json"]` |
| `tags` | map(string) | Etiquetas para la clave | Metadatos | No | `{Environment = "prod"}` |
| `valid_to` | string | Fecha de expiración para claves externas | Especial | No | `"2025-12-31T23:59:59Z"` |

## Ejemplos de Uso

### Clave Estándar de Cifrado
```hcl
kms_parameters = {
  "datos-aplicacion" = {
    description             = "Clave para cifrar datos de aplicación"
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

### Clave para Firma Digital
```hcl
kms_parameters = {
  "firma-documentos" = {
    description              = "Clave para firma digital de documentos"
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

### Clave Multi-Región con Réplica
```hcl
kms_parameters = {
  "principal-global" = {
    description     = "Clave principal multi-región"
    multi_region    = true
    key_usage       = "ENCRYPT_DECRYPT"
    aliases         = ["global/primary"]
  }
  
  "replica-secundaria" = {
    region          = "us-west-2"
    description     = "Réplica en región secundaria"
    create_replica  = true
    primary_key_arn = module.wrapper_kms.wrapper_kms["principal-global"].key_arn
    aliases         = ["global/replica"]
  }
}
```

### Clave Externa Importada
```hcl
kms_parameters = {
  "clave-externa" = {
    description         = "Clave importada desde HSM externo"
    create_external     = true
    key_material_base64 = "Wblj06fduthWggmsT0cLVoIMOkeLbc2kVfMud77i/JY="
    valid_to           = "2025-12-31T23:59:59Z"
    
    aliases = ["external/hsm-key"]
  }
}
```

### Clave para Route53 DNSSEC
```hcl
kms_parameters = {
  "dnssec-signing" = {
    description              = "Clave para firma DNSSEC"
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

## Outputs

El módulo expone todos los outputs del módulo terraform-aws-modules/kms/aws a través de:

```hcl
output "wrapper_kms" {
  description = "Mapa completo de todas las claves KMS creadas"
  value       = module.kms
}
```

### Acceso a Outputs Específicos

```hcl
# ARN de una clave específica
local {
  key_arn = module.wrapper_kms.wrapper_kms["mi-clave"].key_arn
}

# ID de una clave específica
local {
  key_id = module.wrapper_kms.wrapper_kms["mi-clave"].key_id
}

# Aliases de una clave
local {
  aliases = module.wrapper_kms.wrapper_kms["mi-clave"].aliases
}
```

## Consideraciones de Seguridad

### Mejores Prácticas
1. **Principio de Menor Privilegio**: Asignar solo los permisos mínimos necesarios
2. **Rotación de Claves**: Habilitar rotación automática para claves simétricas
3. **Separación de Responsabilidades**: Diferentes roles para propietarios, administradores y usuarios
4. **Monitoreo**: Usar CloudTrail para auditar el uso de claves
5. **Backup**: Las claves multi-región proporcionan redundancia automática

### Políticas Recomendadas
```hcl
key_statements = [
  {
    sid = "RestrictToSpecificServices"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    
    principals = [{
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "rds.amazonaws.com"]
    }]
    
    condition = [{
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }]
  }
]
```

## Requisitos

### Versiones
- Terraform >= 1.5.7
- AWS Provider >= 6.0

### Permisos IAM Requeridos
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListRoles",
        "iam:ListUsers"
      ],
      "Resource": "*"
    }
  ]
}
```

## Limitaciones

1. **Claves Externas**: Requieren gestión manual del material de clave
2. **Réplicas**: No soporta crear replicas de claves primarias
3. **DNSSEC**: Limitado a claves ECC para Route53
4. **Rotación**: No disponible para claves asimétricas o externas
5. **Eliminación**: Período mínimo de 7 días para eliminación programada

## Soporte y Contribuciones

Para reportar problemas o solicitar nuevas funcionalidades, crear un issue en el repositorio del proyecto.