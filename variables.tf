variable "region" {
  description = "AWS region to use"
  default     = "us-east-1"
}

variable "internet_whitelist" {
  description = "Addresses to allow from the internet"
  default     = "127.0.0.1/32"
}
