variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region to deploy resources"
}

variable "validation" {
  type        = string
  description = "You probably don't want to delete this"
}
