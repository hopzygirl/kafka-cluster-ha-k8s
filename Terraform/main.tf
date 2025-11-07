#====================================================================
# Configuration Provider AWS
#====================================================================

terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source = "hshicorp/aws"
      version = "~> 5.0"
    }
  }
}

#Configuration AWS
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

