##############################################################################
# Terraform Settings & Provider Configuration
##############################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

### AWS ###
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# ### Kubernetes ###
data "aws_eks_cluster_auth" "eks" {
  name = module.eks[0].cluster_name
}

provider "kubernetes" {
  host                   = module.eks[0].cluster_endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
}

provider "helm" {
  debug = true
  kubernetes {
    host                   = module.eks[0].cluster_endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
  }
}

provider "kubectl" {
  host                   = module.eks[0].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}