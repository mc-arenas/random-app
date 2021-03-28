variable "portainer_passw" {
  type        = string
}


variable "author" {
  description = "Name of the operator. Used as a prefix to avoid name collision on resources."
  type        = string
  default     = "mararezay"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_path" {
  description = "Key path for SSHing into EC2"
  type        = string
  default     = "mc-key.pem"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  type        = string
  default     = "mc-key"
}
