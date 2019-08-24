variable "region" {
  description = "AWS region to use"
  default     = "us-east-1"
}

variable "internet_whitelist" {
  description = "Addresses to allow from the internet"
  default     = "127.0.0.1/32"
}

variable "domain" {
  description = "Domain to create DNS entries in"
  default     = "example.com"
}

variable "certificate_arn" {
  description = "ARN of certificate to use on ALB"
  default     = "arn:aws:acm:us-east-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "desktop_public_key" {
  description = "Public key used to connect via SSH to desktop instance"
  default = "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX== desktop-rsa-key"
}
