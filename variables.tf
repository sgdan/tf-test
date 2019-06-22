variable "region" {
  description = "AWS region to use"
  default     = "us-east-1"
}

variable "remote_state_bucket" {
  description = "Name prefix of s3 bucket storing remote state"
  default     = "tf-test-state"
}

variable "internet_whitelist" {
  description = "Addresses to allow from the internet"
  default     = "127.0.0.1/32"
}
