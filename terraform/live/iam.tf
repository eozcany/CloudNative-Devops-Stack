data "aws_iam_policy_document" "irsa_role_policies" {
  for_each = local.irsa_role_policies

  dynamic "statement" {
    for_each = each.value.statements

    content {
      sid       = statement.value.statement_id
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

module "k8s_irsa" {
  source  = "../modules/eks-irsa"
  
  for_each = {
    for k, v in var.k8s_irsa_roles : k => v
    if local.create_eks != null
  }

  name                  = each.key
  namespace             = each.value.namespace
  service_acount_name   = each.value.service_acount_name
  cluster_id            = module.eks[0].cluster_name
  cluster_oidc_provider = module.eks[0].oidc_provider
  policies              = local.irsa_role_policy_documents[each.key]
}