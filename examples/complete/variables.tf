/*----------------------------------------------------------------------*/
/* KMS | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "kms_defaults" {
  description = "Map of default values which will be used for each kms database."
  type        = any
  default     = {}
}

variable "kms_parameters" {
  description = "Maps of kms databases to create a wrapper from. Values are passed through to the module."
  type        = any
  default     = {}
}