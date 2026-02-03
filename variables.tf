/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* KMS | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "kms_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "kms_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}
