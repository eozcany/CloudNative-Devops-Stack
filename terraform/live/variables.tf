variable "region" {
  default = "us-east-1"
  type    = string
}

variable "reversed_ip_user" {
  description = "Username for the MySQL database"
  type        = string
  default     = "reversed_ip_user" 
}

variable "reversed_ip_db" {
  description = "Name of the MySQL database"
  type        = string
  default     = "reversed_ip_db"
}

variable "k8s_irsa_roles" {
  description = "List of k8s app IRSA roles used in the k8s cluster"
  type        = map(any)
  default = {
    "cluster-autoscaler" = {
      service_acount_name = "cluster-autoscaler"
      namespace           = "kube-system"

      policies = [
        {
          name = "cluster-autoscaler-policy"
          statements = [
            {
              statement_id = "clusterautoscaler"
              effect       = "Allow"
              actions = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeImages",
                "eks:DescribeNodegroup",
                "ec2:GetInstanceTypesFromInstanceRequirements",
              ]
              resources = ["*"]
            }
          ]
        }
      ]
    }
    "external-secrets" = {
      service_acount_name = "external-secrets"
      namespace           = "external-secrets"

      policies = [
        {
          name = "external-secrets"
          statements = [
            {
              statement_id = "externalSecrets"
              effect       = "Allow"
              actions = [
                "ssm:GetParameter*",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
              ]
              resources = ["*"]
            }
          ]
        }
      ]
    }
    "alb-ingress" = {
      service_acount_name = "alb-ingress"
      namespace           = "alb-ingress"

      policies = [
        {
          name = "algingress"
          statements = [
            {
              statement_id = "algingress"
              effect       = "Allow"
              actions = [
                "iam:CreateServiceLinkedRole",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "ec2:*",
                "elasticloadbalancing:*",
                "acm:*",
                "wafv2:*"
              ]
              resources = ["*"]
            }
          ]
        }
      ]
    }
    "actions-runner" = {
      service_acount_name = "actions-runner"
      namespace           = "actions-runner"

      policies = [
        {
          name = "actionsrunner"
          statements = [
            {
              statement_id = "actionsrunner"
              effect       = "Allow"
              actions = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage"
              ]
              resources = ["*"]
            }
          ]
        }
      ]
    }
  }
}