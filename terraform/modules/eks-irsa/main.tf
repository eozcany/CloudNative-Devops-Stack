terraform {
  required_version = ">= 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

locals {
  role_name = "${var.cluster_id}-${var.namespace}-${var.name}"

  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
  cluster_oidc_provider_iam_arn = format(
    "arn:aws:iam::%s:oidc-provider/%s",
    data.aws_caller_identity.current.account_id,
    var.cluster_oidc_provider
  )

  # https://openid.net/specs/openid-connect-core-1_0.html#Claims
  cluster_oidc_provider_subject_variable_name = format(
    "%s:sub",
    var.cluster_oidc_provider
  )

  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
  cluster_oidc_provider_subject = format(
    "system:serviceaccount:%s:%s",
    var.namespace,
    var.service_acount_name
  )
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trusted_principal" {
  statement {
    sid     = "k8sIRSA"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.cluster_oidc_provider_iam_arn]
    }

    condition {
      test     = "StringEquals"
      variable = local.cluster_oidc_provider_subject_variable_name
      values   = [local.cluster_oidc_provider_subject]
    }
  }
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = "Kubernetes pod role"

  assume_role_policy = data.aws_iam_policy_document.trusted_principal.json

}

resource "aws_iam_role_policy" "policy" {
  count = length(var.policies)

  role   = aws_iam_role.role.id
  name   = var.policies[count.index].name
  policy = var.policies[count.index].policy
}