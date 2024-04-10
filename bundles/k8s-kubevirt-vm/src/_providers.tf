terraform {
  required_version = ">= 1.0"
  required_providers {
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region     = var.kubernetes_cluster.specs.aws.region
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
  default_tags {
    tags = var.md_metadata.default_tags
  }
}

provider "kubernetes" {
  host                   = var.kubernetes_cluster.data.authentication.cluster.server
  cluster_ca_certificate = base64decode(var.kubernetes_cluster.data.authentication.cluster.certificate-authority-data)
  token                  = var.kubernetes_cluster.data.authentication.user.token
}