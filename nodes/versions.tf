terraform {
  required_version = ">= 1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = "~> 2.12"
    helm       = "~> 2.6"
  }
}