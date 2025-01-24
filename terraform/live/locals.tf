locals {
  create_eks = true
  
  tags = {
    Terraform   = "True"
    Environment = "Demo"
    Service     = "Assignment"
  }

  irsa_role_policies = (
    merge([
      for role_name, role in var.k8s_irsa_roles : merge([
        for policy in role.policies :
        {
          (format("%s-%s", role_name, policy.name)) = {
            "statements" = policy.statements
          }
        }
      ]...)
    ]...)
  )

  # Add support for irsa roles with dynamic policy lists
  irsa_role_policy_documents = (
    merge([
      for role_name, role in var.k8s_irsa_roles : merge([
        {
          (role_name) = concat([
            for policy in role.policies : {
              "name"   = policy.name
              "policy" = data.aws_iam_policy_document.irsa_role_policies[format("%s-%s", role_name, policy.name)].json
            }
          ])
        }
      ]...)
    ]...)
  )
}
