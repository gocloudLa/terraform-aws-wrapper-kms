locals {

  metadata = {
    aws_region           = "us-east-2"
    aws_secondary_region = "us-east-1"
    environment          = "Production"
    project              = "Example"
    public_domain        = "democorp.cloud"
    private_domain       = "democorp"

    key = {
      company = "dmc"
      region  = "use2"
      env     = "prd"
      project = "example"
      layer   = "project"
    }
  }

  common_name_prefix = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_name = join("-", [
    local.common_name_prefix,
    local.metadata.key.project
  ])

  sso_admin_role_name = "AWSReservedSSO_Admin_c93014c44eb11264"
}