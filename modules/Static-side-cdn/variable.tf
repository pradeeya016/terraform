variable "bucket_name" {
  description = "The name for the S3 bucket."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}